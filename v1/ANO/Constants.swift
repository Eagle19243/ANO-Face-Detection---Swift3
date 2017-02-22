//
//  Constants.swift
//  ANO
//
//  Created by Mychal Culpepper on 11/17/2016.
//  Copyright © 2016 Blue Shift Group. All rights reserved.
//

import UIKit

let ScreenSize: CGRect = UIScreen.main.bounds
let ScreenWidth = ScreenSize.width
let ScreenHeight = ScreenSize.height
let ApplicationDelegate = UIApplication.shared.delegate as! AppDelegate

public struct Constants
{
    //Strings
    struct Strings
    {
        static let EVENT_TIME_FORMAT = "h:mm a MM/dd/yy"
        static let BIRTHDAY_TIME_FORMAT = "MM-dd-yyyy"
        static let NOTIFICATION_EVENT_UPDATE = "NotificationEventUpdate"
        static let NOTIFICATION_GOL_LOCATION = "NotificationGotLocation"
        static let USER_DEFAULT_KEY: String = "UserDefaultKey"
        static let EVENT_VERSE_TITLE = "ANOVerse"
        static let ANO_PASSWORD = "ANO_PASSWORD"
        static let VERIFY_EMAIL = "We just sent verification email to you.\n Please verify your email to use app."
    }
    
    struct Numbers {
        static let VIDEO_MAX_SEC = 8
        static let EVENT_LIST_DISTANCE = 50000
        static let EVENT_LIVE_DISTANCE = 30
        static let EVENT_LIVE_TIME = 30
        static let EVENT_DESCRIPTION_MAX_LENGHT = 200
        static let PREVIEW_TEXT_MAX_LENGHT = 80
    }
    
    enum MediaType: Int {
        case Photo = 0, Video = 1
    }
    
    struct Arrays {
        static let aryGender = ["👩-female","👦-male"]
        static let aryStatus = ["💚-single", "💛-talking", "❤️-dating"]
    }
    
    struct Errors {
        static let NO_EMAIL = "Please input your email address"
        static let NO_GENDER = "Please choose your gender"
        static let NO_BIRTHDAY = "Please choose your birthday"
        static let NO_RELATION = "Please choose your relation status"
        static let NO_EMAIL_VERIFIED = "Please verify your email address"
    }
}
