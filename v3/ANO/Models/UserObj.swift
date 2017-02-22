//
//  UserObj.swift
//  ANO
//
//  Created by Jacob May on 1/4/17.
//  Copyright © 2017 DMSoft. All rights reserved.
//

import UIKit
import ObjectMapper

class UserObj: Mappable {
    var user_id             : Int?
    var user_name           : String?
    var user_phone          : String?
    var user_gender         : String?
    var user_birthday       : Date?
    var user_stats          : String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        user_id             <- (map["user_id"], GlobalService.intTransform)
        user_name           <- map["user_name"]
        user_phone          <- map["user_phone"]
        user_gender         <- map["user_gender"]
        user_birthday       <- (map["user_birthday"], GlobalService.sharedInstance().dateTransform(format: "yyyy-MM-dd"))
        user_stats          <- map["user_stats"]
    }    
}
