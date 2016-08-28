//
//  workoutClass.swift
//  unit V1
//
//  Created by David Cai on 6/27/16.
//  Copyright © 2016 David Cai. All rights reserved.
//

import UIKit

class workoutClass: NSObject, NSCoding {
    
    // MARK: Properties
    var type: String
    var duration: [Int]
    var reps: [Int]
    var unit: String
    var usersHaveCompleted: [String:String]?
    var week: [String]
    var workoutUsername: String!
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("workout")
    
    // MARK: Struct
    struct PropertyKey {
        static let typeKey = "type"
        static let durationKey = "duration"
        static let repsKey = "reps"
        static let unitKey = "unit"
        static let usersHaveCompletedKey = "usersHaveCompleted"
        static let weekKey = "week"
        static let workoutUsernameKey = "workoutUsername"
    }
    
    // MARK: Init.
    init(type: String!, duration: [Int]!, reps: [Int]!, unit: String!, usersHaveCompleted: [String:String]?, week: [String]!, workoutUsername: String!){
        self.type = type
        self.duration = duration
        self.reps = reps
        self.unit = unit
        self.usersHaveCompleted = usersHaveCompleted
        self.week = week
        self.workoutUsername = workoutUsername
        
        super.init()
    }
    
    // MARK: Getters
    func getPayload() -> String {
        // Payload is the "actual workout". It's stored as a list, so the for loop is needed to get everything in it
        // Using an index b/c we need to grab from two lists, not just one
        
        var payload = ""
        let payloadIndexMax = self.duration.count
        for index in 0..<payloadIndexMax - 1 {
            if index != payloadIndexMax {
                payload += "\(self.reps[index])x\(self.duration[index]) \n"
            }
            else {
                payload += "\(self.reps[index])x\(self.duration[index]) "
            }
        }
        
        payload += self.unit
        return payload
    }
    
    func getUsersHaveCompleted() -> String {
        var payload = ""
        let usersFullNames = self.usersHaveCompleted!.values
        for user in usersFullNames{
            payload += user + "\n"
        }
        return payload
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(type, forKey: PropertyKey.typeKey)
        aCoder.encodeObject(duration, forKey: PropertyKey.durationKey)
        aCoder.encodeObject(reps, forKey: PropertyKey.repsKey)
        aCoder.encodeObject(unit, forKey: PropertyKey.unitKey)
        aCoder.encodeObject(usersHaveCompleted, forKey: PropertyKey.usersHaveCompletedKey)
        aCoder.encodeObject(week, forKey: PropertyKey.weekKey)
        aCoder.encodeObject(workoutUsername, forKey: PropertyKey.workoutUsernameKey)
    }
    
    required convenience init(coder aDecoder: NSCoder){
        let type = aDecoder.decodeObjectForKey(PropertyKey.typeKey) as! String
        let duration = aDecoder.decodeObjectForKey(PropertyKey.durationKey) as! [Int]
        let reps = aDecoder.decodeObjectForKey(PropertyKey.repsKey) as! [Int]
        let unit = aDecoder.decodeObjectForKey(PropertyKey.unitKey) as! String
        let usersHaveCompleted = aDecoder.decodeObjectForKey(PropertyKey.usersHaveCompletedKey) as? [String:String]
        let week = aDecoder.decodeObjectForKey(PropertyKey.weekKey) as! [String]
        let workoutUsername = aDecoder.decodeObjectForKey(PropertyKey.workoutUsernameKey) as! String
        
        self.init(type: type, duration: duration, reps: reps, unit: unit, usersHaveCompleted: usersHaveCompleted, week: week, workoutUsername: workoutUsername)
    }
}
