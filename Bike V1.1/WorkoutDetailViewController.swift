//
//  WorkoutDetailViewController.swift
//  Bike V1.1
//
//  Created by David Cai on 7/18/16.
//  Copyright © 2016 David Cai. All rights reserved.
//

import UIKit
import Firebase

class WorkoutDetailViewController: UIViewController {
    
    var ref = FIRDatabaseReference.init()
    
    var thisWorkout: workoutClass?
    // MARK: Properties
    
    @IBOutlet weak var infoStack: UIStackView!
    
    @IBOutlet weak var weekNumberLabel: UILabel!
    @IBOutlet weak var weekDateLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var payloadLabel: UILabel!
    @IBOutlet weak var usersHaveCompletedLabel: UILabel!
    @IBOutlet weak var completionButtonLabel: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("detail viewdidlaod")
        
        ref = FIRDatabase.database().reference()
        
        // Setting the top-right button label
        
        print(thisWorkout?.usersHaveCompleted.keys.contains(thisUser.userName))
        if ((thisWorkout?.usersHaveCompleted.keys.contains(thisUser.userName)) == true) {
            completionButtonLabel.title = "Incomplete"
        }
        else {
            completionButtonLabel.title = "Complete"
        }
 
        
        // Setting text labels
        self.title = thisWorkout?.type
        
        let weekNumber = "\(thisWorkout!.week[0])"
        let weekDate = "\(thisWorkout!.week[1])"
        
        weekDateLabel.text = weekDate
        weekNumberLabel.text = weekNumber
        typeLabel.text = thisWorkout?.type
        payloadLabel.text = thisWorkout?.getPayload()
        updateUserList()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    @IBAction func completionButton(sender: UIBarButtonItem) {
        // Conditional logic to remove/add user to workout lists based on current state
        // Side Note: the userList is updated via the event listener declared in viewDidLoad
        
        if ((thisWorkout?.usersHaveCompleted.keys.contains(thisUser.userName)) == true) {
            // If this workout has already been completed
            let workoutRef = self.ref.child("colleges/\(thisUser.college)/workouts/\(thisWorkout!.workoutUsername)/usersHaveCompleted/\(thisUser.userName)")
            // Update the workout's usersHaveCompleted List in FB
            workoutRef.removeValue()
            
            // Update the user's completedwo List in FB
            let userRef = self.ref.child("users/\(thisUser.userName)/completedwo/\(thisWorkout!.workoutUsername)")
            userRef.removeValue()
            
            completionButtonLabel.title = "Complete"
            
        }
        else {
            // This workout has not been completed
            // Update the workout's usersHaveCompleted List in FB
            let workoutRef = self.ref.child("colleges/\(thisUser.college)/workouts/\(thisWorkout!.workoutUsername)/usersHaveCompleted")
            workoutRef.updateChildValues([thisUser.userName: thisUser.fullName])
            
            // Update the user's completedwo List in FB
            let userRef = self.ref.child("users/\(thisUser.userName)/completedwo")
            userRef.updateChildValues([thisWorkout!.workoutUsername: true])
            
            completionButtonLabel.title = "Incomplete"
        }
        
        startWorkoutListener()
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        ref.removeAllObservers()
    }
    
    // MISC: Funcs
    
    func startWorkoutListener() {
        // Listener for this workout only -- to update data if completion status is changed
        let workoutRef = ref.child("colleges/\(thisUser.college)/workouts/\(thisWorkout!.workoutUsername)")
        workoutRef.observeEventType(.Value, withBlock: { snapshot in
            // Create workoutClass object from FB data
            let type = snapshot.value!["type"] as! String
            let unit = snapshot.value!["unit"] as! String
            let duration = snapshot.value!["duration"] as! [Int]
            let reps = snapshot.value!["reps"] as! [Int]
            let week = snapshot.value!["week"] as! [String]
            
            let workoutUsername = snapshot.key
            
            var usersHaveCompleted = [String:String]()
            let usersHaveCompletedDict = snapshot.value!["usersHaveCompleted"] as! NSDictionary
            for user in usersHaveCompletedDict {
                if user.key as! String != "init" {
                    usersHaveCompleted[user.key as! String] = (user.value as! String)
                }
            }
            
            let workoutObject = workoutClass(type: type, duration: duration, reps: reps, unit: unit, usersHaveCompleted: usersHaveCompleted, week: week, workoutUsername: workoutUsername)
            self.thisWorkout = workoutObject
            
            // This call is placed here so that the userList will be updated *after* the database is updated.
            self.updateUserList()
        })
    }
    
    func updateUserList() {
        print("updateUserLIst")
        // Refreshes the local usersHaveCompleted  then updates the label
        usersHaveCompletedLabel.text = thisWorkout?.getUsersHaveCompleted()
        
        
    }

}
