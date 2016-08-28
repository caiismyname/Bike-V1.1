//
//  announcementClass.swift
//  Bike iOS
//
//  Created by David Cai on 8/16/16.
//  Copyright © 2016 David Cai. All rights reserved.
//

import UIKit
import Firebase

class announcementClass {
    // MARK: Properties
    var announcementType:String
    var announcementTitle:String
    var announcementMessage:String
    var rideTime:String
    var formattedTime: String
    var hostOneSignalUserId:String
    var riders = [String:String]()
    var ridersUsernames = [String]()
    var ridersFullnames = [String]()
    
    init(announcementType: String, announcementTitle: String) {
        self.announcementType = announcementType
        self.announcementTitle = announcementTitle
        
        self.announcementMessage = ""
        self.rideTime = ""
        self.formattedTime = ""
        self.hostOneSignalUserId = ""
        
    }
    
    func getAnnouncementType() -> String { return self.announcementType}
    
    func getAnnouncementTitle() -> String {return self.announcementTitle}
    
    func getPayload() -> String {
        if self.announcementType == "ride" {
            return getRidePayload()
        } else {
            return getMessage()
        }
    }
    
    //Initializer and methods for general messages
    func initGeneralVars(announcementMessage: String) { self.announcementMessage = announcementMessage}
    
    func getMessage() -> String { return self.announcementMessage};
    
    //Initializer and general setup for rides
    func initRideVars(rideTime: String, hostOneSignalUserId: String, riders:[String:String]) {
        self.rideTime = rideTime
        self.hostOneSignalUserId = hostOneSignalUserId
        self.riders = riders;
        
        for (riderUsername, riderFullname) in riders {
            if riderUsername != "init" {
                self.ridersUsernames.append(riderUsername)
                self.ridersFullnames.append(riderFullname)
            }
        }
        
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
        // If so, make formattedTime = "passed"
        // Else, format and display it
        
        let earlierDate = rideNSDate!.earlierDate(today)
        if earlierDate == rideNSDate {
            self.formattedTime = "passed"
        }
        else {
            // Creating the final string with "today" or "tomorrow", depending on results of comparison
            if todayDateString.substringToIndex(todayDateString.startIndex.advancedBy(2)) == prelimFormattedDate.substringToIndex(prelimFormattedDate.startIndex.advancedBy(2)) {
                self.formattedTime = "Today -- \(prelimFormattedDate.substringFromIndex(prelimFormattedDate.startIndex.advancedBy(4)))"
            }
            else {
                self.formattedTime = "Tomorrow -- \(prelimFormattedDate.substringFromIndex(prelimFormattedDate.startIndex.advancedBy(4)))"
            }
        }
    }
    
    func hasRidePassed() -> Bool {
        // Returns true if ride has passed, false otherwise
        var flag = false
        if self.formattedTime == "passed" {
            flag = true
        }

        return flag
    }
    
    func getRidePayload() -> String {
        var payload = self.formattedTime + "\n"
        if self.ridersFullnames.count > 0 {
            payload += "Joined: "
            for rider in self.ridersFullnames {
                payload += rider + ", "
            }
        } else {
            payload += "No one has joined this ride yet"
        }
        return payload
    }
    
    func joinRide() {
        if self.hostOneSignalUserId != thisUser.oneSignalUserId {
            // Posting Notification
            OneSignal.postNotification(["contents": ["en": "\(thisUser.firstName) \(thisUser.lastName) has joined your ride!"], "include_player_ids": [self.hostOneSignalUserId], "data": ["senderOneSignalUserId": thisUser.oneSignalUserId!, "notificationType": "rideJoined"]])
            
            // Updating FB DB
            var ref = FIRDatabaseReference.init()
            ref = FIRDatabase.database().reference()
            ref.child("colleges/\(thisUser.college)/announcements/\(self.announcementTitle)/riders/\(thisUser.userName)").setValue(thisUser.fullName)
        }
    }
    
    func leaveRide() {
        if self.hostOneSignalUserId != thisUser.oneSignalUserId {
            // Posting Notification
            OneSignal.postNotification(["contents": ["en": "\(thisUser.firstName) \(thisUser.lastName) has left your ride!"], "include_player_ids": [self.hostOneSignalUserId], "data": ["senderOneSignalUserId": thisUser.oneSignalUserId!, "notificationType": "rideJoined"]])
            
            // Updating FB DB
            var ref = FIRDatabaseReference.init()
            ref = FIRDatabase.database().reference()
            ref.child("colleges/\(thisUser.college)/announcements/\(self.announcementTitle)/riders/\(thisUser.userName)").removeValue()
        }
    }
    
    

    
    
    
}
