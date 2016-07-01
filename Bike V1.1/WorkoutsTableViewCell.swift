//
//  WorkoutsTableViewCell.swift
//  Bike V1.1
//
//  Created by David Cai on 7/1/16.
//  Copyright © 2016 David Cai. All rights reserved.
//

import UIKit

class WorkoutsTableViewCell: UITableViewCell {
    // MARK: Properties
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var payloadLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
