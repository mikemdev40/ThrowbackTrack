//
//  SpotifyPlaylistManager.swift
//  ThrowbackTrack
//
//  Created by Michael Miller on 5/14/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import Foundation

class SpotifyPlaylistManager {
    
    static let sharedInstance = SpotifyPlaylistManager()
    
    func getSelf(completionHandler: (success: Bool, error: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.spotify.com/v1/me/playlists")!)
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
            
            let parsedData = parseData(data)
            print(parsedData)
        }
        
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func getListOfGenres(completionHandler: (success: Bool, error: String?) -> Void) {
        
        //let request = NSMutableURLRequest(URL: NSURL(string: "https://api.spotify.com/v1/browse/categories")!)
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.spotify.com/v1/recommendations/available-genre-seeds")!)
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
            
            let parsedData = parseData(data)
            print(parsedData)
        }
        
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    
}