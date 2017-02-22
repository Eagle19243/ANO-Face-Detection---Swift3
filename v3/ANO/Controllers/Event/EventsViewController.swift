//
//  EventsViewController.swift
//  ANO
//
//  Created by Jacob May on 1/4/17.
//  Copyright © 2017 DMSoft. All rights reserved.
//

import UIKit
import BetterSegmentedControl

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var m_segEvent: BetterSegmentedControl!
    @IBOutlet weak var m_btnCreateEvent: UIButton!
    @IBOutlet weak var m_tblEvents: UITableView!
    
    var m_aryEvents = [EventObj]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        m_segEvent.titles = ["Verse", "My Verse"]
        
        m_tblEvents.rowHeight = UITableViewAutomaticDimension
        m_tblEvents.estimatedRowHeight = 110
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onUpdatedEvents),
                                               name: NSNotification.Name(rawValue: Constants.Notifications.GET_EVENTS),
                                               object: nil)
    }
    
    func onUpdatedEvents() {
        onChangedSegment(m_segEvent)
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
        
        m_aryEvents = [EventObj]()
        for objEvent in GlobalService.sharedInstance().g_aryEvents {
            if objEvent.event_id == 1 {
                continue
            }
            
            if m_segEvent.index == 0 {  // Verse
                if objEvent.event_user_id != GlobalService.sharedInstance().g_userMe?.user_id
                    && !checkEventUser(Users: objEvent.event_users, UserId: (GlobalService.sharedInstance().g_userMe?.user_id)!) {
                    m_aryEvents.append(objEvent)
                }
            } else {    // My Verse
                if objEvent.event_user_id == GlobalService.sharedInstance().g_userMe?.user_id
                    || checkEventUser(Users: objEvent.event_users, UserId: (GlobalService.sharedInstance().g_userMe?.user_id)!) {
                    m_aryEvents.append(objEvent)
                }
            }
        }
        
        m_tblEvents.reloadData()
    }
    
    func checkEventUser(Users: [UserObj]?, UserId: Int) -> Bool {
        var isResult = false
        
        if let aryUsers = Users {
            for objUser in aryUsers {
                if objUser.user_id == UserId {
                    isResult = true
                    break
                }
            }
        }
        return isResult
    }
    
    //UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_aryEvents.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let objEvent = m_aryEvents[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventTableViewCell.self)) as! EventTableViewCell
        cell.setViewsWithEvent(event: objEvent)
        
        return cell
    }
}
