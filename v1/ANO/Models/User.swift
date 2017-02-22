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
    var userEventID: String?
    var userGender: String?
    var userBirthday: String?
    var userRealStatus: String?
    
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
        userEventID = json["eventID"] as? String
        userGender = json["gender"] as? String
        userBirthday = json["birthday"] as? String
        userRealStatus = json["realStatus"] as? String
    }
    
    func currentDictionary() -> [String : Any] {
        return [
            "id": userID!,
            "eventID": userEventID ?? "0",
            "gender": userGender!,
            "birthday": userBirthday!,
            "realStatus": userRealStatus!
        ]
    }
}
