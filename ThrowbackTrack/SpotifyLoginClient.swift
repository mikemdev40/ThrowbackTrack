//
//  SpotifyClient.swift
//  ThrowbackTrack
//
//  Created by Michael Miller on 5/8/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import Foundation
import UIKit

class SpotifyLoginClient {
    
    //as outlined in https://developer.spotify.com/technologies/spotify-ios-sdk/tutorial/, it was necessary to FIRST set up spotify app settings (client ID, secret, and bundle ID) in developer account, THEN set up this project to handle the callback URI (which we want to be a "call to open the app back up and handle the response," not a website)

    //resource for explaining how to set up the oauth2 process: http://samwilskey.com/swift-oauth/
    
    static let sharedClient = SpotifyLoginClient()
    
    var stateValue: String?

    var searchResults = [Track]()
    
    var accessToken: String? {
        return getAccessToken()
    }
    
    var refreshToken: String? {
        return getRefreshToken()
    }
    
    var expired: Bool {
        return hasExpired()
    }
    
    //STEP 1 from https://developer.spotify.com/web-api/authorization-guide/ : application requests authorization
    //note that this URL is then handled by a view controller via a safari window, and presented to user to login (this is STEP 2, which is handled by LoginViewController)
    func getApplicationAuthorizationURL() -> NSURL {
        return getRequestURL()
    }
    
    //called from LoginViewController once the callback URL is received from the AppDelegte via the notification; this method determines if the callback contains code to exchange for an access code OR if there is an error (i.e. the user did not permit the app the requested scopes)
    func handleCallback(url: NSURL, completionHandler: (success: Bool, error: String?) -> Void) {
        
        guard let query = url.query else {
            completionHandler(success: false, error: "No query returned")
            return
        }
        
        if query.containsString("code=") {
            
            let queryParsed = query.componentsSeparatedByString("&")
            let codePart = queryParsed.first
            let code = codePart?.stringByReplacingOccurrencesOfString("code=", withString: "")
            
            //protection by checking to make sure state from callback URL matches the randomly generated state string that was used when making the original authentication call
            let statePart = queryParsed.last
            let state = statePart?.stringByReplacingOccurrencesOfString("state=", withString: "")
            guard state == stateValue else {
                completionHandler(success: false, error: "Mismatached state")
                return
            }
            
            if let code = code {
                getAccessToken(code, completionHandler: completionHandler)
            } else {
                completionHandler(success: false, error: "No embedded code found")
            }
            
        } else {
            completionHandler(success: false, error: "Requested access was denied.")
        }
    }
    
    //STEP 4 from https://developer.spotify.com/web-api/authorization-guide/ : application requests refresh and access tokens
    func getAccessToken(code: String, completionHandler: (success: Bool, error: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.AccessTokenConstants.PostURL)!)
        request.HTTPMethod = "POST"
        
        //NOTE that as an alternative to using the header, spotify provided the option to submit the client ID and secret as parameters of the http body; using the following code for the body AND REMOVING the header ALSO worked just fine! but i kept the header version for live code
        //  let body = "\(Constants.AccessTokenConstants.AuthParameters.GrantType)=\(Constants.AccessTokenConstants.AuthValues.GrantType)&\(Constants.AccessTokenConstants.AuthParameters.Code)=\(code)&\(Constants.AccessTokenConstants.AuthParameters.RedirectURI)=\(Constants.AccessTokenConstants.AuthValues.RedirectURI)&\(Constants.AccessTokenConstants.AuthParameters.ClientId)=\(Constants.AccessTokenConstants.AuthValues.ClientId)&\(Constants.AccessTokenConstants.AuthParameters.ClientSecret)=\(Constants.AccessTokenConstants.AuthValues.ClientSecret)"
        let body = "\(Constants.AccessTokenConstants.AuthParameters.GrantType)=\(Constants.AccessTokenConstants.AuthValues.GrantType)&\(Constants.AccessTokenConstants.AuthParameters.Code)=\(code)&\(Constants.AccessTokenConstants.AuthParameters.RedirectURI)=\(Constants.AccessTokenConstants.AuthValues.RedirectURI)"
        
