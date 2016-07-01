//
//  WorkoutsTableViewController.swift
//  Bike V1.1
//
//  Created by David Cai on 7/1/16.
//  Copyright © 2016 David Cai. All rights reserved.
//

import UIKit
import Firebase

class WorkoutsTableViewController: UITableViewController {
    
    var workoutList = [workoutClass]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        workoutList = loadWorkoutList()!
        
        // Watcher thing that auto refreshes when FB DB changes
        // As of right now, it replaces the whole bike list
        // to cover all cases (append, delete, change)
        
        // FB init.
        let ref = FIRDatabase.database().reference()
        let workoutRef = ref.child("workouts")
        
        workoutRef.observeEventType(.Value, withBlock: { snapshot in
            // This temp decleration must be inside the .observeEventType so that it resets with every refresh. Otherwise, you'll just append the old list
            var tempWorkoutList = [workoutClass]()
            for child in snapshot.children {
                // Create workoutClass object from FB data
                let type = child.value["type"] as! String
                let unit = child.value["unit"] as! String
                let duration = child.value["duration"] as! [Int]
                let reps = child.value["reps"] as! [Int]
                let week = child.value["week"] as! [AnyObject]
                
                let workoutObject = workoutClass(type: type, duration: duration, reps: reps, unit: unit, week: week)
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
        cell.typeLabel.text = workout.type

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: NSCoding
    
    func saveWorkoutList(workoutListName: [workoutClass]){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(workoutListName, toFile: workoutClass.ArchiveURL.path!)
        if isSuccessfulSave {
            print("WorkoutList Saved")
        }
        else {
            print("Failed to save WorkoutList")
        }
    }
    
    func loadWorkoutList() -> [workoutClass]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(workoutClass.ArchiveURL.path!) as? [workoutClass]
    }

}
