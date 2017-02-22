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
    var userLocation: CLLocation?
    var cameraVC: UIViewController?
}
