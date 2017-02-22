//
//  Constants.swift
//  ANO
//
//  Created by Mychal Culpepper on 11/17/2016.
//  Copyright © 2016 Blue Shift Group. All rights reserved.
//

import UIKit

public struct Constants
{
    //Strings
    struct Strings
    {
        static let ANO_EMAIL_SURFIX = "@ano.com"
        static let USER_DEFAULT_KEY = "UserDefaultKey"
        static let NOTIFICATION_EVENT_UPDATE = "NotificationEventUpdate"
        static let NOTIFICATION_GOL_LOCATION = "NotificationGotLocation"
        static let EVENT_VERSE_TITLE = "ANOVerse"
        static let EVENT_TIME_FORMAT = "h:mm a MM/dd/yy"
    }
    
    struct Numbers {
        static let PASSWORD_LENGTH = 6
        static let VIDEO_MAX_SEC = 8
        static let EVENT_LIST_DISTANCE = 50000
        static let EVENT_LIVE_DISTANCE = 1000
        static let EVENT_LIVE_TIME = 30
        static let EVENT_DESCRIPTION_MAX_LENGHT = 200
    }
    
    enum MediaType: Int {
        case Photo = 0, Video = 1
    }
    
    struct Errors {
        static let NO_USERNAME = "Please input your username"
        static let SHORT_PASSWORD = "Password should be 6 characters at least."
        static let NO_EMAIL = "Please input your email address"
    }
}
