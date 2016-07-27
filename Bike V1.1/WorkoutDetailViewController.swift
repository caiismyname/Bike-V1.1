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
        ref = FIRDatabase.database().reference()

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
            
            var usersHaveCompleted = [String]()
            let usersCompletedSnap = snapshot.value!["usersHaveCompleted"] as! NSDictionary
            for person in usersCompletedSnap {
                if person.key as! String != "init" {
                    usersHaveCompleted.append(person.key as! String)
                }
            }
            
            let workoutObject = workoutClass(type: type, duration: duration, reps: reps, unit: unit, usersHaveCompleted: usersHaveCompleted, week: week, workoutUsername: workoutUsername)
            self.thisWorkout = workoutObject
            
            // This call is placed here so that the userList will be updated *after* the database is updated.
            self.updateUserList()
        })
        
        
        // Setting the top-right button label
        if ((thisWorkout?.usersHaveCompleted.contains(thisUser.userName)) == true) {
            completionButtonLabel.title = "Incomplete"
        }
        else {
            completionButtonLabel.title = "Complete"
        }
        
        // Setting text labels
        self.title = thisWorkout?.type
        
        let weekNumber = "\(thisWorkout!.week[0])"
        let weekDate = "\(thisWorkout!.week[1])"
        
        // Payload is the "actual workout". It's stored as a list, so the for loop is needed to get everything in it
        var payload = ""
        let payloadIndexMax = thisWorkout!.duration.count
        for index in 0..<payloadIndexMax - 1 {
            if index != payloadIndexMax {
                payload += "\(thisWorkout!.reps[index])x\(thisWorkout!.duration[index]) | "
            }
            else {
                payload += "\(thisWorkout!.reps[index])x\(thisWorkout!.duration[index]) "
            }
        }
        payload += thisWorkout!.unit
        
        
        weekDateLabel.text = weekDate
        weekNumberLabel.text = weekNumber
        typeLabel.text = thisWorkout?.type
        payloadLabel.text = payload
        //updateUserList() This doesn't do anything since it's already updated in the event listner -- it's just here for completion's sake
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    @IBAction func completionButton(sender: UIBarButtonItem) {
        // Conditional logic to remove/add user to workout lists based on current state
        // Side Note: the userList is updated via the event listener declared in viewDidLoad
        
        if ((thisWorkout?.usersHaveCompleted.contains(thisUser.userName)) == true) {
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
            workoutRef.updateChildValues([thisUser.userName: true])
            
            // Update the user's completedwo List in FB
            let userRef = self.ref.child("users/\(thisUser.userName)/completedwo")
            userRef.updateChildValues([thisWorkout!.workoutUsername: true])
            
            completionButtonLabel.title = "Incomplete"
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    // MISC: Funcs
    
    func updateUserList() {
        // Refreshes the local usersHaveCompleted list based on FB info, then updates the label
        var usersHaveCompleted = ""
        let usersIndexMax = thisWorkout!.usersHaveCompleted.count
        
        for index in 0..<usersIndexMax {
            //Pulling user's real name via their username, from FB
            let username = thisWorkout!.usersHaveCompleted[index]
            
            // Notice the differing path/value setup here. Not sure why, but this is the only setup that doesn't make xcode crash.
            let userRef = ref.child("users/\(username)/name")
            
            userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                let realName = snapshot.value as! String
                usersHaveCompleted += "\(realName) \n"
                print(usersHaveCompleted)
                if index == usersIndexMax - 1 {
                    self.usersHaveCompletedLabel.text = usersHaveCompleted
                }
            })
            
        }
        
    }

}
