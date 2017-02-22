//
//  AppDelegate.swift
//  ANO
//
//  Created by Jacob May on 12/28/16.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit
import UserNotifications
import SVProgressHUD
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //UserNotification
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            // Enable or disable features based on authorization.
            if granted {
                UIApplication.shared.registerForRemoteNotifications()
            } else {
                print("Don't Allow")
            }
        }
        
        //SVProgressHUD
        SVProgressHUD.setDefaultStyle(.dark)
        
        //Check UserObj
        GlobalService.sharedInstance().g_appDelegate = self
        if let userObj = GlobalService.sharedInstance().loadUserObj() {
            GlobalService.sharedInstance().g_userMe = userObj
            startApplication(animated: false)
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block:{(timer) in
            self.locationManager.startUpdatingLocation()
        })
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        GlobalService.sharedInstance().g_userDeviceToken = deviceTokenString
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        GlobalService.sharedInstance().g_userDeviceToken = ""
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptivar (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.last {
            GlobalService.sharedInstance().updateUserLocation(userLocation)
            manager.stopUpdatingLocation()
        }
    }
    
    func startApplication(animated: Bool) {
        let mainNC = window?.rootViewController as! UINavigationController
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        let homeVC = storyboard.instantiateViewController(withIdentifier: String(describing: HomeViewController.self)) as! HomeViewController
        GlobalService.sharedInstance().g_homeVC = homeVC
        mainNC.pushViewController(homeVC, animated: animated)
    }
}

