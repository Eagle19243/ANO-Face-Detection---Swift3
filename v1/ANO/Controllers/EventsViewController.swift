//
//  EventsViewController.swift
//  ANO
//
//  Created by Mychal Culpepper on 11/18/16.
//  Copyright © 2016 Blue Shift Group. All rights reserved.
//

import UIKit
import CoreLocation
import SVProgressHUD

class EventsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var returnToCamButton: UIButton!
    @IBAction func returnToCam(_ sender: UIButton) {
        let cameraVC = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController")
        GlobalService.sharedInstance.cameraVC = cameraVC
        self.navigationController?.pushViewController(cameraVC!, animated: true)
    }
    
    var isStill17 = false
    @IBOutlet weak var m_tblEvents: UITableView!
    
    var videoUrl: String?
    var imageUrl: String?
    var mediaType: Constants.MediaType?
    
    var aryEvents = [Event]()
    var isFirstEventUpdate = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        m_tblEvents.rowHeight = UITableViewAutomaticDimension
        m_tblEvents.estimatedRowHeight = 110
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onUpdatedEvents),
                                               name: NSNotification.Name(rawValue: Constants.Strings.NOTIFICATION_EVENT_UPDATE),
                                               object: nil)
        
        sort50KMEvents()
    }
    
    func onUpdatedEvents(notification: Notification) {
        sort50KMEvents()
    }
    
    func sort50KMEvents() {
        aryEvents.removeAll()
        
        for event in GlobalService.sharedInstance.aryEvents {
            let eventLocation = CLLocation(latitude: event.eventLatitude!, longitude: event.eventLongitude!)
            let fDistance = eventLocation.distance(from: GlobalService.sharedInstance.userLocation!)
            
            // check event distance
            if fDistance < Double(Constants.Numbers.EVENT_LIST_DISTANCE) {
                // check event time
                let eventEndTime = event.eventTime?.addingTimeInterval(24 * 60 * 60)
                if eventEndTime?.compare(Date()) == .orderedDescending {
                    event.eventDistance = fDistance
                    aryEvents.append(event)
                }
            }
        }
        
        if aryEvents.count == 0 {
            if isFirstEventUpdate {
                isFirstEventUpdate = false
                
                let alertController = UIAlertController(title: "ANO",
                                                        message: "It appears no events are currently live yet. Select an event you would like to attend",
                                                        preferredStyle: .alert)
                let acceptAction = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(acceptAction)
                
                self.present(alertController, animated: true)
            }
            
            aryEvents.append(Event().initVerseEvent())
        }
        
        self.m_tblEvents.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    //UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryEvents.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell") as! EventTableViewCell
        cell.setViewsWithEvent(event: aryEvents[indexPath.row])
        
        return cell
    }
    
    //UITableViewDelegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isStill17 == true{
            let alertController = UIAlertController(title: "Sorry", message: "You must be 18 to view this material", preferredStyle: .alert)
            let acceptAction = UIAlertAction(title: "OK", style: .default)
            self.present(alertController, animated: true)
            alertController.addAction(acceptAction)
        }
        
        let selectedEvent = aryEvents[indexPath.row]
        if videoUrl != nil || imageUrl != nil {
            SVProgressHUD.show(withStatus: "Saving Feed...")
            FirebaseService.sharedInstance.addMediaToFeed(eventID: selectedEvent.eventID!,
                                                          videoUrl: videoUrl!,
                                                          imageUrl: imageUrl!,
                                                          mediaType: mediaType!) {(error) in
                                                            if error != nil {
                                                                SVProgressHUD.showError(withStatus: error)
                                                            } else {
                                                                SVProgressHUD.dismiss()
                                                                let displayVC = self.storyboard?.instantiateViewController(withIdentifier: "DisplayViewController") as! DisplayViewController
                                                                displayVC.m_selectedEvent = selectedEvent
                                                                self.navigationController?.pushViewController(displayVC, animated: true)
                                                            }
            }
        } else {
            let displayVC = self.storyboard?.instantiateViewController(withIdentifier: "DisplayViewController") as! DisplayViewController
            displayVC.m_selectedEvent = selectedEvent
            self.navigationController?.pushViewController(displayVC, animated: true)
        }
    }
}
