//
//  announcementsTableViewCell.swift
//  Bike iOS
//
//  Created by David Cai on 8/25/16.
//  Copyright © 2016 David Cai. All rights reserved.
//

import UIKit

class announcementsTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var payloadLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
