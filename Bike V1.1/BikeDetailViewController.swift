//
//  BikeDetailViewController.swift
//  Bike V1.1
//
//  Created by David Cai on 7/3/16.
//  Copyright © 2016 David Cai. All rights reserved.
//

import UIKit

class BikeDetailViewController: UIViewController {
    // MARK: Properties
    var thisBike: bikeClass?
    
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var wheelsLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var ridersLabel: UILabel!
    @IBOutlet weak var bikeImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = thisBike?.bikeName
        sizeLabel.text = thisBike?.size
        wheelsLabel.text = thisBike?.wheels
        statusLabel.text = thisBike?.status
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Actions
    
    @IBAction func doneButton(sender: UIBarButtonItem) {
        performSegueWithIdentifier("unwindFromBikeDetailViewToBikelist", sender: self)
    }

}
