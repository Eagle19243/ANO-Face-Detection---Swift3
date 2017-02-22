//
//  UniversityView.swift
//  ANO
//
//  Created by Jacob May on 11/30/16.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit
import SDWebImage

class UniversityView: UIView {

    @IBOutlet weak var m_imgLogo: UIImageView!
    @IBOutlet weak var m_lblName: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func setViewsWithUniversity(university: University) {
        m_imgLogo.sd_setImage(with: URL(string: university.universityLogo!))
        m_lblName.text = university.universityName
    }
}
