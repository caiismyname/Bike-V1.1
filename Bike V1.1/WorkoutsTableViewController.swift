//
//  WorkoutsTableViewController.swift
//  Bike V1.1
//
//  Created by David Cai on 7/1/16.
//  Copyright © 2016 David Cai. All rights reserved.
//

import UIKit
import Firebase

class WorkoutsTableViewController: UITableViewController{
    
    var workoutList = [workoutClass]()
    let ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        workoutList = loadWorkoutList()!
        //print(workoutList)

        // Watcher thing that auto refreshes when FB DB changes
        // As of right now, it replaces the whole workout list
        // to cover all cases (append, delete, change)
        
        // FB init.
        let workoutRef = ref.child("colleges/\(thisUser.college)/workouts/")
        
        // RealTime listener b/c possible updates (completion) from this page
        workoutRef.observeEventType(.Value, withBlock: { snapshot in
            // This temp decleration must be inside the .observeEventType so that it resets with every refresh. Otherwise, you'll just append the old list
            var tempWorkoutList = [workoutClass]()
            for child in snapshot.children {
                // Create workoutClass object from FB data
                let type = child.value!["type"] as! String
                let unit = child.value!["unit"] as! String
                let duration = child.value!["duration"] as! [Int]
                let reps = child.value!["reps"] as! [Int]
                let week = child.value!["week"] as! [String]
            
                let childSnap = child as! FIRDataSnapshot
                let workoutUsername = childSnap.key
                
                var usersHaveCompleted = [String:String]()
                let usersHaveCompletedDict = child.value!["usersHaveCompleted"] as! NSDictionary
                for user in usersHaveCompletedDict {
                    if user.key as! String != "init" {
                        usersHaveCompleted[user.key as! String] = user.value as? String
                    }
                }
            
                let workoutObject = workoutClass(type: type, duration: duration, reps: reps, unit: unit, usersHaveCompleted: usersHaveCompleted, week: week, workoutUsername: workoutUsername)
                tempWorkoutList.append(workoutObject)
                
                // To avoid callbacks, the new (refreshed) bikeList is saved, loaded, and the view is reloaded
                // for every workout. It doesn't seem to affect the appearence, so we're cool.
                self.saveWorkoutList(tempWorkoutList)
                self.workoutList = self.loadWorkoutList()!
                self.tableView.reloadData()
            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return workoutList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "workoutTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! WorkoutsTableViewCell
            
        let workout = workoutList[indexPath.row]

        let weekInfo = "\(workout.week[0]): \(workout.week[1])"
        let usersHaveCompleted = String(workout.usersHaveCompleted!.count)
        
        cell.typeLabel.text = workout.type
        cell.weekLabel.text = weekInfo
        cell.usersHaveCompletedLabel.text = usersHaveCompleted
        
        
        if workout.usersHaveCompleted!.keys.contains(thisUser.userName) {
            cell.backgroundColor = UIColor.clearColor()
        }
        else {
            // If they have not completed the workout
            cell.backgroundColor = UIColor(red: CGFloat(253.0/255.0), green: CGFloat(153.0/255.0), blue: CGFloat(153.0/255.0), alpha: CGFloat(1.0))
        }

        // So nothing (visually) changes when cell is selected
        cell.selectionStyle = .None
        
        return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        let workout = self.workoutList[indexPath.row]
        
        if workout.usersHaveCompleted!.keys.contains(thisUser.userName){
            return false
        } else {
            return true
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {}
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        // Grab the workout to be updated
        let workout = self.workoutList[indexPath.row]
        let workoutUsername = workout.workoutUsername
        
        let completeAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Complete") { (action:UITableViewRowAction!, index:NSIndexPath) in
            
            // Update the workout's usersHaveCompleted List in FB
            let workoutRef = self.ref.child("colleges/\(thisUser.college)/workouts/\(workoutUsername)/usersHaveCompleted")
            workoutRef.updateChildValues([thisUser.userName: thisUser.fullName])
            
            
            // Update the user's completedwo List in FB
            let userRef = self.ref.child("users/\(thisUser.userName)/completedwo")
            userRef.updateChildValues([workoutUsername: true])
            
        }
        
        return [completeAction]
    }

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: - Navigation

    // For the unwind segue
    @IBAction func unwindBackToWorkoutlist(segue: UIStoryboardSegue) {}
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // The "if" prevents this from running when exiting the workoutlist view.
        if segue.identifier == "fromWorkoutListToWorkoutDetailView" {
            // Get the new view controller using segue.destinationViewController.
            let selectedWorkoutCell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(selectedWorkoutCell)
            let selectedWorkout = workoutList[indexPath!.row]
            // Pass the selected object to the new view controller.
            let workoutDetailView = segue.destinationViewController as! WorkoutDetailViewController
            workoutDetailView.thisWorkout = selectedWorkout
            print(selectedWorkout.workoutUsername)
        }
        
        ref.removeAllObservers()
    }
    
    
    // MARK: NSCoding
    
    func saveWorkoutList(workoutListName: [workoutClass]){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(workoutListName, toFile: workoutClass.ArchiveURL!.path!)
        if isSuccessfulSave {
            print("WorkoutList Saved")
        }
        else {
            print("Failed to save WorkoutList")
        }
    }
    
    func loadWorkoutList() -> [workoutClass]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(workoutClass.ArchiveURL!.path!) as? [workoutClass]
    }

    
    
}
