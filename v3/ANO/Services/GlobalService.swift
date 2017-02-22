//
//  GlobalService.swift
//  ANO
//
//  Created by Jacob May on 12/30/16.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreLocation

class GlobalService {
    static var _globalService: GlobalService? = nil
    
    static func sharedInstance() -> GlobalService {
        if(_globalService == nil) {
            _globalService = GlobalService()
        }
        
        return _globalService!;
    }
    
    var g_userDeviceToken: String?
    var g_userMe: UserObj?
    var g_appDelegate: AppDelegate?
    var g_homeVC: HomeViewController?
    
    var g_userCLLocation: CLLocation?
    var g_aryLocations = [LocationObj]()
    var g_userCurrentLocation: LocationObj?
    
    var g_aryEvents = [EventObj]()
    var g_objLiveEvent: EventObj?
    
    init() {
        if let path = Bundle.main.path(forResource: "Locations", ofType: "plist") {
            //If your plist contain root as Array
            if let aryLocations = NSArray(contentsOfFile: path) as? [[String: Any]] {
                for location in aryLocations {
                    let objLocation = Mapper<LocationObj>().map(JSON: location)
                    g_aryLocations.append(objLocation!)
                }
            }
        }
    }
    
    func loadUserObj() -> UserObj? {
        let defaults = UserDefaults.standard;
        if let jsonUser = defaults.object(forKey: Constants.UserDefaults.USER_ME) {
            g_userMe = Mapper<UserObj>().map(JSONString: jsonUser as! String)
        } else {
            g_userMe = nil
        }
        
        return g_userMe
    }
    
    func saveUserObj() {
        let defaults = UserDefaults.standard;
        defaults.set(g_userMe?.toJSONString(prettyPrint: true), forKey: Constants.UserDefaults.USER_ME)
        defaults.synchronize()
    }
    
    func dateTransform(format: String) -> DateFormatterTransform {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return DateFormatterTransform(dateFormatter: formatter)
    }
    
    static let intTransform = TransformOf<Int, String>(fromJSON: { (value: String?) -> Int? in
        // transform value from String? to Int?
        return Int(value!)
    }, toJSON: { (value: Int?) -> String? in
        // transform value from Int? to String?
        if let value = value {
            return String(value)
        }
        return nil
    })
    
    static let doubleTransform = TransformOf<Double, String>(fromJSON: { (value: String?) -> Double? in
        // transform value from String? to Int?
        return Double(value!)
    }, toJSON: { (value: Double?) -> String? in
        // transform value from Int? to String?
        if let value = value {
            return String(value)
        }
        return nil
    })
    
    static let boolTransform = TransformOf<Bool, String>(fromJSON: { (value: String?) -> Bool? in
        return value == "1"
    }, toJSON: { (value: Bool?) -> String? in
        return value! ? "1" : "0"
    })
    
    func makeVerificationCode() -> String {
        var strCode = ""
        for _ in 0 ..< 4 {
            let nCode = arc4random() % 10
            strCode = "\(strCode)\(nCode)"
        }
        
        return strCode
    }
    
    func updateUserLocation(_ UserLocation: CLLocation) {
        g_userCLLocation = UserLocation
        g_userCurrentLocation = nil
        
        // get user location
        for location in g_aryLocations {
            let coreLocation = CLLocation(latitude: location.location_latitude!, longitude: location.location_longitude!)
            let fDistance = coreLocation.distance(from: UserLocation)
            
            // check event distance
            if fDistance < Double(Constants.Numbers.EVENT_LIST_DISTANCE) {
                g_userCurrentLocation = location
                break
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Notifications.GET_USER_LOCATION), object: nil)
        
        if g_userMe != nil {
            // get all valid events
            WebService.sharedInstance().getActiveEvents
                { (aryEvents, error) in
                    if let error = error {
                        print(error)
                    } else {
                        self.g_aryEvents = aryEvents!
                        self.g_objLiveEvent = aryEvents?[0]
                        
                        for objEvent in aryEvents! {
                            let coreLocation = CLLocation(latitude: objEvent.event_latitude!, longitude: objEvent.event_longitude!)
                            let fDistance = coreLocation.distance(from: UserLocation)
                            
                            // check event distance
                            if fDistance < Double(Constants.Numbers.EVENT_LIVE_DISTANCE) {
                                // check event time
                                if (objEvent.event_time?.timeIntervalSinceNow)! < Double(Constants.Numbers.EVENT_LIVE_TIME) {
                                    self.g_objLiveEvent = objEvent
                                    
                                    break
                                }
                            }
                        }
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Notifications.GET_EVENTS), object: nil)
                    }
            }
        }
    }
}
