//
//  ViewController.swift
//  ThrowbackTrack
//
//  Created by Michael Miller on 5/3/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import UIKit
import SafariServices

class LoginViewController: UIViewController {

    //idea for using notifications to dismiss safari window when callback is received from spotify came from http://strawberrycode.com/blog/sfsafariviewcontroller-and-oauth-the-instagram-example/

    var safariWindow: SFSafariViewController?
    
    //STEP 2 from https://developer.spotify.com/web-api/authorization-guide/ : the user is asked to authorize access within the scopes
    @IBAction func login(sender: UIButton) {
        
        //gets the authorization URL to ask user for permission; creates the URL that contains all the necessary info for making contact with spotify (including scopes)
        let authorizationURL = SpotifyLoginClient.sharedClient.getApplicationAuthorizationURL()
        
        //creates and presents a safari window to display the authorization URL (which will ask user to login to spotify if they aren't already, then to click OKAY or CANCEL to the requested permissions/scopes)
        safariWindow = SFSafariViewController(URL: authorizationURL)
        safariWindow?.delegate = self
        presentViewController(safariWindow!, animated: true, completion: nil)
    }
    
    @IBOutlet weak var messageLabel: UILabel!
    
    //called as part of the notifcation set up below, which is sent by the AppDelegate and received by this VC when the callback URL is sent by spotify after the user OKAYS or CANCELS the app's request for priveleges
    func dismissSafariAndDeliverNotication(notification: NSNotification) {
        print("CALLBACK RECEIVED")
        safariWindow?.dismissViewControllerAnimated(true, completion: nil)
        manageCallback(notification)
    }
    
    func manageCallback(notification: NSNotification) {
        let url = notification.object as! NSURL
        
        SpotifyLoginClient.sharedClient.handleCallback(url) { (success, error) in
            if success {
                print("SUCCESS!")
            } else {
                print(error)
            }
        }
    }
    
    @IBAction func getRefresh(sender: UIButton) {
        SpotifyLoginClient.sharedClient.refreshToken { (success, error) in
            if success {
                print("successfully refreshed token")
            } else {
                print(error)
            }
        }
    }
    
    @IBAction func accessSpotify(sender: UIButton) {
        SpotifyPlaylistManager.sharedInstance.getSelf { (success, error) in
            print(success)
            print(error)
        }
    }
    
    @IBAction func logout(sender: UIButton) {
        SpotifyLoginClient.sharedClient.logout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(NSDate())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.dismissSafariAndDeliverNotication), name: Constants.LoginViewConstants.DismissSafariWindowNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if SpotifyLoginClient.sharedClient.expired {
            messageLabel.text = "Access expired"
        } else {
            messageLabel.text = "Access enabled"
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.LoginViewConstants.DismissSafariWindowNotification, object: nil)
    }

}

extension LoginViewController: SFSafariViewControllerDelegate {
    
    func safariViewController(controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        print("SF loaded: \(didLoadSuccessfully)")
    }
    
    //not called when "dismissSafari" is called instead from the notifcation
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        print("SF done button pressed")
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
