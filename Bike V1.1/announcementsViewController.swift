//
//  announcementsViewController.swift
//  Bike V1.1
//
//  Created by David Cai on 7/26/16.
//  Copyright © 2016 David Cai. All rights reserved.
//

import UIKit
import Firebase

class announcementsViewController: UIViewController {

    // MARK: Properties
    
    var ref = FIRDatabaseReference.init()
    
    @IBOutlet weak var upcomingRidesTextLabel: UILabel!
    
    @IBOutlet weak var announcementOneTitleLabel: UILabel!
    @IBOutlet weak var announcementOneTextLabel: UILabel!
    @IBOutlet weak var announcementTwoTitleLabel: UILabel!
    @IBOutlet weak var announcementTwoTextLabel: UILabel!
    @IBOutlet weak var announcementThreeTitleLabel: UILabel!
    @IBOutlet weak var announcementThreeTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        let generalRef = ref.child("colleges/\(thisUser.college)/announcements/general")
        let rideRef = ref.child("colleges/\(thisUser.college)/announcements/rides")
        
        rideRef.observeEventType(.Value, withBlock:  { snapshot in
            
            // Initalize holding variable
            var rideText = ""
            
            // Initalize indicies for iteration/updating label
            let maxIndex = snapshot.childrenCount
            // Force Cast of index b/c maxIndex is a UInt, comparison won't work unless same type
            var index = 1 as UInt
            
            
            // FB DB Call
            for ride in snapshot.children {

                let rideSnap = ride as! FIRDataSnapshot
                let rideTitle = rideSnap.key

                if rideTitle != "init" {
                    let rideTime = snapshot.value![rideTitle] as! String
                    
                    // Creating an NSDate from input, of the ride's start time
                    let inputDateFormatter = NSDateFormatter()
                    inputDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
                    let rideNSDate = inputDateFormatter.dateFromString(rideTime)
                    
                    // Parsing day and time from that NSDate, as a string
                    let outputDateFormatter = NSDateFormatter()
                    outputDateFormatter.dateFormat = "EEE h:mm a"
                    let prelimFormattedDate = outputDateFormatter.stringFromDate(rideNSDate!)
                    
                    // Getting today, for comparison
                    let today = NSDate()
                    let todayDateString = outputDateFormatter.stringFromDate(today)
                    
                    // Checking if ride has passed. 
                    // If so, delete it from the DB
                    // Else, format and display it
                    
                    let earlierDate = rideNSDate!.earlierDate(today)
                    if earlierDate == rideNSDate {
                        let thisRideRef = rideRef.child("/\(rideTitle)")
                        thisRideRef.removeValue()
                    }
                    else {
                    
                        var finalDateString = ""
                        
                        // Creating the final string with "today" or "tomorrow", depending on results of comparison
                        if todayDateString.substringToIndex(todayDateString.startIndex.advancedBy(2)) == prelimFormattedDate.substringToIndex(prelimFormattedDate.startIndex.advancedBy(2)) {
                            finalDateString += "Today -- \(prelimFormattedDate.substringFromIndex(prelimFormattedDate.startIndex.advancedBy(4)))"
                        }
                        else {
                            finalDateString += "Tomorrow -- \(prelimFormattedDate.substringFromIndex(prelimFormattedDate.startIndex.advancedBy(4)))"
                        }
                        
                        rideText += "\(rideTitle): \(finalDateString) \n"
                    }
                    
                }

                if index == maxIndex && rideText.isEmpty == false {
                    self.upcomingRidesTextLabel.text = rideText
                }
                index += 1
            }
        })
        
        generalRef.observeEventType(.Value, withBlock: { snapshot in
            // Index to keep track of which label to update
            var index = 1
            
            // Resetting the text to "empty"
            self.announcementOneTitleLabel.textColor = UIColor.whiteColor()
            self.announcementOneTextLabel.textColor = UIColor.whiteColor()
            self.announcementTwoTitleLabel.textColor = UIColor.whiteColor()
            self.announcementTwoTextLabel.textColor = UIColor.whiteColor()
            self.announcementThreeTitleLabel.textColor = UIColor.whiteColor()
            self.announcementThreeTextLabel.textColor = UIColor.whiteColor()
            
            for announcement in snapshot.children {
                let announcementSnap = announcement as! FIRDataSnapshot
                let announcementTitle = announcementSnap.key
                if announcementTitle != "init" {
                    switch index {
                    case 1:
                        self.announcementOneTitleLabel.text = announcementTitle
                        self.announcementOneTextLabel.text = snapshot.value![announcementTitle] as? String
                        
                        self.announcementOneTitleLabel.textColor = UIColor.blackColor()
                        self.announcementOneTextLabel.textColor = UIColor.blackColor()
                    case 2:
                        self.announcementTwoTitleLabel.text = announcementTitle
                        self.announcementTwoTextLabel.text = snapshot.value![announcementTitle] as? String
                        
                        self.announcementTwoTitleLabel.textColor = UIColor.blackColor()
                        self.announcementTwoTextLabel.textColor = UIColor.blackColor()
                    case 3:
                        self.announcementThreeTitleLabel.text = announcementTitle
                        self.announcementThreeTextLabel.text = snapshot.value![announcementTitle] as? String
                        
                        self.announcementThreeTitleLabel.textColor = UIColor.blackColor()
                        self.announcementThreeTextLabel.textColor = UIColor.blackColor()
                        
                    default:
                        break
                    }
                    index += 1
                }
                
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        ref.removeAllObservers()
    }
    

}
