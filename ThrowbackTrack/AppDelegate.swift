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
    
    
    //http://stackoverflow.com/questions/19962276/best-practices-for-storyboard-login-screen-handling-clearing-of-data-upon-logou
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        if SpotifyLoginClient.sharedClient.expired {
            if let _ = SpotifyLoginClient.sharedClient.accessToken {
                SpotifyLoginClient.sharedClient.refreshToken({ (success, error) in
                    if success {
                        print("refresh token: SUCESS!")
                    } else {
                        print(error)
                        
                        
                        //SHOW LOGIN SCREEN AND SHOW ERROR
                        
                        
                    }
                })
            } else {
                let authVC = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier(Constants.LoginViewConstants.AuthenticationVCName)
                window?.rootViewController = authVC
            }
        }
        return true
    }
    
}

