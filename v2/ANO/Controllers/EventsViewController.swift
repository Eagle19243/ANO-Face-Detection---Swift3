//
//  EventsViewController.swift
//  ANO
//
//  Created by Jacob May on 12/14/16.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit
import BetterSegmentedControl
import CoreLocation
import SVProgressHUD

class EventsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var videoUrl: String?
    var imageUrl: String?
    var mediaType: Constants.MediaType?
    
    @IBOutlet weak var m_segEvent: BetterSegmentedControl!
    @IBOutlet weak var m_btnCreateEvent: UIButton!
    @IBOutlet weak var m_tblEvents: UITableView!
    
    var aryEvents = [Event]()
    var aryMyEvents = [Event]()
    var isFirstEventUpdate = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        m_segEvent.titles = ["Events", "My Event"]
        
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
        aryMyEvents.removeAll()
        
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
                    
                    if event.eventCreatorID == User.currentUser?.userID {
                        aryMyEvents.append(event)
                    }
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
    
    @IBAction func onChangedSegment(_ sender: Any) {
        m_btnCreateEvent.isHidden = m_segEvent.index == 0
        m_tblEvents.reloadData()
    }
    
    @IBAction func onClickBtnCamera(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func onClickBtnCreateEvent(_ sender: Any) {
        let eventCameraVC = self.storyboard?.instantiateViewController(withIdentifier: "EventCameraViewController") as! EventCameraViewController
        self.navigationController?.pushViewController(eventCameraVC, animated: false)
    }
    
    //UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if m_segEvent.index == 0 {
            return aryEvents.count
        } else {
            return aryMyEvents.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var event: Event!
        
        if m_segEvent.index == 0 {
            event = aryEvents[indexPath.row]
        } else {
            event = aryMyEvents[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell") as! EventTableViewCell
        cell.setViewsWithEvent(event: event)
        
        return cell
    }
    
    //UITableViewDelegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var event: Event!
        
        if m_segEvent.index == 0 {
            event = aryEvents[indexPath.row]
        } else {
            event = aryMyEvents[indexPath.row]
        }
        
        if videoUrl != nil || imageUrl != nil {
            SVProgressHUD.show(withStatus: "Saving Feed...")
            FirebaseService.sharedInstance.addMediaToFeed(eventID: event.eventID!,
                                                          videoUrl: videoUrl!,
                                                          imageUrl: imageUrl!,
                                                          mediaType: mediaType!) {(error) in
                                                            if error != nil {
                                                                SVProgressHUD.showError(withStatus: error)
                                                            } else {
                                                                SVProgressHUD.dismiss()
                                                                let displayVC = self.storyboard?.instantiateViewController(withIdentifier: "DisplayViewController") as! DisplayViewController
                                                                displayVC.m_selectedEvent = event
                                                                self.navigationController?.pushViewController(displayVC, animated: true)
                                                            }
            }
        } else {
            let displayVC = self.storyboard?.instantiateViewController(withIdentifier: "DisplayViewController") as! DisplayViewController
            displayVC.m_selectedEvent = event
            self.navigationController?.pushViewController(displayVC, animated: true)
        }
    }
}
