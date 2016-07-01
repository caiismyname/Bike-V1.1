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
    var user: userClass!
    @IBOutlet weak var words: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if hasAccount() {
            loadUser()
            words.text = user.name
        }
        else {
            performSegueWithIdentifier("toCreateAccount", sender: self)
        }  
    }
    
    // MARK: Actions
    @IBAction func signIn(sender: UIButton) {
        FIRAuth.auth()?.signInWithEmail(user.email, password: user.password, completion: nil)
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
        self.user = loadedUser
    }
    
}
