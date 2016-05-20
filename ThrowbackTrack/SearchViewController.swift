//
//  SearchViewController.swift
//  ThrowbackTrack
//
//  Created by Michael Miller on 5/15/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var year1: UITextField!
    @IBOutlet weak var year2: UITextField!
    
    @IBOutlet weak var table: UITableView! {
        didSet {
            table.delegate = self
            table.dataSource = self
        }
    }
    
    @IBAction func selectSegment(sender: UISegmentedControl) {
    }
    
    @IBAction func search(sender: UIButton) {
    
        //check to make sure valid years are entered
    
        //CHECK FOR ACTIVE TOKEN, AND IF NOT, AUTOREFRESH TOKEN BEFORE PERFORMING THE SEARCH
        
        SpotifyYearSearcher.sharedInstance.searchYears(year1.text, year2: year2.text) { (success, error) in
            if success {
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.table.reloadData()
                })
            }
        }
    }
    
    
    func sortByPopularity() {
        
        //                    parsedTracks.sortInPlace({ (element1, element2) -> Bool in
        //                        return element1.trackPopularity > element2.trackPopularity
        //                    })
        //                    for track in parsedTracks {
        //                        print("\(track.artists.first?.name), \(track.track.name), \(track.trackPopularity)")
        //                    }
    
    }
    
    func showOnlyBetweenMonths() {
        
        //                parsedAlbums.sortInPlace({ (element1, element2) -> Bool in
        //                    guard let release1 = element1.releaseDate, let release2 = element2.releaseDate else {
        //                        return false
        //                    }
        //                    return release1.compare(release2) == .OrderedDescending
        //                })
        //
        //                for album in parsedAlbums {
        //                    if album.releaseDatePrecision == .Month || album.releaseDatePrecision == .Day {
        //                        print("\(album.album.name) \(album.albumPopularity) \(album.releaseDate)")
        //                    }
        //                }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = table.dequeueReusableCellWithIdentifier("YearSearchCell") as! YearSearchTableViewCell
        
        cell.textLabel?.text = SpotifyYearSearcher.sharedInstance.mostRecentTrackResults[indexPath.row].track.name
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SpotifyYearSearcher.sharedInstance.mostRecentTrackResults.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}