        let bodyData = body.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPBody = bodyData
        
        //to setup the header correctly, i followed the example provided here http://swiftdeveloperblog.com/http-get-request-example-in-swift/ and used the format provided by spotify: "Basic <base64 encoded client_id:client_secret>"; the example outlined here http://stackoverflow.com/questions/24379601/how-to-make-an-http-request-basic-auth-in-swift helped with exact setup, since it became evident that "Basic <encoded64 string>" is typical! (i was trying to to send "Authorization: Basic <encoded64 string>" which didn't work
        let headerData = "\(Constants.AccessTokenConstants.AuthValues.ClientId):\(Constants.AccessTokenConstants.AuthValues.ClientSecret)".dataUsingEncoding(NSUTF8StringEncoding)
        guard let header64Encoded = headerData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions()) else {
            completionHandler(success: false, error: "There was a problem encoding the data")
            return
        }
        let headerFormattedForSpotify = "Basic \(header64Encoded)"
        request.addValue(headerFormattedForSpotify, forHTTPHeaderField: "Authorization")

        let session = getConfiguredSession()
        
        let task = session.dataTaskWithRequest(request) { [unowned self] (data, response, error) in
            
            guard error == nil else {
                completionHandler(success: false, error: error?.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print((response as? NSHTTPURLResponse)?.statusCode)
                completionHandler(success: false, error: "Unsuccessful status code: get access token")
                return
            }
            
            guard let data = data else {
                completionHandler(success: false, error: "No data")
                return
            }
            
            let parsedData = parseData(data)
            guard let parsedDict = parsedData as? [String: AnyObject] else {
                completionHandler(success: false, error: "Unable to convert to dictionary")
                return
            }
            //STEP 5 from https://developer.spotify.com/web-api/authorization-guide/ : tokens are returned to your application
            guard let access = parsedDict["access_token"] as? String, let refresh = parsedDict["refresh_token"] as? String, let timer = parsedDict["expires_in"] as? Int else {
                completionHandler(success: false, error: "No access token, request token, and/or expiration info")
                return
            }
            
            self.saveAccessInfo(access, refresh: refresh, timer: timer)            
        }
        
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    //STEP 7 from https://developer.spotify.com/web-api/authorization-guide/ : request access token from refresh token
    func refreshToken(completionHandler: (success: Bool, error: String?) -> Void) {
        
        guard let refresh = refreshToken else {
            completionHandler(success: false, error: "No refresh token")
            return
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.RefreshTokenConstants.PostURL)!)
        request.HTTPMethod = "POST"
        
        let body = "\(Constants.RefreshTokenConstants.AuthParameters.GrantType)=\(Constants.RefreshTokenConstants.AuthValues.GrantType)&\(Constants.RefreshTokenConstants.AuthParameters.RefreshToken)=\(refresh)"
        
        let bodyData = body.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPBody = bodyData
        
        let headerData = "\(Constants.RefreshTokenConstants.AuthValues.ClientId):\(Constants.RefreshTokenConstants.AuthValues.ClientSecret)".dataUsingEncoding(NSUTF8StringEncoding)
        guard let header64Encoded = headerData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions()) else {
            completionHandler(success: false, error: "There was a problem encoding the data")
            return
        }
        
        let headerFormattedForSpotify = "Basic \(header64Encoded)"
        request.addValue(headerFormattedForSpotify, forHTTPHeaderField: "Authorization")
        
        let session = getConfiguredSession()
        
        let task = session.dataTaskWithRequest(request) { [unowned self] (data, response, error) in
            
            guard error == nil else {
                completionHandler(success: false, error: error?.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print((response as? NSHTTPURLResponse)?.statusCode)
                completionHandler(success: false, error: "Unsuccessful status code: refresh")
                return
            }
            
            guard let data = data else {
                completionHandler(success: false, error: "No data")
                return
            }
            
            let parsedData = parseData(data)
            guard let parsedDict = parsedData as? [String: AnyObject] else {
                completionHandler(success: false, error: "Unable to convert to dictionary")
                return
            }
            //note that per https://developer.spotify.com/web-api/authorization-guide/ on step 7, refresh tokens are not returned when a refresh token is used to get a new access token
            guard let access = parsedDict["access_token"] as? String, let timer = parsedDict["expires_in"] as? Int else {
                completionHandler(success: false, error: "No access token and/or expiration info")
                return
            }
        
            //"refresh" is from current scope and is just the old refresh token, so the refresh token just gets resaved
            self.saveAccessInfo(access, refresh: refresh, timer: timer)
            completionHandler(success: true, error: nil)
        }
        
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func getRequestURL() -> NSURL {
        
        let parameters: [String: String] = [
            Constants.AuthorizationConstants.AuthParameters.ClientId: Constants.AuthorizationConstants.AuthValues.ClientId,
            Constants.AuthorizationConstants.AuthParameters.RedirectURI: Constants.AuthorizationConstants.AuthValues.RedirectURI,
            Constants.AuthorizationConstants.AuthParameters.ResponseType: Constants.AuthorizationConstants.AuthValues.ResponseType,
            Constants.AuthorizationConstants.AuthParameters.Scope: Constants.AuthorizationConstants.AuthValues.Scope,
            Constants.AuthorizationConstants.AuthParameters.State: getRandomState()]
        
        let NSURLFromComponents = NSURLComponents()
        NSURLFromComponents.scheme = Constants.AuthorizationConstants.Scheme
        NSURLFromComponents.host = Constants.AuthorizationConstants.Host
        NSURLFromComponents.path = Constants.AuthorizationConstants.Path
        
        var queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: value)
            queryItems.append(queryItem)
        }
        NSURLFromComponents.queryItems = queryItems
        
        return NSURLFromComponents.URL!
    }
    
    func saveAccessInfo(access: String?, refresh: String?, timer: Int?) {
        if access != nil {
            NSUserDefaults.standardUserDefaults().setObject(access!, forKey: "accessToken")
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("accessToken")
        }
        
        if refresh != nil {
            NSUserDefaults.standardUserDefaults().setObject(refresh!, forKey: "refreshToken")
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("refreshToken")
        }
        
        if timer != nil {
            NSUserDefaults.standardUserDefaults().setInteger(timer!, forKey: "expiresIn")
            NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "dateSaved")
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("expiresIn")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("dateSaved")
        }
    }
    
    func logout() {
        saveAccessInfo(nil, refresh: nil, timer: nil)
        print("logged out")
    }
    
    func getAccessToken() -> String? {
        if let access = NSUserDefaults.standardUserDefaults().objectForKey("accessToken") as? String {
            return access
        } else {
            return nil
        }
    }
    
    func getRefreshToken() -> String? {
        if let refresh = NSUserDefaults.standardUserDefaults().objectForKey("refreshToken") as? String {
            return refresh
        } else {
            return nil
        }
    }
    
    func hasExpired() -> Bool {
        
        guard let dateSaved = NSUserDefaults.standardUserDefaults().objectForKey("dateSaved") as? NSDate else {
            return true
        }
        
        guard let expiryTimeInSeconds = NSUserDefaults.standardUserDefaults().objectForKey("expiresIn") as? Int else {
            return true
        }
        //date comparison: http://stackoverflow.com/questions/26198526/nsdate-comparison-using-swift
        let expiresAt = dateSaved.dateByAddingTimeInterval(Double(expiryTimeInSeconds))
        print(dateSaved)
        print(expiresAt)
        return NSDate().compare(expiresAt) == .OrderedDescending
    }
    
    func getRandomState() -> String {
        let state = NSUUID().UUIDString
        stateValue = state
        return state
    }
    
    private init() { }
}