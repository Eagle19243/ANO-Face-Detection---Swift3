//
//  ANOVideoOverlay.swift
//  ANO
//
//  Created by Jacob May on 12/14/16.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit
import SCRecorder

class ANOVideoOverlay: UIView, SCVideoOverlay {
    
    @IBOutlet weak var m_lblUsername: UILabel!
    
    var m_overlayText: UITextField?

    override func layoutSubviews() {
        super.layoutSubviews()
        let size = self.bounds.size
        let factor = size.width / UIScreen.main.bounds.size.width
        if let overlayText = m_overlayText {
            var frame = overlayText.frame
            frame.size.width *= factor
            frame.size.height *= factor
            frame.origin.y *= factor
            overlayText.frame = frame
            
            overlayText.font = UIFont(name: overlayText.font!.fontName, size: (overlayText.font?.pointSize)! * factor)
        }
        
        m_lblUsername.font = UIFont(name: m_lblUsername.font!.fontName, size: 15 * factor)
        m_lblUsername.sizeToFit()
        var frame = m_lblUsername.frame
        frame.origin.x = size.width - frame.width - 15 * factor
        frame.origin.y = 15 * factor
        m_lblUsername.frame = frame
    }
}
