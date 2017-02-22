//
//  Feed.swift
//  ANO
//
//  Created by Mychal Culpepper on 11/19/16.
//  Copyright © 2016 Blue Shift Group. All rights reserved.
//

import UIKit

class Feed: NSObject {
    var feedID: String?
    var feedUserID: String?
    var feedEventID: String?
    var feedVideoUrl: String?
    var feedImageUrl: String?
    var feedMediaType: Constants.MediaType?
    var feedCreatedAt: String?
    
    override init()
    {
        super.init()
    }
    
    init(key: String, json: [String : Any])
    {
        feedID = key
        feedUserID = json["userID"] as? String
        feedEventID = json["eventID"] as? String
        feedVideoUrl = json["videoUrl"] as? String
        feedImageUrl = json["imageUrl"] as? String
        feedMediaType = (json["mediaType"] as? Int) == 0 ? Constants.MediaType.Photo : Constants.MediaType.Video
        feedCreatedAt = json["createdAt"] as? String
    }
}
