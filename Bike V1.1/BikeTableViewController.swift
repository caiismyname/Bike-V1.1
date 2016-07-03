//
//  BikeTableViewController.swift
//  
//
//  Created by David Cai on 6/29/16.
//
//

import UIKit
import Firebase

class BikeTableViewController: UITableViewController {
    
    //MARK: Properties
    var bikeList = [bikeClass]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Loading the saved list of bikes, to avoid FB calls
        bikeList = loadBikeList()!
        
        // Watcher thing that auto refreshes when FB DB changes
        // As of right now, it replaces the whole bike list
        // to cover all cases (append, delete, change)
        
        // FB init.
        let ref = FIRDatabase.database().reference()
        let bikeListRef = ref.child("colleges/\(thisUser.college)/bikeList")
        
        bikeListRef.observeEventType(.Value, withBlock: { snapshot in
            // This temp decleration must be inside the .observeEventType so that it resets with every refresh. Otherwise, you'll just append the old list
            var tempBikeList = [bikeClass]()
            for child in snapshot.children {
                // Creating bikeClass object from FB DB data
                let bikeName = child.value["name"] as! String
                let size = child.value["size"] as! String
                let wheels = child.value["wheels"] as! String
                let riders = child.value["riders"] as? [String]
                
                let bikeObject = bikeClass(bikeName: bikeName, wheels: wheels, size: size, riders: riders, status: nil)
                tempBikeList.append(bikeObject)
                
                // To avoid callbacks, the new (refreshed) bikeList is saved, loaded, and the view is reloaded
                // for every bike. It doesn't seem to affect the appearence, so we're cool.
                self.saveBikeList(tempBikeList)
                self.bikeList = self.loadBikeList()!
                self.tableView.reloadData()
            }
            
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
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bikeList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Take info from bikeList array and puts them into cells
        let cellIdentifier = "BikeTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BikeTableViewCell
        
        let bike = bikeList[indexPath.row]

        cell.bikeNameDisplay.text = bike.bikeName
        cell.wheelInfoDisplay.text = bike.wheels
        cell.sizeInfoDisplay.text = bike.size

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

    
    // MARK: - Navigation
    
    @IBAction func unwindToBikelist(segue: UIStoryboardSegue) {}
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromBikelistToBikeDetailView" {
            
            // Grab which bike initiated the segue
            let selectedBikeCell = sender as! BikeTableViewCell
            let indexPath = tableView.indexPathForCell(selectedBikeCell)!
            let selectedBike = bikeList[indexPath.row]
            
            // Send that bike info over to the BikeDetailView
            let bikeDetailView = segue.destinationViewController as! BikeDetailViewController
            bikeDetailView.thisBike = selectedBike
            
        }
    }
    
    
    
    
    // MARK: Actions

    @IBAction func cancelButton(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("unwindFromBikelistToHomepage", sender: self)
    }

    // MARK: NSCoding
    
    func saveBikeList(bikeListName: [bikeClass]){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(bikeListName, toFile: bikeClass.ArchiveURL.path!)
        if isSuccessfulSave {
            print("BikeList Saved")
        }
        else {
            print("Failed to save BikeList")
        }
    }
    
    func loadBikeList() -> [bikeClass]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(bikeClass.ArchiveURL.path!) as? [bikeClass]
    }
    
}
