//
//  SpotifyYearSearch.swift
//  ThrowbackTrack
//
//  Created by Michael Miller on 5/14/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import Foundation

class SpotifyYearSearcher: SpotifyMusicGetter {
    
    static let sharedInstance = SpotifyYearSearcher()
    
    func searchYears(year1: String?, year2: String?, keyword: String?, genre: String?, completionHandler: (success: Bool, error: String?) -> Void) {
        
        guard let year1 = year1, let year2 = year2, let keyword = keyword, let genre = genre else {
            return
        }
        
        //        let parameters: [String: String] = ["q": "\(keyword) genre:\(genre) year:\(year1)-\(year2)", "limit": "50", "type": "track"]
        let parameters: [String: String] = ["q": "year:\(year1)-\(year2)", "limit": "20", "type": "track"]
        
        let NSURLFromComponents = NSURLComponents()
        NSURLFromComponents.scheme = "https"
        NSURLFromComponents.host = "api.spotify.com"
        NSURLFromComponents.path = "/v1/search"
        
        var queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: value)
            queryItems.append(queryItem)
        }
        NSURLFromComponents.queryItems = queryItems
        
        let request = NSMutableURLRequest(URL: NSURLFromComponents.URL!)
        request.HTTPMethod = "GET"
        
        guard let token = SpotifyLoginClient.sharedClient.accessToken else {
            completionHandler(success: false, error: "No access token")
            return
        }
        
        let headerFormattedForSpotify = "Bearer \(token)"
        request.addValue(headerFormattedForSpotify, forHTTPHeaderField: "Authorization")
        
        let session = getConfiguredSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard error == nil else {
                completionHandler(success: false, error: error?.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print((response as? NSHTTPURLResponse)?.statusCode)
                completionHandler(success: false, error: "Unsuccessful status code")
                return
            }
            
            guard let data = data else {
                completionHandler(success: false, error: "No data")
                return
            }
            
            guard let parsedData = parseData(data) else {
                completionHandler(success: false, error: "There was an error parsing the data")
                return
            }
            
            print(parsedData)
            if let tracks = parsedData["tracks"] as? [String: AnyObject] {
                if let trackItems = tracks["items"] as? [[String: AnyObject]] {
                    var parsedTracks = self.getTracks(trackItems)
                    print(parsedTracks.count)
                    parsedTracks.sortInPlace({ (element1, element2) -> Bool in
                        return element1.trackPopularity > element2.trackPopularity
                    })
                    for track in parsedTracks {
                        print("\(track.artists.first?.name), \(track.track.name), \(track.trackPopularity)")
                    }
                    
                    self.getFullAlbumInfo(parsedTracks, completionHandler: completionHandler)
                    
                }
            }
            
        }
        
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    private func getFullAlbumInfo(tracks: [Track], completionHandler: (success: Bool, error: String?) -> Void) {
        
        var stringOfAlbumIDs = ""
        
        for track in tracks {
            stringOfAlbumIDs += "\(track.album.id),"
        }
        
        if stringOfAlbumIDs != "" {
            stringOfAlbumIDs.removeAtIndex(stringOfAlbumIDs.endIndex.predecessor())
        }
        
        let parameters: [String: String] = ["ids": stringOfAlbumIDs]
        
        let NSURLFromComponents = NSURLComponents()
        NSURLFromComponents.scheme = "https"
        NSURLFromComponents.host = "api.spotify.com"
        NSURLFromComponents.path = "/v1/albums"
        
        var queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: value)
            queryItems.append(queryItem)
        }
        NSURLFromComponents.queryItems = queryItems
        
        let request = NSMutableURLRequest(URL: NSURLFromComponents.URL!)
        request.HTTPMethod = "GET"
        
        guard let token = SpotifyLoginClient.sharedClient.accessToken else {
            completionHandler(success: false, error: "No access token")
            return
        }
        
        let headerFormattedForSpotify = "Bearer \(token)"
        request.addValue(headerFormattedForSpotify, forHTTPHeaderField: "Authorization")
        
        let session = getConfiguredSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard error == nil else {
                completionHandler(success: false, error: error?.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print((response as? NSHTTPURLResponse)?.statusCode)
                completionHandler(success: false, error: "Unsuccessful status code")
                return
            }
            
            guard let data = data else {
                completionHandler(success: false, error: "No data")
                return
            }
            
            guard let parsedData = parseData(data) else {
                completionHandler(success: false, error: "There was an error parsing the data")
                return
            }
            
            if let albums = parsedData["albums"] as? [[String: AnyObject]] {
                var parsedAlbums = self.getAlbums(albums)
                
                parsedAlbums.sortInPlace({ (element1, element2) -> Bool in
                    guard let release1 = element1.releaseDate, let release2 = element2.releaseDate else {
                        return false
                    }
                    return release1.compare(release2) == .OrderedDescending
                })
                
                for album in parsedAlbums {
                    if album.releaseDatePrecision == .Month || album.releaseDatePrecision == .Day {
                        print("\(album.album.name) \(album.albumPopularity) \(album.releaseDate)")
                    }
                }
                
            }
            
        }
        
        task.resume()
        session.finishTasksAndInvalidate()
        
    }
    
}