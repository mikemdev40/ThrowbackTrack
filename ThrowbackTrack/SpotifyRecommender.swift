//
//  SpotifyRecommender.swift
//  ThrowbackTrack
//
//  Created by Michael Miller on 5/14/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import Foundation

class SpotifyRecommender: SpotifyMusicGetter {
    
    static let sharedInstance = SpotifyRecommender()
    
    func getRecommendations(completionHandler: (success: Bool, error: String?) -> Void) {
        
        let parameters: [String: String] = ["seed_artists": "3fMbdgg4jU18AjLCKBhRSm", "min_popularity": "30", "limit": "100", "seed_genre": "pop"]
        
        let nsurl = getNSURLFromComponents("https", host: "api.spotify.com", path: "/v1/recommendations", parameters: parameters)
        
        let request = NSMutableURLRequest(URL: nsurl)
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
            
            if let tracks = parsedData["tracks"] as? [[String: AnyObject]] {
                
                var parsedTracks = self.getTracks(tracks)
                print(parsedTracks.count)
                parsedTracks.sortInPlace({ (element1, element2) -> Bool in
                    return element1.trackPopularity > element2.trackPopularity
                })
                for track in parsedTracks {
                    print("\(track.artists.first?.name), \(track.track.name), \(track.trackPopularity)")
                }
            }
            
        }
        
        task.resume()
        session.finishTasksAndInvalidate()
        
    }
    
}