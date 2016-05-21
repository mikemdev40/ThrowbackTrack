//
//  SpinnerTableViewCell.swift
//  ThrowbackTrack
//
//  Created by Michael Miller on 5/21/16.
//  Copyright © 2016 MikeMiller. All rights reserved.
//

import UIKit

class SpinnerTableViewCell: UITableViewCell {

    @IBOutlet weak var spinner: UIActivityIndicatorView! {
        didSet {
            spinner.hidesWhenStopped = true
        }
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
