//
//  EventTableViewCell.swift
//  ANO
//
//  Created by Jacob May on 11/18/16.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit
import CoreLocation

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var m_imgPhoto: UIImageView!
    @IBOutlet weak var m_lblTitle: UILabel!
    @IBOutlet weak var m_lblTime: UILabel!
    @IBOutlet weak var m_lblDistance: UILabel!
    @IBOutlet weak var m_imgUber: UIImageView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setViewsWithEvent(event: EventObj) {
        self.m_imgPhoto.kf.setImage(with: URL(string: Constants.Server.PHOTO_URL + event.event_photo_url!))
        
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.Strings.EVENT_TIME_FORMAT
        self.m_lblTime.text = formatter.string(from: event.event_time!)
        
        let coreLocation = CLLocation(latitude: event.event_latitude!, longitude: event.event_longitude!)
        let fDistance = coreLocation.distance(from: GlobalService.sharedInstance().g_userCLLocation!)
        if fDistance < 1000 {
            self.m_lblDistance.text = String(format: "%d m", Int(fDistance))
        } else {
            self.m_lblDistance.text = String(format: "%.1f Km", fDistance / 1000)
        }
    
        self.m_lblTitle.text = event.event_name
        self.m_imgUber.isHidden = !event.event_enable_uber
        
        // check event type
        if event.event_user_id == GlobalService.sharedInstance().g_userMe?.user_id
            || event.event_type == "PUBLIC" {
            self.m_lblTime.isHidden = false
            self.m_lblDistance.isHidden = false
            self.m_lblTitle.isHidden = false
        } else if event.event_type == "SEMI-PUBLIC" {
            self.m_lblTime.isHidden = true
            self.m_lblDistance.isHidden = true
            self.m_lblTitle.isHidden = false
        } else {
            self.m_lblTime.isHidden = true
            self.m_lblDistance.isHidden = true
            self.m_lblTitle.isHidden = false
            
            let imgLock = NSTextAttachment()
            imgLock.image = UIImage(named: "event_icon_lock")
            self.m_lblTitle.attributedText = NSAttributedString(attachment: imgLock)
        }
    }
}
