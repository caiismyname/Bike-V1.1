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
    // NOTE: Change size to INT when prelim stuff is done
    var size: String
    var status: String?
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("bikeList")
    
    // MARK: Struct
    struct PropertyKey {
        static let bikeNameKey = "bikeName"
        static let wheelsKey = "wheels"
        static let sizeKey = "size"
        static let statusKey = "status"
    }
    
    // MARK: Init.
    init(bikeName: String!, wheels: String!, size: String!, status: String?){
        self.bikeName = bikeName
        self.wheels = wheels
        self.size = size
        self.status = status
        
        super.init()
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(bikeName, forKey: PropertyKey.bikeNameKey)
        aCoder.encodeObject(wheels, forKey: PropertyKey.wheelsKey)
        aCoder.encodeObject(size, forKey: PropertyKey.sizeKey)
        aCoder.encodeObject(status, forKey: PropertyKey.statusKey)
    }
    
    required convenience init(coder aDecoder: NSCoder){
        let bikeName = aDecoder.decodeObjectForKey(PropertyKey.bikeNameKey) as! String
        let wheels = aDecoder.decodeObjectForKey(PropertyKey.wheelsKey) as! String
        let size = aDecoder.decodeObjectForKey(PropertyKey.sizeKey) as! String
        let status = aDecoder.decodeObjectForKey(PropertyKey.statusKey) as? String
        
        self.init(bikeName: bikeName, wheels: wheels, size: size, status: status)
    }
    
    
}
