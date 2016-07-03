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
    var firstName: String!
    var lastName: String!
    var college: String!
    var email: String!
    var password: String!
    var bike: bikeClass?
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("user")
    
    // MARK: Struct
    struct PropertyKey {
        static let firstNameKey = "firstName"
        static let lastNameKey = "lastName"
        static let collegeKey = "college"
        static let emailKey = "email"
        static let passwordKey = "password"
        static let bikeKey = "bike"
    }
    
    // MARK: Init.
    init(firstName: String!, lastName: String!, college: String!, email: String!, password: String!, bike: bikeClass?){
        
        let DBCollege: String
        // Some hard-coding issues, with UI and DB names for colleges
        if college == "Will Rice" {
            DBCollege = "wrc"
        }
        else {
            DBCollege = college
        }
        self.firstName = firstName
        self.lastName = lastName
        self.college = DBCollege
        self.email = email
        self.password = password
        self.bike = bike
        
        super.init()
        
        
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(firstName, forKey: PropertyKey.firstNameKey)
        aCoder.encodeObject(lastName, forKey: PropertyKey.lastNameKey)
        aCoder.encodeObject(college, forKey: PropertyKey.collegeKey)
        aCoder.encodeObject(email, forKey: PropertyKey.emailKey)
        aCoder.encodeObject(password, forKey: PropertyKey.passwordKey)
        aCoder.encodeObject(bike, forKey: PropertyKey.bikeKey)
    }
    
    required convenience init(coder aDecoder: NSCoder){
        let firstName = aDecoder.decodeObjectForKey(PropertyKey.firstNameKey) as! String
        let lastName = aDecoder.decodeObjectForKey(PropertyKey.lastNameKey) as! String
        let college = aDecoder.decodeObjectForKey(PropertyKey.collegeKey) as! String
        let email = aDecoder.decodeObjectForKey(PropertyKey.emailKey) as! String
        let password = aDecoder.decodeObjectForKey(PropertyKey.passwordKey) as! String
        let bike = aDecoder.decodeObjectForKey(PropertyKey.bikeKey) as? bikeClass
        
        self.init(firstName: firstName, lastName: lastName, college: college, email: email, password: password, bike: bike)
    }
}
