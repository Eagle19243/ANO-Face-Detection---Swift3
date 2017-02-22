//
//  Event.swift
//  ANO
//
//  Created by Mychal Culpepper on 11/17/2016.
//  Copyright © 2016 Blue Shift Group. All rights reserved.
//

import UIKit

enum EVENT_TYPE: Int {
    case PUBLIC = 1, SEMI_PUBLIC = 2, PRIVATE = 0
}

class Event: NSObject {
    var eventID: String?
    var eventCreatorID: String?
    var eventImageUrl: String?
    var eventTitle: String?
    var eventTime: Date?
    var eventDescription: String?
    var eventLatitude: Double?
    var eventLongitude: Double?
    var eventAddress: String?
    var eventDistance: Double?
    var eventUberEnabled: Bool?
    var eventHost: String?
    var eventType: EVENT_TYPE?
    
    override init()
    {
        super.init()
    }
    
    init(key: String, json: [String : Any])
    {
        eventID = key
        eventCreatorID = json["creatorID"] as? String
        eventImageUrl = json["imageUrl"] as? String
        eventTitle = json["title"] as? String
        
        if let startTime = json["time"] {
            let formatter = DateFormatter()
            formatter.dateFormat = Constants.Strings.EVENT_TIME_FORMAT
            eventTime = formatter.date(from: startTime as! String)
        }
        
        eventDescription = json["description"] as? String
        eventLatitude = json["latitude"] as? Double
        eventLongitude = json["longitude"] as? Double
        eventAddress = json["address"] as? String
        eventUberEnabled = json["uberEnabled"] as? Bool
        eventHost = json["host"] as? String
        eventType = json["type"] as? EVENT_TYPE ?? EVENT_TYPE.PUBLIC
    }
    
    func initVerseEvent() -> Event {
        let eventVerse = Event()
        eventVerse.eventID = "0"
        eventVerse.eventTitle = Constants.Strings.EVENT_VERSE_TITLE
        eventVerse.eventUberEnabled = false
        eventVerse.eventType = .PUBLIC
        
        return eventVerse
    }
}
