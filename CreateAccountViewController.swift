//
//  ViewController.swift
//  Bike V1
//
//  Created by David Cai on 6/27/16.
//  Copyright © 2016 David Cai. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var createName: UITextField!
    @IBOutlet weak var createEmail: UITextField!
    @IBOutlet weak var createPassword: UITextField!
    @IBOutlet weak var createButton: UIButton!

    var thisUser: userClass!
    
    override func viewDidLoad() {
        createName.delegate = self
        createEmail.delegate = self
        createPassword.delegate = self
        createButton.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    // MARK: UITextfield Delegate
    func isNameValid() -> Bool {
        // true if not empty, false if empty
        return !(createName.text?.isEmpty)!
    }
    
    func isEmailValid() -> Bool {
        // checks for emptiness, then if @ and . are in the email string
        if !(createEmail.text?.isEmpty)! {
            let at = createEmail.text!.rangeOfString("@")
            let dot = createEmail.text!.rangeOfString(".")
            if at != nil && dot != nil {
                return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
    
    func isPasswordValid() -> Bool {
        // true if not empty, false if empty
        return !(createPassword.text?.isEmpty)!
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        // Once user finishes enter data, if data is valid, then we'll let them create the account
        createButton.enabled = isNameValid() && isEmailValid() && isPasswordValid()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Moves user along through the textFields
        
        createButton.enabled = isNameValid() && isEmailValid() && isPasswordValid()
        if textField == createName {
            createName.resignFirstResponder()
            createEmail.becomeFirstResponder()
        }
        else if textField == createEmail {
            createEmail.resignFirstResponder()
            createPassword.becomeFirstResponder()
        }
        else {
            createPassword.resignFirstResponder()
        }
        
        // b/c it returns a Bool. Not sure why this is here tbh
        return true
    }
    
    
    
    // MARK: Actions
    @IBAction func createAccount(sender: UIButton) {
        // It is important to note that anything that interacts with FB DB should probs use callbacks
        // b/c it takes (relatively) forever to connected and retrieve data, at which point
        // other funcs will have run and failed.
        
        // Resign, in case they are still FR
        createName.resignFirstResponder()
        createEmail.resignFirstResponder()
        createPassword.resignFirstResponder()
        
        // Create new userClass object
        thisUser = userClass.init(name: createName.text!, email: createEmail.text!, password: createPassword.text!, bike: nil)
        
        saveUser()
        
        // Create account on Firebase
        FIRAuth.auth()?.createUserWithEmail(createEmail.text!, password: createPassword.text!) { (user, error) in
            // Callback for creating account
            if let error = error {
                print(error.localizedDescription)
                return
            }
            else {
                // Note that user now has account
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "launchedBefore")
                
                // Sign user in, then pull bikeList array from FB DB
                FIRAuth.auth()?.signInWithEmail(self.thisUser.email, password: self.thisUser.password) { (user, error) in
                    // Callback for signing in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    else {
                        print("User signed in")
                        self.pullData() { (bikes) in
                            // Callback for pullData, so everything's loaded when we go to the homepage
                            // To homescreen!
                            self.performSegueWithIdentifier("unwindFromCreateAccountToHomepage", sender: self)
                        }
                    }
                }
            }
        
        }

    }
    
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let homepage = segue.destinationViewController as! HomepageViewController
        homepage.user = thisUser
    }
    
    
    // MARK: NSCoding
    func saveUser() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(thisUser, toFile: userClass.ArchiveURL.path!)
        if isSuccessfulSave {
            print("User saved")
        }
        else {
            print("Failed to save user")
        }
    }
    
    func saveBikeList(bikeListName: [bikeClass]){
        NSKeyedArchiver.archiveRootObject(bikeListName, toFile: bikeClass.ArchiveURL.path!)
    }
    
    //MARK: Preperations for other views
    
    func pullData(completion: (listOfBikes: [bikeClass]) -> Void) {
        // This takes everything from bikeList in FB, makes them into bikeClass objects, and appends said objects to bikeList array
        
        // Firebase Init
        var ref = FIRDatabaseReference.init()
        ref = FIRDatabase.database().reference()
        let bikeListRef = ref.child("bikeList")
        
        var tempBikeList = [bikeClass]()
        
        // Iterate through all children of bikeList (see prev. decleration of path)
        bikeListRef.observeEventType(.Value, withBlock: { snapshot in
            for child in snapshot.children {
                // Create bikeClass object from FB data
                let bikeName = child.value["name"] as! String
                let size = child.value["size"] as! String
                let wheels = child.value["wheels"] as! String
                
                let bikeObject = bikeClass(bikeName: bikeName, wheels: wheels, size: size, status: nil)
                tempBikeList.append(bikeObject)
                
                // Save as you go, otherwise it'll just save an empty list b/c asycnchrony.
                self.saveBikeList(tempBikeList)
                print("saved")
            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        completion(listOfBikes: tempBikeList)
    }

}
