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
    
    //MARK: Properties
    @IBOutlet weak var words: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if hasAccount() {
            loadUser()
            self.words.text = thisUser.firstName + " " + thisUser.lastName
        }
        else {
            performSegueWithIdentifier("toCreateAccount", sender: self)
        }
    }
    
    // MARK: Actions
    @IBAction func signIn(sender: UIButton) {
        //FIRAuth.auth()?.signInWithEmail(thisUser.email, password: thisUser.password, completion: nil)
        print(thisUser.firstName)
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
