//
//  SearchViewController.swift
//  ThrowbackTrack
//
//  Created by Michael Miller on 5/10/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var year1: UITextField! { didSet { year1.delegate = self }}
    @IBOutlet weak var year2: UITextField! { didSet { year2.delegate = self }}
    @IBOutlet weak var keyword: UITextField! { didSet { keyword.delegate = self }}
    @IBOutlet weak var genre: UITextField! { didSet { genre.delegate = self }}
    
    // ERROR CHECK FOR INT ENTRIES!!!!!!!
    
    @IBAction func searchYears(sender: UIButton) {
        
        //CHECK FOR ACTIVE TOKEN, AND IF NOT, AUTOREFRESH TOKEN BEFORE PERFORMING THE SEARCH
        
        SpotifyYearSearcher.sharedInstance.searchYears(year1.text, year2: year2.text) { (success, error) in
            print(success)
        }
    }
    
    @IBAction func search(sender: UIButton) {
        
        //CHECK FOR ACTIVE TOKEN, AND IF NOT, AUTOREFRESH TOKEN BEFORE PERFORMING THE SEARCH

        SpotifyRecommender.sharedInstance.getRecommendations { (success, error) in
            print(success)
        }
        
    }
    
    @IBAction func getMore(sender: UIButton) {
        
        //CHECK FOR ACTIVE TOKEN, AND IF NOT, AUTOREFRESH TOKEN BEFORE PERFORMING THE SEARCH
        SpotifyYearSearcher.sharedInstance.getNextTracks { (success, error) in
            print("get more: \(success)")
        }

    }
    
    @IBAction func genres(sender: UIButton) {
        
        //CHECK FOR ACTIVE TOKEN, AND IF NOT, AUTOREFRESH TOKEN BEFORE PERFORMING THE SEARCH

        SpotifyPlaylistManager.sharedInstance.getListOfGenres { (success, error) in
            print(success)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}