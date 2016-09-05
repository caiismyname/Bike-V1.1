//
//  bikeClass.swift
//  Bike V1.1
//
//  Created by David Cai on 6/29/16.
//  Copyright © 2016 David Cai. All rights reserved.
//

import UIKit

class bikeClass: NSObject, NSCoding {
    
    // MARK: Properties
    var bikeShortName: String
    var bikeFullName: String
    var size: String
    var riders: [String:String]?
    var status: String?
    var bikeUsername: String!
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("bikeList")
    
    // MARK: Struct
    struct PropertyKey {
        static let bikeShortNameKey = "bikeShortName"
        static let bikeFullNameKey = "bikeFullName"
        static let sizeKey = "size"
        static let ridersKey = "riders"
        static let statusKey = "status"
        static let bikeUsernameKey = "bikeUsername"
    }
    
    // MARK: Init.
    init(bikeShortName: String!, bikeFullName: String!, size: String!, riders: [String:String]?, status: String?, bikeUsername: String!){
        self.bikeShortName = bikeShortName
        self.bikeFullName = bikeFullName
        self.size = size
        self.riders = riders
        self.status = status
        self.bikeUsername = bikeUsername
        
        super.init()
    }
    
    // MARK: Getters
    
    func getRidersPayload() -> String {
        var ridersPayload = ""
        for (_, riderFullname) in self.riders! {
            ridersPayload += riderFullname + ", "
        }
        
        if (ridersPayload != "") {
            return ridersPayload
        } else {
            return "No Riders"
        }
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(bikeShortName, forKey: PropertyKey.bikeShortNameKey)
        aCoder.encodeObject(bikeFullName, forKey: PropertyKey.bikeFullNameKey)
        aCoder.encodeObject(size, forKey: PropertyKey.sizeKey)
        aCoder.encodeObject(riders, forKey: PropertyKey.ridersKey)
        aCoder.encodeObject(status, forKey: PropertyKey.statusKey)
        aCoder.encodeObject(bikeUsername, forKey: PropertyKey.bikeUsernameKey)
    }
    
    required convenience init(coder aDecoder: NSCoder){
        let bikeShortName = aDecoder.decodeObjectForKey(PropertyKey.bikeShortNameKey) as! String
        let bikeFullName = aDecoder.decodeObjectForKey(PropertyKey.bikeFullNameKey) as! String
        let size = aDecoder.decodeObjectForKey(PropertyKey.sizeKey) as! String
        let riders = aDecoder.decodeObjectForKey(PropertyKey.ridersKey) as? [String:String]
        let status = aDecoder.decodeObjectForKey(PropertyKey.statusKey) as? String
        let bikeUsername = aDecoder.decodeObjectForKey(PropertyKey.bikeUsernameKey) as! String
        
        self.init(bikeShortName: bikeShortName, bikeFullName: bikeFullName, size: size, riders: riders, status: status, bikeUsername: bikeUsername)
    }
    
    
}
