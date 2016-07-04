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
    var bikeName: String
    var wheels: String
    var size: String
    var riders: [String]?
    var status: String?
    var bikeUsername: String!
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("bikeList")
    
    // MARK: Struct
    struct PropertyKey {
        static let bikeNameKey = "bikeName"
        static let wheelsKey = "wheels"
        static let sizeKey = "size"
        static let ridersKey = "riders"
        static let statusKey = "status"
        static let bikeUsernameKey = "bikeUsername"
    }
    
    // MARK: Init.
    init(bikeName: String!, wheels: String!, size: String!, riders: [String]?, status: String?, bikeUsername: String!){
        self.bikeName = bikeName
        self.wheels = wheels
        self.size = size
        self.riders = riders
        self.status = status
        self.bikeUsername = bikeUsername
        
        super.init()
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(bikeName, forKey: PropertyKey.bikeNameKey)
        aCoder.encodeObject(wheels, forKey: PropertyKey.wheelsKey)
        aCoder.encodeObject(size, forKey: PropertyKey.sizeKey)
        aCoder.encodeObject(riders, forKey: PropertyKey.ridersKey)
        aCoder.encodeObject(status, forKey: PropertyKey.statusKey)
        aCoder.encodeObject(bikeUsername, forKey: PropertyKey.bikeUsernameKey)
    }
    
    required convenience init(coder aDecoder: NSCoder){
        let bikeName = aDecoder.decodeObjectForKey(PropertyKey.bikeNameKey) as! String
        let wheels = aDecoder.decodeObjectForKey(PropertyKey.wheelsKey) as! String
        let size = aDecoder.decodeObjectForKey(PropertyKey.sizeKey) as! String
        let riders = aDecoder.decodeObjectForKey(PropertyKey.ridersKey) as? [String]
        let status = aDecoder.decodeObjectForKey(PropertyKey.statusKey) as? String
        let bikeUsername = aDecoder.decodeObjectForKey(PropertyKey.bikeUsernameKey) as! String
        
        self.init(bikeName: bikeName, wheels: wheels, size: size, riders: riders, status: status, bikeUsername: bikeUsername)
    }
    
    
}
