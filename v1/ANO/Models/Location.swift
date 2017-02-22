//
//  Location.swift
//  ANO
//
//  Created by Jacob May on 11/30/16.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit

class University: NSObject {
    var universityName: String?
    var universityEmail: String?
    var universityLogo: String?
    
    override init()
    {
        super.init()
    }
    
    init(json: [String : Any])
    {
        universityName = json["name"] as? String
        universityEmail = json["email"] as? String
        universityLogo = json["logo"] as? String
    }
}

class Location: NSObject {
    var locationAddress: String?
    var locationLatitude: Double?
    var locationLongitude: Double?
    var aryUniversities: [University]?
    
    override init()
    {
        super.init()
    }
    
    init(json: [String : Any])
    {
        locationAddress = json["address"] as? String
        locationLatitude = json["latitude"] as? Double
        locationLongitude = json["longitude"] as? Double
        
        aryUniversities = [University]()
        
        let dicUniversities = json["Universities"] as? [String: Any]
        for key in (dicUniversities?.keys)! {
            aryUniversities?.append(University(json: dicUniversities?[key] as! [String: Any]))
        }
    }
}
