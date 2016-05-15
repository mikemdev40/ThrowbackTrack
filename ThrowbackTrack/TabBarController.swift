//
//  TabBarController.swift
//  ThrowbackTrack
//
//  Created by Michael Miller on 5/15/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()


        if SpotifyLoginClient.sharedClient.expired {
            if let _ = SpotifyLoginClient.sharedClient.accessToken {
                SpotifyLoginClient.sharedClient.refreshToken({ (success, error) in
                    if success {
                        print("refresh token: SUCESS!")
                    } else {
                        print(error)
                    }
                })
            } else {
                let authenticateViewController = storyboard!.instantiateViewControllerWithIdentifier(Constants.LoginViewConstants.AuthenticationVCName)
                presentViewController(authenticateViewController, animated: true, completion: nil)
            }

        }
        
    }

}
