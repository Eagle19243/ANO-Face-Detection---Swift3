//
//  ANOButton.swift
//  ANO
//
//  Created by Jacob May on 17/11/2016.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit

@IBDesignable class ANOButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
            setLayout ()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
            setLayout ()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            setLayout ()
        }
    }
    
    @IBInspectable var verticalAlign: Bool = false {
        
        didSet {
            
            setLayout()
        }
    }
    
    @IBInspectable var verticalSpace: CGFloat = 6.0 {
        
        didSet {
            
            setLayout()
        }
    }
    
    func setLayout () {
        
        if verticalAlign {
            
            let imageSize = self.imageView?.frame.size
            let titleSize = self.titleLabel?.frame.size
            let totalHeight = ((imageSize?.height)! + (titleSize?.height)! + verticalSpace);
            
            self.imageEdgeInsets = UIEdgeInsetsMake(-(totalHeight - (imageSize?.height)!),
                                                    0.0,
                                                    0.0,
                                                    -(titleSize?.width)!)
            
            self.titleEdgeInsets = UIEdgeInsetsMake(0.0,
                                                    -(imageSize?.width)!,
                                                    -(totalHeight - (titleSize?.height)!),
                                                    0.0)
        }
    }
}
