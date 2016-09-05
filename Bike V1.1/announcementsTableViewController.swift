//
//  announcementsTableViewController.swift
//  Bike iOS
//
//  Created by David Cai on 8/25/16.
//  Copyright © 2016 David Cai. All rights reserved.
//

import UIKit
import Firebase

class announcementsTableViewController: UITableViewController {
    
    let ref = FIRDatabase.database().reference()
    var announcements = [announcementClass]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        let announcementsRef = ref.child("colleges/\(thisUser.college)/announcements")
        
        announcementsRef.observeEventType(.Value, withBlock: { snapshot in
            self.announcements = [announcementClass]()
            for announcement in snapshot.children {
                let annoucementSnap = announcement as! FIRDataSnapshot
                let announcementTitle = annoucementSnap.key
                if announcementTitle != "init" {
                    let announcementType = announcement.value["type"] as! String
                    print(announcementTitle)
                    
                    let currentAnnouncement = announcementClass(announcementType: announcementType, announcementTitle: announcementTitle)
                    if announcementType == "ride" {
                        let rideTime = announcement.value["rideTime"] as! String
                        let hostOneSignalUserId = announcement.value["hostOneSignalUserId"] as! String
                        let ridersDict = announcement.value["riders"] as! NSDictionary
                        var riders = [String:String]()
                        for rider in ridersDict {
                            if rider.key as! String != "init" {
                                riders[rider.key as! String] = rider.value as! String
                            }
                        }
                        
                        currentAnnouncement.initRideVars(rideTime, hostOneSignalUserId: hostOneSignalUserId, riders: riders)
                        
                        if currentAnnouncement.hasRidePassed() {
                            announcementsRef.child(announcementTitle).removeValue()
                        } else {
                            self.announcements.append(currentAnnouncement)
                            self.tableView.reloadData()
                        }
                    } else {
                        currentAnnouncement.initGeneralVars(announcement.value["message"] as! String)
                        self.announcements.append(currentAnnouncement)
                        self.tableView.reloadData()
                    }
                }
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

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return announcements.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "announcementTableViewCell"
            
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! announcementsTableViewCell
        let announcement = announcements[indexPath.row]
        
        cell.titleLabel.text = announcement.getAnnouncementTitle()
        cell.payloadLabel.text = announcement.getPayload()
        cell.titleLabel.adjustsFontSizeToFitWidth = true
        
        if announcement.getAnnouncementType() == "ride" {
            cell.titleLabel.textColor = UIColor(red: CGFloat(1.0/255.0), green: CGFloat(65.0/255.0), blue: CGFloat(129.0/255.0), alpha: CGFloat(1))
        }
        
        return cell
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let announcement = announcements[indexPath.row]
        if announcement.getAnnouncementType() == "ride" {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        // Grab the workout to be updated
        let announcement = announcements[indexPath.row]
        let announcementName = announcement.getAnnouncementTitle()
        
        let joinAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Join") { (action:UITableViewRowAction!, index:NSIndexPath) in
            
            let announcementRef = self.ref.child("colleges/\(thisUser.college)/announcements/\(announcementName)/riders/\(thisUser.userName)")
            announcementRef.setValue(thisUser.fullName)
            
            OneSignal.postNotification(["contents": ["en": "\(thisUser.fullName) has joined your ride!"], "include_player_ids": [announcement.hostOneSignalUserId], "data": ["senderOneSignalUserId": thisUser.oneSignalUserId!, "notificationType": "rideJoined", "rideName":"\(announcement.announcementTitle)"]])
        }
        
        let leaveAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Leave") { (action:UITableViewRowAction!, index:NSIndexPath) in
            
            let announcementRef = self.ref.child("colleges/\(thisUser.college)/announcements/\(announcementName)/riders/\(thisUser.userName)")
            announcementRef.removeValue()
            
            OneSignal.postNotification(["contents": ["en": "\(thisUser.fullName) has left your ride!"], "include_player_ids": [announcement.hostOneSignalUserId], "data": ["senderOneSignalUserId": thisUser.oneSignalUserId!, "notificationType": "rideJoined", "rideName":"\(announcement.announcementTitle)"]])
        }
        
        let cancelAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Cancel") { (action:UITableViewRowAction!, index:NSIndexPath) in
            
            let announcementRef = self.ref.child("colleges/\(thisUser.college)/announcements/\(announcementName)")
            announcementRef.removeValue()

        }
        if announcement.hostOneSignalUserId == thisUser.oneSignalUserId {
            return [cancelAction]
        } else {            
            if announcement.ridersUsernames.contains(thisUser.userName) {
                return [leaveAction]
            } else {
                return [joinAction]
            }
        }
    }

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    @IBAction func doneButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    

}
