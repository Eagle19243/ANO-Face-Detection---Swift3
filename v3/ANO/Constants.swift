//
//  Constants.swift
//  ANO
//
//  Created by Jacob May on 1/3/17.
//  Copyright © 2017 DMSoft. All rights reserved.
//

import UIKit

class Constants {
    struct Server {
        static let URL                  = "http://35.165.232.110/api/v1"
        static let RESPONSE_MESSAGE     = "message"
        static let PHOTO_URL            = "http://35.165.232.110/api/assets/images/"
        static let VIDEO_URL            = "http://35.165.232.110/api/assets/videos/"
    }
    
    struct Toasts {
        static let NO_USERNAME          = "Please input username"
        static let SHORT_PASSWORD       = "Password should be 6 characters at least"
        static let DISMATCH_PASSWORD    = "Dismatch password"
    }
    
    struct UserDefaults {
        static let USER_ME              = "UserDefaultsUserMe"
        static let USER_ACCESS_TOKEN    = "UserDefaultsAccessToken"
    }
    
    struct Notifications {
        static let GET_EVENTS           = "NotificationGetEvents"
        static let GET_USER_LOCATION    = "NotificationGetUserLocation"
    }
    
    struct Numbers {
        static let PASSWORD_LENGTH      = 6
        static let VIDEO_MAX_SEC        = 8
        static let EVENT_LIST_DISTANCE  = 50000
        static let EVENT_LIVE_DISTANCE  = 300
        static let EVENT_LIVE_TIME      = 30 * 60 // (30 minutes)
        static let VIBE_MAX_LENGTH      = 50
    }
    
    struct Arrays {
        static let aryGender            = ["👩-female","👦-male"]
        static let aryStatus            = ["💚-single", "💛-talking", "❤️-dating"]
    }
    
    struct Strings {
        static let BIRTHDAY_TIME_FORMAT = "MM-dd-yyyy"
        static let EVENT_TIME_FORMAT    = "h:mm a MM/dd/yy"
    }
}
