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
    
    let ref = FIRDatabase.database().reference()
    
    // MARK: Properties
    var thisBike: bikeClass?
    
    // Variable visuals
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var ridersLabel: UILabel!
    @IBOutlet weak var bikeImageView: UIImageView!
    
    // Static visuals
    @IBOutlet weak var staticSizeLabel: UILabel!
    @IBOutlet weak var staticStatusLabel: UILabel!
    @IBOutlet weak var staticRidersLabel: UILabel!
    @IBOutlet weak var staticModelLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("User has selected: \(thisBike!.bikeUsername)")
        
        let bikeRef = ref.child("colleges/\(thisUser.college)/bikeList/\(thisBike!.bikeUsername)")
        // Listener is used to live update the info as the user manipulates the information from the detailview
        bikeRef.observeEventType(.Value, withBlock: { snapshot in
            // Creating bikeClass object from FB DB data
            let bikeShortName = snapshot.value!["shortName"] as! String
            let bikeFullName = snapshot.value!["fullName"] as! String
            let size = snapshot.value!["size"] as! String
            let status = snapshot.value!["status"] as! String
            let bikeUsername = snapshot.key
            
            var riders = [String:String]()
            
            let riderDict = snapshot.value!["riders"] as! NSDictionary
            for rider in riderDict {
                if rider.key as! String != "init" {
                    riders[rider.key as! String] = rider.value as! String
                }
            }
            
            let bikeObject = bikeClass(bikeShortName: bikeShortName, bikeFullName: bikeFullName, size: size, riders: riders, status: status, bikeUsername: bikeUsername)
            self.thisBike = bikeObject
            self.updateRiderList()
            
        })
        
        // Setting titles
        self.title = thisBike?.bikeShortName
        sizeLabel.text = thisBike?.size
        statusButton.setTitle(thisBike?.status, forState: .Normal)
        modelLabel.text = thisBike?.bikeFullName
        
        // Setting appropriate color for status label/button
        if thisBike?.status == "Ready" {
            statusButton.setTitleColor(UIColor.init(red: CGFloat(0), green: CGFloat(128.0/255.0), blue: CGFloat(0), alpha: CGFloat(1)), forState: .Normal)
        }
        else if thisBike?.status == "In Use" {
            statusButton.setTitleColor(UIColor.orangeColor(), forState: .Normal)
        }
        else if thisBike?.status == "Unusable" {
            statusButton.setTitleColor(UIColor.init(red: CGFloat(200.0/255.0), green: CGFloat(0), blue: CGFloat(0), alpha: CGFloat(1)), forState: .Normal)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        ref.removeAllObservers()
    }
    
    // MARK: Actions
    
    @IBAction func doneButton(sender: UIBarButtonItem) {
        performSegueWithIdentifier("unwindFromBikeDetailViewToBikelist", sender: self)
    }
    
    @IBAction func setBikeButton(sender: UIBarButtonItem) {
        // Updating the bike's list of riders
        let bikeRef = ref.child("colleges/\(thisUser.college)/bikeList/\(thisBike!.bikeUsername)/riders")
        
        bikeRef.updateChildValues([thisUser.userName : thisUser.fullName])
        
        // Removing user from other bikes
        let bikeListRef = ref.child("colleges/\(thisUser.college)/bikeList")
        
        bikeListRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            // Iterating through the bikes
            for child in snapshot.children {
                // To grab bike's username for removing riders
                let childSnap = child as! FIRDataSnapshot
                let bikeName = childSnap.key
                
                // if-statement to ensure you don't remove yourself from the bike you just added to
                if bikeName != self.thisBike!.bikeUsername {
                    // The following line will remove the user if it exists -- nothing will happen if the user does not exist
                    bikeListRef.child("/\(bikeName)/riders/\(thisUser.userName)").removeValue()
                }
            }
        })
        
        // Updating the user's data
        let userRef = ref.child("users/\(thisUser.userName)/bike")
        userRef.setValue(thisBike?.bikeUsername)
        
        thisUser.bike = thisBike?.bikeUsername
        self.saveUser()
        
    }
    
    @IBAction func statusButtonToggle(sender: UIButton) {
        var newStatus: String?
        if thisBike?.status == "Ready"{
            newStatus = "In Use"
            statusButton.setTitleColor(UIColor.orangeColor(), forState: .Normal)
        }
        else if thisBike?.status == "In Use" {
            newStatus = "Unusable"
            statusButton.setTitleColor(UIColor.init(red: CGFloat(200.0/255.0), green: CGFloat(0), blue: CGFloat(0), alpha: CGFloat(1)), forState: .Normal)
        }
        else if thisBike?.status == "Unusable" {
            newStatus = "Ready"
            statusButton.setTitleColor(UIColor.init(red: CGFloat(0), green: CGFloat(128.0/255.0), blue: CGFloat(0), alpha: CGFloat(1)), forState: .Normal)
        }
        
        statusButton.setTitle(newStatus, forState: .Normal)
        let statusRef = ref.child("colleges/\(thisUser.college)/bikeList/\(thisBike?.bikeUsername as String!)/status")
        statusRef.setValue(newStatus)
        
    }
    
    
    // MARK: Misc funcs
    func updateRiderList() {
        // Turning usernames into actual names
        ridersLabel.text = thisBike?.getRidersPayload()
        
    }
    
    //MARK: NSCoding
    func saveUser() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(thisUser, toFile: userClass.ArchiveURL!.path!)
        if isSuccessfulSave {
            print("User saved")
        }
        else {
            print("Failed to save user")
        }
    }
}
