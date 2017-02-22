//
//  EventTableViewCell.swift
//  ANO
//
//  Created by Jacob May on 11/18/16.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit
import SDWebImage

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var m_imgPhoto: UIImageView!
    @IBOutlet weak var m_lblTitle: UILabel!
    @IBOutlet weak var m_lblTime: UILabel!
    @IBOutlet weak var m_lblDistance: UILabel!
    @IBOutlet weak var userEnabledUber: UIImageView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setViewsWithEvent(event: Event) {
        if event.eventTitle == Constants.Strings.EVENT_VERSE_TITLE {
            self.m_imgPhoto.image = UIImage(named: "image_verse_event")
            self.m_lblTime.text = "00:00"
            self.m_lblDistance.text = "0 Km"
        } else {
            self.m_imgPhoto.sd_setImage(with: URL(string: event.eventImageUrl!))           
            
            let formatter = DateFormatter()
            formatter.dateFormat = Constants.Strings.EVENT_TIME_FORMAT
            self.m_lblTime.text = formatter.string(from: event.eventTime!)
            self.m_lblDistance.text = String(format: "%.1f Km", event.eventDistance! / 1000)
        }
        self.m_lblTitle.text = event.eventTitle
        userEnabledUber.isHidden = !(event.eventUberEnabled)!
    }
}
