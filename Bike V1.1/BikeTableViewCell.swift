//
//  BikeTableViewCell.swift
//  Bike V1.1
//
//  Created by David Cai on 6/29/16.
//  Copyright © 2016 David Cai. All rights reserved.
//

import UIKit

class BikeTableViewCell: UITableViewCell {
    // MARK: Properties
    
    @IBOutlet weak var bikeNameDisplay: UILabel!
    @IBOutlet weak var wheelInfoDisplay: UILabel!
    @IBOutlet weak var sizeInfoDisplay: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
