//
//  EventObj.swift
//  ANO
//
//  Created by Jacob May on 1/5/17.
//  Copyright © 2017 DMSoft. All rights reserved.
//

import UIKit
import ObjectMapper

class EventObj: Mappable {
    var event_id                : Int?
    var event_user_id           : Int?
    var event_photo_url         : String?
    var event_name              : String?
    var event_description       : String?
    var event_latitude          : Double?
    var event_longitude         : Double?
    var event_time              : Date?
    var event_enable_uber = false
    var event_type              : String?
    var event_email             : String?
    var event_email_verified = false
    var event_created_at        : Date?
    var event_medias            : [MediaObj]?
    var event_vibes             : [VibeObj]?
    var event_users             : [UserObj]?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        event_id                <- (map["event_id"], GlobalService.intTransform)
        event_user_id           <- (map["event_user_id"], GlobalService.intTransform)
        event_photo_url         <- map["event_photo_url"]
        event_name              <- map["event_name"]
        event_description       <- map["event_description"]
        event_latitude          <- (map["event_latitude"], GlobalService.doubleTransform)
        event_longitude         <- (map["event_longitude"], GlobalService.doubleTransform)
        event_time              <- (map["event_time"], GlobalService.sharedInstance().dateTransform(format: "yyyy-MM-dd HH:mm:ss"))
        event_enable_uber       <- (map["event_enable_uber"], GlobalService.boolTransform)
        event_type              <- map["event_type"]
        event_email             <- map["event_email"]
        event_email_verified    <- (map["event_email_verified"], GlobalService.boolTransform)
        event_created_at        <- (map["event_created_at"], GlobalService.sharedInstance().dateTransform(format: "yyyy-MM-dd HH:mm:ss"))
        event_medias            <- map["event_medias"]
        event_vibes             <- map["event_vibes"]
    }
}

class MediaObj: Mappable {
    var media_id        : Int?
    var media_user_id   : Int?
    var media_video_url : String?
    var media_photo_url : String?
    var media_type      : String?
    var media_is_read = false
    var media_created_at: Date?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        media_id            <- (map["media_id"], GlobalService.intTransform)
        media_user_id       <- (map["media_user_id"], GlobalService.intTransform)
        media_video_url     <- map["media_video_url"]
        media_photo_url     <- map["media_photo_url"]
        media_type          <- map["media_type"]
        media_is_read       <- map["media_is_read"]
        media_created_at    <- (map["media_created_at"], GlobalService.sharedInstance().dateTransform(format: "yyyy-MM-dd HH:mm:ss"))
    }
}

class VibeObj: Mappable {
    var vibe_id         : Int?
    var vibe_event_id   : Int?
    var vibe_text       : String?
    var vibe_created_at : Date?
    var vibe_likes: Int = 0
    var vibe_dislikes: Int = 0
    var vibe_is_vote = false
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        vibe_id             <- (map["vibe_id"], GlobalService.intTransform)
        vibe_event_id       <- (map["vibe_event_id"], GlobalService.intTransform)
        vibe_text           <- map["vibe_text"]
        vibe_created_at     <- (map["vibe_created_at"], GlobalService.sharedInstance().dateTransform(format: "yyyy-MM-dd HH:mm:ss"))
        vibe_likes          <- (map["vibe_likes"], GlobalService.intTransform)
        vibe_dislikes       <- (map["vibe_dislikes"], GlobalService.intTransform)
        vibe_is_vote        <- map["vibe_is_vote"]
    }
}
