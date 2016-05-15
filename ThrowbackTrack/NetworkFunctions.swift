//
//  NetworkFunctions.swift
//  ThrowbackTrack
//
//  Created by Michael Miller on 5/14/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import Foundation

func getConfiguredSession() -> NSURLSession {
    let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
    config.timeoutIntervalForRequest = 15
    return NSURLSession(configuration: config)
}

func parseData(dateToParse: NSData) -> NSDictionary? {
    let JSONData: AnyObject?
    do {
        JSONData = try NSJSONSerialization.JSONObjectWithData(dateToParse, options: .AllowFragments)
    } catch {
        return nil
    }
    guard let parsedData = JSONData as? NSDictionary else {
        return nil
    }
    return parsedData
}

func getNSURLFromComponents(scheme: String, host: String, path: String, parameters: [String: String]?) -> NSURL {
    
    let NSURLFromComponents = NSURLComponents()
    NSURLFromComponents.scheme = scheme
    NSURLFromComponents.host = host
    NSURLFromComponents.path = path
    
    if let parameters = parameters {
        var queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: value)
            queryItems.append(queryItem)
        }
        NSURLFromComponents.queryItems = queryItems
    }

    return NSURLFromComponents.URL!
}