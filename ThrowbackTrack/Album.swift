//
//  Album.swift
//  ThrowbackTrack
//
//  Created by Michael Miller on 5/13/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import Foundation

struct Album {
    
    enum ReleaseDatePrecision {
        case Day, Month, Year
    }
    
    let album: (id: String, name: String)
    let artists: [(id: String, name: String)]  //because spotify returns an array for each track, since a track can have more than one artist featured
    let albumPopularity: Int
    let trackIcons: [Image]
    
    let releaseDate: NSDate?
    let releaseDatePrecision: ReleaseDatePrecision?
    
    init(album: (id: String, name: String), artists: [(id: String, name: String)], albumPopularity: Int, trackIcons: [Image], releaseDate: String, releaseDatePrecision: String) {
        
        func formatDate(dateString: String, format: String) -> NSDate? {
            let formatter = NSDateFormatter()
            formatter.dateFormat = format
            return formatter.dateFromString(dateString)
        }
        
        self.album = album
        self.artists = artists
        self.albumPopularity = albumPopularity
        self.trackIcons = trackIcons
        
        switch releaseDatePrecision {
        case "day":
            self.releaseDatePrecision = ReleaseDatePrecision.Day
            self.releaseDate = formatDate(releaseDate, format: "yyyy-MM-dd")
        case "month":
            self.releaseDatePrecision = ReleaseDatePrecision.Month
            self.releaseDate = formatDate(releaseDate, format: "yyyy-MM")
        case "year":
            self.releaseDatePrecision = ReleaseDatePrecision.Year
            self.releaseDate = formatDate(releaseDate, format: "yyyy")
        default:
            self.releaseDatePrecision = nil
            self.releaseDate = nil
        }
    }

}