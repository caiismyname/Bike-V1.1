//
//  BikeDetailViewController.swift
//  Bike V1.1
//
//  Created by David Cai on 7/3/16.
//  Copyright © 2016 David Cai. All rights reserved.
//

import UIKit
import Firebase

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
        print("User has selected: \(thisBike!.bikeUsername)")
        
        self.title = thisBike?.bikeName
        sizeLabel.text = thisBike?.size
        wheelsLabel.text = thisBike?.wheels
        statusLabel.text = thisBike?.status
        
        // FB is needed to get the *actual* names of the riders b/c the user dict is not stored locally
        var ref = FIRDatabaseReference.init()
        ref = FIRDatabase.database().reference()
        
        var riderList = String()
        
        for rider in thisBike!.riders! {
            if rider != "init" {
                let riderRef = ref.child("users/\(rider)")
                riderRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                    let actualName = snapshot.value!["name"] as! String
                    riderList += "\(actualName), "
                    
                    // Yeah this is bad, but a callback would be so much messier
                    self.ridersLabel.text = riderList
                })
            }
        }
        
        
        
        
        
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
    
    @IBAction func setBikeButton(sender: UIBarButtonItem) {
        // Updating the bike's list of riders
        var ref = FIRDatabaseReference.init()
        ref = FIRDatabase.database().reference()
        let bikeRef = ref.child("colleges/\(thisUser.college)/bikeList/\(thisBike!.bikeUsername)/riders")
        
        let index = thisBike?.riders?.count
        bikeRef.updateChildValues(["\(index!)": thisUser.userName])
        
        // Removing user from other bikes
        let bikeListRef = ref.child("colleges/\(thisUser.college)/bikeList")
        
        bikeListRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            // Iterating through the bikes
            for child in snapshot.children {
                // To grab bike's username for removing riders
                let childSnap = child as! FIRDataSnapshot
                let bikeName = childSnap.key
                print("bikeusername")
                print(bikeName)
                
                // Iterating through the riders of the bike
                let riders = child.value["riders"] as! [String]
                // In FB, lists are stored as dicts with the index as the key, so the removal REF must use that index
                var index = 0
                
                for rider in riders {
                    if thisUser.userName == rider && bikeName != self.thisBike!.bikeUsername {
                        let indexString = String(index)
                        let removedUserRef = bikeListRef.child("/\(bikeName)/riders/\(indexString)")
                        removedUserRef.removeValue()
                    }
                    index += 1
                }
            }
        })
        
        
        
        // Updating the user's data
        let userRef = ref.child("users/\(thisUser.userName)/bike")
        userRef.setValue(thisBike?.bikeUsername)
        
    }
    

}
