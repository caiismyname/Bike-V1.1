//
//  userClass.swift
//  Bike V1
//
//  Created by David Cai on 6/27/16.
//  Copyright © 2016 David Cai. All rights reserved.
//

import UIKit

class userClass: NSObject, NSCoding {
    
    // MARK: Properties
    var name: String!
    var email: String!
    var password: String!
    var bike: bikeClass?
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("user")
    
    // MARK: Struct
    struct PropertyKey {
        static let nameKey = "name"
        static let emailKey = "email"
        static let passwordKey = "password"
        static let bikeKey = "bike"
    }
    
    // MARK: Init.
    init(name: String!, email: String!, password: String!, bike: bikeClass?){
        // Is Failable Initializer
        self.name = name
        self.email = email
        self.password = password
        self.bike = bike
        
        super.init()
        
        
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(email, forKey: PropertyKey.emailKey)
        aCoder.encodeObject(password, forKey: PropertyKey.passwordKey)
        aCoder.encodeObject(bike, forKey: PropertyKey.bikeKey)
    }
    
    required convenience init(coder aDecoder: NSCoder){
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        let email = aDecoder.decodeObjectForKey(PropertyKey.emailKey) as! String
        let password = aDecoder.decodeObjectForKey(PropertyKey.passwordKey) as! String
        let bike = aDecoder.decodeObjectForKey(PropertyKey.bikeKey) as? bikeClass
        
        self.init(name: name, email: email, password: password, bike: bike)
    }
}
