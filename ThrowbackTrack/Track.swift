//
//  Track.swift
//  ThrowbackTrack
//
//  Created by Michael Miller on 5/13/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import Foundation

struct Track {
    
    let track: (id: String, name: String)
    let album: (id: String, name: String)
    let artists: [(id: String, name: String)]  //because spotify returns an array for each track, since a track can have more than one artist featured
    let trackPopularity: Int
    let previewURL: String?
    let trackIcons: [Image]
}