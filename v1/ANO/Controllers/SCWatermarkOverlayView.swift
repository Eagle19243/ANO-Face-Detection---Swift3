//
//  VideoOverlay.swift
//  ANO
//
//  Created by Mychal Culpepper on 11/10/16.
//  Copyright © 2016 Blue Shift Group. All rights reserved.
//
import UIKit
import SCRecorder

class SCWatermarkOverlayView: UIView, SCVideoOverlay {
    var watermarkImage: UIImageView!
    var videoTextView: UITextView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.watermarkImage = UIImageView()
        self.watermarkImage.image = UIImage(named: "icon_overlay")
        self.watermarkImage.contentMode = .scaleAspectFit
        self.watermarkImage.clipsToBounds = true
        self.watermarkImage.alpha = 0.5
        self.addSubview(watermarkImage)
        
        
        self.videoTextView = UITextView()
         self.videoTextView.autocorrectionType = .no
        self.videoTextView.frame = CGRect(x: 10, y: 10, width: ScreenWidth, height: ScreenHeight)
        self.videoTextView.text = "Here we go"
        self.addSubview(videoTextView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.sync(){
            let inset: CGFloat = 8
            let size = self.bounds.size
            watermarkImage.sizeToFit()
            var watermarkFrame = watermarkImage.frame
            watermarkFrame.origin.x = size.width - watermarkFrame.size.width - inset
            watermarkFrame.origin.y = size.height - watermarkFrame.size.height - inset
            watermarkImage.frame = watermarkFrame
            
            let factor = size.width / ScreenWidth
            if (videoTextView != nil) {
                var textViewFrame = videoTextView.frame
                textViewFrame.size.width *= factor
                textViewFrame.size.height *= factor
                textViewFrame.origin.y *= factor
                videoTextView.frame = textViewFrame
                
                videoTextView.font = UIFont(name: videoTextView.font!.fontName, size: (videoTextView.font?.pointSize)! * factor)
            }
        }
    }
}
