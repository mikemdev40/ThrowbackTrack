//
//  SpotifyMusicGetter.swift
//  ThrowbackTrack
//
//  Created by Michael Miller on 5/14/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import Foundation

class SpotifyMusicGetter {
    
    func getTracks(tracksToParse: [[String: AnyObject]]) -> [Track] {
        
        var tracks = [Track]()
        
        for track in tracksToParse {
            let trackId = track["id"] as! String
            let trackName = track["name"] as! String
            
            let albumTemp = track["album"] as! [String: AnyObject]
            let albumId = albumTemp["id"] as! String
            let albumName = albumTemp["name"] as! String
            
            let imageArray = albumTemp["images"] as! [[String: AnyObject]]
            var images = [Image]()
            for image in imageArray {
                if let height = image["height"] as? Int, let width = image["width"] as? Int, let url = image["url"] as? String {
                    let imageToAppend = Image(url: url, width: width, height: height)
                    images.append(imageToAppend)
                }
            }
            
            let artistTemp = track["artists"] as! [[String: AnyObject]]
            var artists = [(id: String, name: String)]()
            for artist in artistTemp {
                let artistId = artist["id"] as! String
                let artistName = artist["name"] as! String
                artists.append((id: artistId, name: artistName))
            }
            
            let trackPopularity = track["popularity"] as! Int
            let previewURL = track["preview_url"] as? String
            
            tracks.append(Track(track: (id: trackId, name: trackName), album: (id: albumId, name: albumName), artists: artists, trackPopularity: trackPopularity, previewURL: previewURL, trackIcons: images))
        }
        
        return tracks
    }
    
    func getAlbums(albumsToParse: [[String: AnyObject]]) -> [Album] {
        
        var albums = [Album]()
        
        for album in albumsToParse {
            let albumId = album["id"] as! String
            let albumName = album["name"] as! String
            
            let imageArray = album["images"] as! [[String: AnyObject]]
            var images = [Image]()
            for image in imageArray {
                if let height = image["height"] as? Int, let width = image["width"] as? Int, let url = image["url"] as? String {
                    let imageToAppend = Image(url: url, width: width, height: height)
                    images.append(imageToAppend)
                }
            }
            
            let artistTemp = album["artists"] as! [[String: AnyObject]]
            var artists = [(id: String, name: String)]()
            for artist in artistTemp {
                let artistId = artist["id"] as! String
                let artistName = artist["name"] as! String
                artists.append((id: artistId, name: artistName))
            }
            
            let albumPopularity = album["popularity"] as! Int
            let releaseDate = album["release_date"] as! String
            let releaseDatePrecision = album["release_date_precision"] as! String
            
            albums.append(Album(album: (id: albumId, name: albumName), artists: artists, albumPopularity: albumPopularity, trackIcons: images, releaseDate: releaseDate, releaseDatePrecision: releaseDatePrecision))
        }
        
        return albums
    }
}