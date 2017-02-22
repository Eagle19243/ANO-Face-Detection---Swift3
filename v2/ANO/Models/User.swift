//
//  User.swift
//  ANO
//
//  Created by Mychal Culpepper on 11/17/2016.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit

class User: NSObject {
    var userID: String?
    var userName: String?
    var userEmail: String?
    var userEmailVerified = false
    var userEventID: String?
    
    static var currentUser: User?
        {
        get
        {
            let userDefaults = UserDefaults.standard
            if let userDict = userDefaults.dictionary(forKey: Constants.Strings.USER_DEFAULT_KEY)
            {
                return User(json: userDict)
            }
            
            return nil
        }
        
        set
        {
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue?.currentDictionary(), forKey: Constants.Strings.USER_DEFAULT_KEY)
            userDefaults.synchronize()
        }
    }
    
    override init()
    {
        super.init()
    }
    
    init(json: [String : Any])
    {
        userID = json["id"] as? String
        userName = json["username"] as? String
        userEmail = json["email"] as? String
        userEmailVerified = json["emailVerified"] as? Bool ?? false
        
        userEventID = json["eventID"] as? String
    }
    
    func currentDictionary() -> [String : Any] {
        return [
            "id": userID!,
            "username": userName!,
            "email": userEmail ?? "",
            "emailVerified": userEmailVerified,
            
            "eventID": userEventID ?? "0"
        ]
    }
}
