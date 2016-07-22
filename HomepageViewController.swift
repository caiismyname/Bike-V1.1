//
//  HomepageViewController.swift
//  Bike V1
//
//  Created by David Cai on 6/27/16.
//  Copyright © 2016 David Cai. All rights reserved.
//

import UIKit
import Firebase

class HomepageViewController: UIViewController {

    var ref = FIRDatabaseReference.init()
    
    
    //MARK: Properties
    @IBOutlet weak var words: UILabel!
    @IBOutlet weak var collegeLabel: UILabel!
    
    @IBOutlet weak var bikesButton: UIButton!
    @IBOutlet weak var workoutButton: UIButton!
    @IBOutlet weak var goRideButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        
        // Adjusts font size of long text on Homepage for smaller screens
        workoutButton.titleLabel?.adjustsFontSizeToFitWidth = true
        words.adjustsFontSizeToFitWidth = true
        
    
        if hasAccount() {
            loadUser()
            self.words.text = thisUser.firstName + " " + thisUser.lastName
            self.collegeLabel.text = thisUser.college
        }
        else {
            performSegueWithIdentifier("toCreateAccount", sender: self)
        }
    }
    
    // MARK: Actions
    @IBAction func goRideButton(sender: UIButton) {
        getTeammates { (listOfTeammates) in
            self.getUserIds(listOfTeammates, completion: { (listOfUserIds) in
                
                // Change user's bike status to "In Use", alert them if the bike is currently "In use" or "unusable"
                let userBikeUsername = thisUser.bike
                print(userBikeUsername)
                if userBikeUsername != "None" {
                    let bikeRef = self.ref.child("colleges/\(thisUser.college)/bikeList/\(userBikeUsername)/status")
                    bikeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                        let bikeStatus = snapshot.value! as! String
                        
                        if bikeStatus == "Ready" {
                            let bikeStatusRef = self.ref.child("colleges/\(thisUser.college)/bikeList/\(userBikeUsername)/status")
                            bikeStatusRef.setValue("In Use")
                            
                            // Send out notification
                            OneSignal.defaultClient().postNotification(["contents": ["en": "\(thisUser.firstName) \(thisUser.lastName) is going on a ride!"], "include_player_ids": listOfUserIds])
                            
                            // Let the user know their notification has been sent out
                            let goRideSentAlert = UIAlertController(title: "Team Notified", message: "Your team now knows you're going on a ride!", preferredStyle: UIAlertControllerStyle.Alert)
                            goRideSentAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                            self.presentViewController(goRideSentAlert, animated: true, completion: nil)
                            
                            // Resets the bike to "ready" after an hour
                            // Code only gets called here b/c other two situations would not reset to "Ready"
                            self.runAfterDelay(3600, block: {
                                if let userBike = thisUser?.bike {
                                    let bikeRef = self.ref.child("colleges/\(thisUser.college)/bikeList/\(userBike)/status")
                                    bikeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                                        bikeRef.setValue("Ready")
                                    })
                                }
                            })
                        }
                        else if bikeStatus == "In Use" {
                            let bikeInUseAlert = UIAlertController(title: "Your bike is in use", message: "Your bike is currently being used! You'll have to find another.", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            bikeInUseAlert.addAction(UIAlertAction(title: "Continue", style: .Default, handler: { alertAction in
                                OneSignal.defaultClient().postNotification(["contents": ["en": "\(thisUser.firstName) \(thisUser.lastName) is going on a ride!"], "include_player_ids": listOfUserIds])
                                
                                // Let the user know their notification has been sent out
                                let goRideSentAlert = UIAlertController(title: "Team Notified", message: "Your team now knows you're going on a ride!", preferredStyle: UIAlertControllerStyle.Alert)
                                goRideSentAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                                self.presentViewController(goRideSentAlert, animated: true, completion: nil)
                            }))
                            bikeInUseAlert.addAction(UIAlertAction(title: "Cancel Ride", style: .Cancel, handler: nil))
                            self.presentViewController(bikeInUseAlert, animated: true, completion: nil)
                            
                        }
                        else if bikeStatus == "Unusable" {
                            let bikeUnusableAlert = UIAlertController(title: "Your bike is unusable!", message: "Your bike is currently unusable! You'll have to find another.", preferredStyle: UIAlertControllerStyle.Alert)
                            bikeUnusableAlert.addAction(UIAlertAction(title: "Continue", style: .Default, handler: { alertAction in
                                OneSignal.defaultClient().postNotification(["contents": ["en": "\(thisUser.firstName) \(thisUser.lastName) is going on a ride!"], "include_player_ids": listOfUserIds])
                                
                                // Let the user know their notification has been sent out
                                let goRideSentAlert = UIAlertController(title: "Team Notified", message: "Your team now knows you're going on a ride!", preferredStyle: UIAlertControllerStyle.Alert)
                                goRideSentAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                                self.presentViewController(goRideSentAlert, animated: true, completion: nil)
                            }))
                            bikeUnusableAlert.addAction(UIAlertAction(title: "Cancel Ride", style: .Cancel, handler: nil))
                            self.presentViewController(bikeUnusableAlert, animated: true, completion: nil)
                        }

                    })
                }
                else {
                    let noBikeAlert = UIAlertController(title: "You don't have a bike!", message: "Set a bike as your own from the Bike List", preferredStyle: UIAlertControllerStyle.Alert)
                    noBikeAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                    self.presentViewController(noBikeAlert, animated: true, completion: nil)
                }
            })
        }
    }
    
    func getTeammates(completion: (listOfTeammates: [String]) -> Void) {
        // Find all members of a team (college)
        
        var teammateList = [String]()
        let teammatesRef = ref.child("colleges/\(thisUser.college)/users")
        
        teammatesRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            for member in snapshot.children {
                let memberSnap = member as! FIRDataSnapshot
                if memberSnap.key as! String != thisUser.userName {
                    teammateList.append(memberSnap.key as! String)
                }
            }
            completion(listOfTeammates: teammateList)
        })
        
    }
    
    func getUserIds(listOfTeammates: [String], completion: (listOfUserIds: [String]) -> Void) {
        // Gets oneSignalUserId's from a list of usernames
        
        var userIdList = [String]()
        
        // B/c callbacks are annoying. With this index thing,
        // The completion handler only gets called when we have the same number of entries
        // in the userIdList as we do teammates, ensuring it's correctness in time of callback.
        
        var index = 0
        let maxIndex = listOfTeammates.count
        
        for teammate in listOfTeammates {
            let userRef = self.ref.child("users/\(teammate)")

            userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                let userId = snapshot.value!["oneSignalUserId"] as! String
                userIdList.append(userId)
                index += 1
                if index == maxIndex {
                    completion(listOfUserIds: userIdList)
                }
            })
        }
    }
    
    // Function that executes a block after time interval, even when app is in background
    func runAfterDelay(delay: NSTimeInterval, block: dispatch_block_t) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue(), block)
    }
    
    
    // MARK: Navigation
    @IBAction func unwindToHomepage(segue: UIStoryboardSegue) {}
    
    // MARK: NSCoding
    func hasAccount() -> Bool {
        // is seperate from loadUser b/c of return values.
        if (NSKeyedUnarchiver.unarchiveObjectWithFile(userClass.ArchiveURL.path!) as? userClass) != nil {
            return true
        }
        else {
            return false
        }
    }
    
    func loadUser(){
        let loadedUser = (NSKeyedUnarchiver.unarchiveObjectWithFile(userClass.ArchiveURL.path!) as? userClass)!
        thisUser = loadedUser
        print("homepage load user")
        print(thisUser.firstName)
    }
    
    func loadBikeList() -> [bikeClass]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(bikeClass.ArchiveURL.path!) as? [bikeClass]
    }
    
    
    
}
