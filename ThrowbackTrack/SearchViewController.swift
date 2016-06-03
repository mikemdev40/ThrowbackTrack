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
            table.rowHeight = UITableViewAutomaticDimension
            table.estimatedRowHeight = 60
        }
    }
    
    var sectionAfterLastResultsSection: Int {
        return SpotifyYearSearcher.sharedInstance.mostRecentTrackResults.count
    }
    
    var gettingNextTracks = false
    let formatter = NSDateFormatter()
    
    @IBAction func selectSegment(sender: UISegmentedControl) {
        
    }
    
    @IBAction func search(sender: UIButton) {
    
        //check to make sure valid years are entered
    
        //CHECK FOR ACTIVE TOKEN, AND IF NOT, AUTOREFRESH TOKEN BEFORE PERFORMING THE SEARCH
        SpotifyYearSearcher.sharedInstance.mostRecentTrackResults.removeAll()
        table.reloadData()
        
        SpotifyYearSearcher.sharedInstance.searchYears(year1.text, year2: year2.text) { (success, error) in
            if success {
                
                dispatch_async(dispatch_get_main_queue(), {
                    print("5. \(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))")

                    self.table.reloadData()
                })
            }
        }
    }
    
    
    func sortByPopularity() {
        
//        parsedTracks.sortInPlace({ (element1, element2) -> Bool in
//            return element1.trackPopularity > element2.trackPopularity
//        })
//        for track in parsedTracks {
//            print("\(track.artists.first?.name), \(track.track.name), \(track.trackPopularity)")
//        }
    
    }
    
    func showOnlyBetweenMonths() {
        
//        parsedAlbums.sortInPlace({ (element1, element2) -> Bool in
//            guard let release1 = element1.releaseDate, let release2 = element2.releaseDate else {
//                return false
//            }
//            return release1.compare(release2) == .OrderedDescending
//        })
//
//        for album in parsedAlbums {
//            if album.releaseDatePrecision == .Month || album.releaseDatePrecision == .Day {
//                print("\(album.album.name) \(album.albumPopularity) \(album.releaseDate)")
//            }
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        if indexPath.section == sectionAfterLastResultsSection {
            cell = table.dequeueReusableCellWithIdentifier("SpinnerViewCell") as! SpinnerTableViewCell
            (cell as? SpinnerTableViewCell)?.spinner.startAnimating()
        } else {
            let yearCell = table.dequeueReusableCellWithIdentifier("YearSearchCell") as! YearSearchTableViewCell
            
            let track = SpotifyYearSearcher.sharedInstance.mostRecentTrackResults[indexPath.section][indexPath.row]
            
            yearCell.titleLabel.text = track.track.name
            yearCell.artistLabel.text = track.artists[0].name
            
            if let releaseDate = track.albumObject?.releaseDate, let precision = track.albumObject?.releaseDatePrecision {
                switch precision {
                case  .Day:
                    formatter.dateFormat = "yyyy-MM-dd"
                case .Month:
                    formatter.dateFormat = "yyyy-MM"
                case .Year:
                    formatter.dateFormat = "yyyy"
                }
                yearCell.releaseDate.text = formatter.stringFromDate(releaseDate)
            } else {
                yearCell.releaseDate.text = "Unknown"
            }
    
            let popularity = track.trackPopularity
            yearCell.popularityLabel.text = "\(popularity)"
            
            yearCell.albumLabel.text = track.album.name
            
            let previewURL = SpotifyYearSearcher.sharedInstance.mostRecentTrackResults[indexPath.section][indexPath.row].previewURL
            yearCell.previewURL = previewURL
            
            cell = yearCell
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == sectionAfterLastResultsSection {
            return 1
        } else {
            return SpotifyYearSearcher.sharedInstance.mostRecentTrackResults[section].count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if sectionAfterLastResultsSection == 0 {
            return 0
        } else {
            return sectionAfterLastResultsSection + 1
        }
    }

    
    //reminder that tableviews are subclasses of scrollviews, and the UITableViewDelegate protocol conforms to UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let frameHeight = scrollView.frame.height
        let contentSizeHeight = scrollView.contentSize.height
        let contentOffset = scrollView.contentOffset.y
        
      //  print("\(frameHeight) \(contentSizeHeight) \(contentOffset)")
        
        if frameHeight + contentOffset + Constants.YearSearchConstants.HeightOfSpinnerCell >= contentSizeHeight {
       //     print("arrived at spinner")
            
            if !gettingNextTracks {
                print("------ GETTING SONGS -----")
                gettingNextTracks = true
                SpotifyYearSearcher.sharedInstance.getNextTracks { (success, error) in
                    if success {
                        dispatch_async(dispatch_get_main_queue(), {
                            print("6. \(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))")

                            self.table.reloadData()
                            self.gettingNextTracks = false
                            print("---- DONE DONE DONE DONE ----")
                        })
                    }
                }
            }
            
        }
    }
}