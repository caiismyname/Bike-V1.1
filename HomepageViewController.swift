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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
    
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
                OneSignal.defaultClient().postNotification(["contents": ["en": "\(thisUser.firstName) \(thisUser.lastName) is going on a ride!"], "include_player_ids": listOfUserIds])
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
                teammateList.append(memberSnap.key as! String)
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


    
    
    // MARK: Navigation
    @IBAction func unwindToHomepage(segue: UIStoryboardSegue) {}
    
    // MARK: NSCoding
    func hasAccount() -> Bool {
        // is seperate from loadUser b/c of return values.
        if let user = NSKeyedUnarchiver.unarchiveObjectWithFile(userClass.ArchiveURL.path!) as? userClass {
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
