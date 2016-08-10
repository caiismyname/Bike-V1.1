//
//  goRideViewController.swift
//  
//
//  Created by David Cai on 7/22/16.
//
//

import UIKit
import Firebase

class realGoRideViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var timePickerOutlet: UIDatePicker!
    
    @IBOutlet weak var nowButtonOutlet: UIButton!
    @IBOutlet weak var tenMinutesButtonOutlet: UIButton!
    @IBOutlet weak var thirtyMinutesButtonOutlet: UIButton!
    @IBOutlet weak var sixtyMinutesButtonOutlet: UIButton!
    @IBOutlet weak var atTimeButtonOutlet: UIButton!
    
    var notificationTime = "now"
    var timePickerTime: NSDate?
    
    var ref = FIRDatabaseReference.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        timePickerOutlet.minimumDate =  NSCalendar.currentCalendar().dateByAddingUnit(.Hour, value: 1, toDate: NSDate(), options: [])
        timePickerOutlet.maximumDate = NSCalendar.currentCalendar().dateByAddingUnit(.Hour, value: 22, toDate: NSDate(), options: [])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    // MARK: Actions
    @IBAction func nowButton(sender: UIButton) {
        notificationTime = "now"
        turnButtonsGray(nowButtonOutlet)
    }
    
    @IBAction func tenMinutesButton(sender: UIButton) {
        notificationTime = "10"
        turnButtonsGray(tenMinutesButtonOutlet)
    }

    @IBAction func thirtyMinutesButton(sender: UIButton) {
        notificationTime = "30"
        turnButtonsGray(thirtyMinutesButtonOutlet)
    }
    
    @IBAction func sixtyMinutesButton(sender: UIButton) {
        notificationTime = "60"
        turnButtonsGray(sixtyMinutesButtonOutlet)
    }
    
    @IBAction func atTimeButton(sender: UIButton) {
        notificationTime = "timePicker"
        turnButtonsGray(atTimeButtonOutlet)
    }

    @IBAction func timePickerAction(sender: UIDatePicker) {
        timePickerTime = timePickerOutlet.date
        print(timePickerTime)
    }
    
    func turnButtonsGray(staysBlue: UIButton){
        nowButtonOutlet.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        tenMinutesButtonOutlet.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        thirtyMinutesButtonOutlet.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        sixtyMinutesButtonOutlet.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        atTimeButtonOutlet.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        staysBlue.setTitleColor(UIColor.magentaColor(), forState: .Normal)
        
    }

    @IBAction func goRideButton(sender: UIButton) {
        
        let userBikeUsername = thisUser.bike!
        
        // Determine if User has a bike associated with them
        if userBikeUsername != "None" {
            // Determine the current status of the bike
            let bikeRef = self.ref.child("colleges/\(thisUser.college)/bikeList/\(userBikeUsername)/status")
            bikeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                print("statuslookeup")
                let bikeStatus = snapshot.value! as! String
                
                if bikeStatus == "Ready" {
                    print("bikeisready")
                    
                    self.sendNotificationShell()
                    
                }
                else if bikeStatus == "In Use" {
                    let bikeInUseAlert = UIAlertController(title: "Your bike is in use", message: "Your bike is currently being used! You'll have to find another.", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    bikeInUseAlert.addAction(UIAlertAction(title: "Continue", style: .Default, handler: { alertAction in
                        self.sendNotificationShell()
                    }))
                    bikeInUseAlert.addAction(UIAlertAction(title: "Cancel Ride", style: .Cancel, handler: nil))
                    self.presentViewController(bikeInUseAlert, animated: true, completion: nil)
                    
                }
                else if bikeStatus == "Unusable" {
                    let bikeUnusableAlert = UIAlertController(title: "Your bike is unusable!", message: "Your bike is currently unusable! You'll have to find another.", preferredStyle: UIAlertControllerStyle.Alert)
                    bikeUnusableAlert.addAction(UIAlertAction(title: "Continue", style: .Default, handler: { alertAction in
                        self.sendNotificationShell()
                    }))
                    bikeUnusableAlert.addAction(UIAlertAction(title: "Cancel Ride", style: .Cancel, handler: nil))
                    self.presentViewController(bikeUnusableAlert, animated: true, completion: nil)
                }
                
            })
        }
        // If user does not have a bike, let them no
        // Do not send notifications
        else {
            let noBikeAlert = UIAlertController(title: "You don't have a bike!", message: "Set a bike as your own from the Bike List", preferredStyle: UIAlertControllerStyle.Alert)
            noBikeAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(noBikeAlert, animated: true, completion: nil)
        }

    }
    
    func sendNotificationShell() {
        getUserIds { listOfUserIds in
            self.getNotificationTimes(listOfUserIds, completion: { (message, listOfUserIds, listOfTimes) in
                self.postRideNotification(message, listOfUserIds: listOfUserIds, listOfTimes: listOfTimes)
            })
        }
    }
    
    func postRideNotification(messages: [String], listOfUserIds: [String], listOfTimes: [String]) {
        // Send out notification
        if listOfTimes.count == 0 {
            OneSignal.postNotification(["contents": ["en": messages[0]], "include_player_ids": listOfUserIds, "data": ["senderOneSignalUserId": thisUser.oneSignalUserId!, "notificationType": "goingOnRide"]])
        }
        else {
            
            var index = 0
            
            for _ in messages {
                print(index)
                OneSignal.postNotification(["contents": ["en": messages[index]], "include_player_ids": listOfUserIds, "send_after": listOfTimes[index], "data": ["senderOneSignalUserId": thisUser.oneSignalUserId!, "notificationType": "goingOnRide"]])
                index += 1
            }
            
        }
        // Let the user know their notification has been sent out
        let goRideSentAlert = UIAlertController(title: "Team Notified", message: "Your team now knows you're going on a ride!", preferredStyle: UIAlertControllerStyle.Alert)
        goRideSentAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(goRideSentAlert, animated: true, completion: nil)
        
    }
    
    func getUserIds(completion: (listOfUserIds: [String]) -> Void) {
        // Find oneSignalUserId's of all members of a team (college)
        
        var userIdList = [String]()
        let teammatesRef = ref.child("colleges/\(thisUser.college)/users")
        
        teammatesRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            for member in snapshot.children {
                let memberSnap = member as! FIRDataSnapshot
                if memberSnap.key != thisUser.userName {
                    userIdList.append(memberSnap.value as! String)
                }
            }
            completion(listOfUserIds: userIdList)
        })
        
    }
    
    
    func getNotificationTimes(listOfUserIds: [String], completion: (messages: [String], listOfUserIds: [String], listOfTimes: [String]) -> Void) {
        
        // Message and listOfTimes are lists so that postNotification can iterate through and send each notification seperately
        
        // If there is only one notification, listOfTImes will remain empty -- that is the flag 
        // All messages will be in the message list, regardless of total count
        
        // Since this function has access to the notification times, setBikeStatus is also called here
        
        var messages = [String]()
        var listOfTimes = [String]()
        
        if notificationTime == "now" {
            messages.append("\(thisUser.firstName) \(thisUser.lastName) is going on a ride right now!")
            setBikeStatus("now")
            
        }
        else if notificationTime == "10" {
            messages.append("\(thisUser.firstName) \(thisUser.lastName) is going on a ride in 10 minutes!")
            
            let rideTime = calculateTimes(10,secondsFromNow: 0)
            setBikeStatus(rideTime)
            setAnnouncementRides(rideTime)
            
        }
        else if notificationTime == "30" {
            messages.append("\(thisUser.firstName) \(thisUser.lastName) is going on a ride in 30 minutes!")
            messages.append("\(thisUser.firstName) \(thisUser.lastName) is going on a ride right now!")
            
            listOfTimes.append(calculateTimes(0,secondsFromNow: 5))
            listOfTimes.append(calculateTimes(30,secondsFromNow: 0))
            
            setBikeStatus(listOfTimes[1])
            setAnnouncementRides(listOfTimes[1])
        }
        else if notificationTime == "60" {
            messages.append("\(thisUser.firstName) \(thisUser.lastName) is going on a ride in an hour!")
            messages.append("\(thisUser.firstName) \(thisUser.lastName) is going on a ride right now!")
            
            listOfTimes.append(calculateTimes(0,secondsFromNow: 5))
            listOfTimes.append(calculateTimes(60,secondsFromNow: 0))
            
            setBikeStatus(listOfTimes[1])
            setAnnouncementRides(listOfTimes[1])
        }
        else if notificationTime == "timePicker" {
            let notificationFormatter = NSDateFormatter()
            notificationFormatter.dateFormat = "h:mm a"
            let timeString = notificationFormatter.stringFromDate(timePickerTime!)
            
            let isoFormatter = NSDateFormatter()
            isoFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
            let isoTimeString = isoFormatter.stringFromDate(timePickerTime!)
            
            messages.append("\(thisUser.firstName) \(thisUser.lastName) is going on a ride at \(timeString)!")
            messages.append("\(thisUser.firstName) \(thisUser.lastName) is going on a ride right now!")
            
            listOfTimes.append(calculateTimes(0, secondsFromNow: 5))
            listOfTimes.append(isoTimeString)
            
            setBikeStatus(isoTimeString)
            setAnnouncementRides(isoTimeString)
        }
        
        completion(messages: messages, listOfUserIds: listOfUserIds, listOfTimes: listOfTimes)
    }
    
    func calculateTimes(minutesFromNow: Int, secondsFromNow: Int) -> String {
        let currentDate = NSDate()
        let newDateComponents = NSDateComponents()
        newDateComponents.minute = minutesFromNow
        newDateComponents.second = secondsFromNow
        let calculatedDate = NSCalendar.currentCalendar().dateByAddingComponents(newDateComponents, toDate: currentDate, options: NSCalendarOptions.init(rawValue: 0))
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        
        let formattedCalculatedDate = formatter.stringFromDate(calculatedDate!)
        return formattedCalculatedDate
    }
    
    
    func setAnnouncementRides(rideTime: String) {
        
        // Updating FB DB
        let ridesRef = ref.child("colleges/\(thisUser.college)/announcements/rides")
        ridesRef.updateChildValues(["\(thisUser.firstName) \(thisUser.lastName)'s ride" : rideTime])
    }
    
    // Function that executes a block after time interval, even when app is in background
    func runAfterDelay(delay: NSTimeInterval, block: dispatch_block_t) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue(), block)
    }
    
    func setBikeStatus(rideTime: String) {
        
        let bikeStatusRef = self.ref.child("colleges/\(thisUser.college)/bikeList/\(thisUser.bike!)/status")
        
        if rideTime == "now" {
            bikeStatusRef.setValue("In Use")
            
            // Resets the bike to "ready" after an hour
            runAfterDelay(3600, block: { 
                bikeStatusRef.setValue("Ready")
            })
        }
        else {
            // Turn rideTime into NSDate object
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
            let rideTimeNSDate = formatter.dateFromString(rideTime)
            let endTimeNSDate = rideTimeNSDate?.dateByAddingTimeInterval(3600)
            
            // Find time interval, in seconds, from now until rideTime
            let currentDate = NSDate()
            let intervalToStart = rideTimeNSDate?.timeIntervalSinceDate(currentDate)
            let intervalToEnd = endTimeNSDate?.timeIntervalSinceDate(currentDate)
            
            // Calls to start timer that will set the status values
            runAfterDelay(intervalToStart!, block: { 
                bikeStatusRef.setValue("In Use")
            })
            
            runAfterDelay(intervalToEnd!, block: {
                // Hard-coded "Ready" value b/c function will not get called if bike is unusable
                bikeStatusRef.setValue("Ready")
            })
        }
    }
    

    

    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        ref.removeAllObservers()
    }

}
