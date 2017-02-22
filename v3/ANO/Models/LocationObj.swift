//
//  LocationObj.swift
//  ANO
//
//  Created by Jacob May on 1/4/17.
//  Copyright © 2017 DMSoft. All rights reserved.
//

import UIKit
import ObjectMapper

class LocationObj: Mappable {
    var location_address        : String?
    var location_latitude       : Double?
    var location_longitude      : Double?
    var location_icon           : String?
    var location_universities   : [UniversityObj]?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        location_address        <- map["Address"]
        location_latitude       <- map["Latitude"]
        location_longitude      <- map["Longitude"]
        location_icon           <- map["Icon"]
        location_universities   <- map["Universities"]
    }
}

class UniversityObj: Mappable {
    var university_email        : String?
    var university_icon         : String?
    var university_name         : String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        university_email    <- map["Email"]
        university_icon     <- map["Icon"]
        university_name     <- map["Name"]
    }
}
