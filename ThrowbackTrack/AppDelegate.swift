//
//  AppDelegate.swift
//  ThrowbackTrack
//
//  Created by Michael Miller on 5/3/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //STEP 3 from https://developer.spotify.com/web-api/authorization-guide/ : The user is redirected back to your specified URI
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
        guard let launch = options["UIApplicationOpenURLOptionsSourceApplicationKey"] as? String where launch == "com.apple.SafariViewService" else {
            return false
        }
        
        guard url.scheme == Constants.CallbackConstants.Scheme && url.host == Constants.CallbackConstants.Host else {
            return false
        }
        
        //the callback url, which contains either the code that will be exchanged for the access token or the error message, is sent back to the LoginViewController (a receiver of this notification) via a notification object, as set up below; the callback URL is then processed by the SpotifyClient
        let notification = NSNotification(name: Constants.LoginViewConstants.DismissSafariWindowNotification, object: url)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    
        return true
    }
}

