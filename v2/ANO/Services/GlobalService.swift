//
//  GlobalService.swift
//  ANO
//
//  Created by Mychal Culpepper on 11/18/16.
//  Copyright © 2016 Blue Shift Group. All rights reserved.
//

import UIKit
import CoreLocation

class GlobalService {
    static let sharedInstance = GlobalService()
    
    var aryEvents = [Event]()
    var aryLocations = [Location]()
    var userLocation: CLLocation?
    var cameraVC: UIViewController?
    
    func getLiveEvent() -> Event? {
        var liveEvent: Event?
        
        //check live event
        for event in aryEvents {
            //check distance
            let eventLocation = CLLocation(latitude: event.eventLatitude!, longitude: event.eventLongitude!)
            if eventLocation.distance(from: userLocation!) < Double(Constants.Numbers.EVENT_LIVE_DISTANCE) {
                //check time
                if Int(event.eventTime!.timeIntervalSinceNow) < Constants.Numbers.EVENT_LIVE_TIME * 60 {
                    liveEvent = event
                    break
                }
            }
        }
        
        return liveEvent
    }
    
    func getMyUniversity() -> Location? {
        var myUniversity: Location?
        
        if userLocation != nil {
            //get neareast location
            for location in aryLocations {
                let objLocation = CLLocation(latitude: location.locationLatitude!, longitude: location.locationLongitude!)
                
                let fDistance = objLocation.distance(from: GlobalService.sharedInstance.userLocation!)
                // check event distance
                if fDistance < Double(Constants.Numbers.EVENT_LIST_DISTANCE) {
                    myUniversity = location
                    break
                }
            }
            
            if myUniversity == nil {
                myUniversity = aryLocations[0]
            }
        }
        
        return myUniversity
    }
}
