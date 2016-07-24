
//
//  AppDelegate.swift
//  Bike V1.1
//
//  Created by David Cai on 6/28/16.
//  Copyright © 2016 David Cai. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        FIRApp.configure()
        
        _ = OneSignal(launchOptions: launchOptions, appId: "0d103f19-b6e5-4da9-9864-8ae146104c88") { (message, additionalData, isActive) in
            NSLog("OneSignal Notification opened:\nMessage: %@", message)
            
            // "Going on ride" notifications will send the sender's OSUserId in the addtional data.
            // "Join ride" notifications will not. 
            // Thus, the .count of additionalData can be used as a flag for which handler to call
            if additionalData.count > 1 {
                // Recieved a "Going on ride" notification
                NSLog("additionalData: %@", additionalData)
                let senderOneSignalUserId = additionalData["senderOneSignalUserId"]
                
                let joinRideAlert = UIAlertController(title: "A teammate is riding!", message: message + "\n Would you like to join them?", preferredStyle: UIAlertControllerStyle.Alert)
                joinRideAlert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
                joinRideAlert.addAction(UIAlertAction(title: "Join!", style: .Default, handler: { alertAction in
                    OneSignal.defaultClient().postNotification(["contents": ["en": "\(thisUser.firstName) \(thisUser.lastName) has joined your ride!"], "include_player_ids": [senderOneSignalUserId!]])
                    
                }))
                
                self.window?.rootViewController?.presentViewController(joinRideAlert, animated: true, completion: nil)
                
                
                if let customKey = additionalData["customKey"] as! String? {
                    NSLog("customKey: %@", customKey)
                }
            }
            else {
                // Recieved a "xxx Joined your ride" notification"
                print("bollucks")
                let rideJoinedAlert = UIAlertController(title: "A teammate joined your ride!", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                rideJoinedAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                
                self.window?.rootViewController?.presentViewController(rideJoinedAlert, animated: true, completion: nil)
            }
        }
        
        OneSignal.defaultClient().enableInAppAlertNotification(false)
        
        return true
        
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

