//
//  YearSearchTableViewCell.swift
//  ThrowbackTrack
//
//  Created by Michael Miller on 5/19/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import UIKit

class YearSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    
    @IBOutlet weak var previewButton: UIButton!
    
    var previewURL: String?
    
    @IBAction func playPreview(sender: UIButton) {
    
    
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
