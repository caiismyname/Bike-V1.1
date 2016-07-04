//
//  ViewController.swift
//  Bike V1
//
//  Created by David Cai on 6/27/16.
//  Copyright © 2016 David Cai. All rights reserved.
//

import UIKit
import Firebase

var thisUser = userClass(firstName: "foo", lastName: "foo", userName: "foo", college: "fo", email: "foo", password: "foo", bike: nil)

class CreateAccountViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    
    @IBOutlet weak var createFirstName: UITextField!
    @IBOutlet weak var createLastName: UITextField!
    @IBOutlet weak var createCollege: UIPickerView!
    @IBOutlet weak var createEmail: UITextField!
    @IBOutlet weak var createPassword: UITextField!
    @IBOutlet weak var createButton: UIButton!
    
    
    var thisUser: userClass!
    let listOfColleges = [" ", "Don't Pick this one", "wrc", "Not this one"]
    var userCollege: String!
    
    override func viewDidLoad() {
        // Delegation
        createFirstName.delegate = self
        createLastName.delegate = self
        createCollege.delegate = self
        createCollege.dataSource = self
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
        return !((createFirstName.text?.isEmpty)! && (createLastName.text?.isEmpty)!)
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
        if textField == createFirstName {
            createFirstName.resignFirstResponder()
            createLastName.becomeFirstResponder()
        }
        else if textField == createLastName {
            createLastName.resignFirstResponder()
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
    
    // MARK: Picker Delegate and datasource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return listOfColleges.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return listOfColleges[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.userCollege = listOfColleges[row]
    }
    
    
    // MARK: Actions
    @IBAction func createAccount(sender: UIButton) {
        // It is important to note that anything that interacts with FB DB should probs use callbacks
        // b/c it takes (relatively) forever to connected and retrieve data, at which point
        // other funcs will have run and failed.
        
        // Resign, in case they are still FR
        createFirstName.resignFirstResponder()
        createLastName.resignFirstResponder()
        createCollege.resignFirstResponder()
        createEmail.resignFirstResponder()
        createPassword.resignFirstResponder()
        
        let createUserName = userCollege + createFirstName.text! + createLastName.text!
        
        // Create new userClass object
        thisUser = userClass.init(firstName: createFirstName.text!, lastName: createLastName.text!, userName: createUserName, college: self.userCollege, email: createEmail.text!, password: createPassword.text!, bike: nil)
        
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
                        self.pullBikeListData() { (bikes) in
                            // Callback for pullBikeListData, so everything's loaded when we go to the homepage
                            print("bike list pulled")
                            self.pullWorkoutsData() { (workouts) in
                                // Callback for pullWorkoutsData, so everything's loaded when we go to the homepage
                                print("workouts pulled")
                                self.createdDBEntries(self.thisUser) { (foo) in
                                    print("DB Entries created")
                                    self.performSegueWithIdentifier("unwindFromCreateAccountToHomepage", sender: self)
                                }
                            }
                        }
                    }
                }
            }
        
        }

    }
    
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let homepage = segue.destinationViewController as! HomepageViewController
        homepage.words.text = thisUser.firstName + thisUser.college

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
       let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(bikeListName, toFile: bikeClass.ArchiveURL.path!)
        if isSuccessfulSave {
            print("BikeList Saved")
        }
        else {
            print("Failed to save BikeList")
        }
    }
    
    func saveWorkoutList(workoutListName: [workoutClass]){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(workoutListName, toFile: workoutClass.ArchiveURL.path!)
        if isSuccessfulSave {
            print("WorkoutList Saved")
        }
        else {
            print("Failed to save WorkoutList")
        }
    }
    
    func loadBikeList() -> [bikeClass]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(bikeClass.ArchiveURL.path!) as? [bikeClass]
    }
    
    func loadWorkoutList() -> [workoutClass]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(workoutClass.ArchiveURL.path!) as? [workoutClass]
    }
    
    //MARK: Preperations for other views
    
    func createdDBEntries(user: userClass, completion: (foo: String) -> Void) {
        // Creating and setting the user in the DB in the /users/[username] and /colleges/[college]/users/[username]
        
        // Firebase Init
        var ref = FIRDatabaseReference.init()
        ref = FIRDatabase.database().reference()
        
        // username is the Dict. key for the user entries
        let username = user.userName
        // Full name is the human readable name of the person
        let fullname = user.firstName + " " + user.lastName
        
        // First DB entry, /users/[username]
        //
        //
        
        // Top-level User list
        let userRef = ref.child("users/\(username)")
        
        // Dict. representation of values in /users/[username] entry
        let userRefPayload = ["college": user.college, "email": user.email, "name": fullname, "bike":"None"]
        //  Uploads to FB DB | Setting the value of users/[username]
        userRef.setValue(userRefPayload) { (error: NSError?, database: FIRDatabaseReference) in
            if (error != nil) {
                print(error?.description)
            }
            else {
                print("users/username values set")
            }
        }

        
        // Second DB entry, /colleges/[college]/users/username/
        //
        //
        
        let collegeUserRef = ref.child("colleges/\(thisUser.college)/users/\(username)")
        
        collegeUserRef.setValue("true") { (error: NSError?, database: FIRDatabaseReference) in
            if (error != nil) {
                print(error?.description)
            }
            else {
                print("college/[college]/users/[username] value set")
            }
        }
        
        completion(foo: "FOO")

    }
    
    func pullBikeListData(completion: (listOfBikes: [bikeClass]) -> Void) {
        // This takes everything from bikeList in FB, makes them into bikeClass objects, and appends said objects to bikeList array
        
        // Firebase Init
        
        print("beginning pull of bikes")
        var ref = FIRDatabaseReference.init()
        ref = FIRDatabase.database().reference()
        let bikeListRef = ref.child("colleges/\(thisUser.college)/bikeList/")
        
        var tempBikeList = [bikeClass]()
        
        // Iterate through all children of bikeList (see prev. decleration of path)
        bikeListRef.observeEventType(.Value, withBlock: { snapshot in
            for child in snapshot.children {
                // Create bikeClass object from FB data
                let bikeName = child.value["name"] as! String
                let size = child.value["size"] as! String
                let riders = child.value["riders"] as! [String]
                let wheels = child.value["wheels"] as! String
                
                let childsnap = child as! FIRDataSnapshot
                let bikeUsername = childsnap.key
    
                
                let bikeObject = bikeClass(bikeName: bikeName, wheels: wheels, size: size, riders: riders, status: nil, bikeUsername: bikeUsername)
                tempBikeList.append(bikeObject)
                
                print(tempBikeList)
                // Save as you go, otherwise it'll just save an empty list b/c asycnchrony.
                self.saveBikeList(tempBikeList)
            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    
        completion(listOfBikes: tempBikeList)
    }
    
    func pullWorkoutsData(completion: (listOfWorkouts: [workoutClass]) -> Void) {
        
        // Firebase Init
        print("beginning workout pull")
        var ref = FIRDatabaseReference.init()
        ref = FIRDatabase.database().reference()
        let workoutRef = ref.child("colleges/\(thisUser.college)/workouts")
        
        var tempWorkoutList = [workoutClass]()
        
        // Iterate through all children of workoutList (see prev. decleration of path)
        workoutRef.observeEventType(.Value, withBlock: { snapshot in
            for child in snapshot.children {
                // Create workoutClass object from FB data
                let type = child.value["type"] as! String
                let unit = child.value["unit"] as! String
                let duration = child.value["duration"] as! [Int]
                let reps = child.value["reps"] as! [Int]
                let week = child.value["week"] as! [String]
                let usersHaveCompleted = child.value["usersHaveCompleted"] as! [String]
                
                print(type)
                
                let workoutObject = workoutClass(type: type, duration: duration, reps: reps, unit: unit, usersHaveCompleted: usersHaveCompleted, week: week)
                tempWorkoutList.append(workoutObject)
                
                print(tempWorkoutList)
                
                // Save as you go, otherwise it'll just save an empty list b/c asycnchrony.
                self.saveWorkoutList(tempWorkoutList)
                print(self.loadWorkoutList())
            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        

        completion(listOfWorkouts: tempWorkoutList)
        
    }

}
