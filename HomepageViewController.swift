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
    
    @IBOutlet weak var annoucementsButton: UIButton!
    @IBOutlet weak var bikesButton: UIButton!
    @IBOutlet weak var workoutButton: UIButton!
    @IBOutlet weak var goRideButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("homepage viewdidload")
        ref = FIRDatabase.database().reference()
        
        // Adjusts font size of long text on Homepage for smaller screens
        workoutButton.titleLabel?.adjustsFontSizeToFitWidth = true
        words.adjustsFontSizeToFitWidth = true
        annoucementsButton.titleLabel?.adjustsFontSizeToFitWidth = true
    
        if hasAccount() {
            loadUser()
            self.words.text = thisUser.firstName + " " + thisUser.lastName
            self.collegeLabel.text = thisUser.college
        }
        else {
            performSegueWithIdentifier("toCreateAccount", sender: self)
        }
    }

    
    // MARK: Navigation
    @IBAction func unwindToHomepage(segue: UIStoryboardSegue) {}
    
    // MARK: NSCoding
    func hasAccount() -> Bool {
        // is seperate from loadUser b/c of return values.
        if (NSKeyedUnarchiver.unarchiveObjectWithFile(userClass.ArchiveURL!.path!) as? userClass) != nil {
            return true
        }
        else {
            return false
        }
    }
    
    func loadUser(){
        let loadedUser = (NSKeyedUnarchiver.unarchiveObjectWithFile(userClass.ArchiveURL!.path!) as? userClass)!
        thisUser = loadedUser
        print("homepage load user")
        print(thisUser.firstName)
    }
    
    func loadBikeList() -> [bikeClass]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(bikeClass.ArchiveURL!.path!) as? [bikeClass]
    }
    
    func loadWorkoutList() -> [workoutClass]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(workoutClass.ArchiveURL!.path!) as? [workoutClass]
    }
    
}
