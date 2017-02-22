//
//  LocationView.swift
//  ANO
//
//  Created by Jacob May on 12/15/16.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit
import iCarousel
import SVProgressHUD
import FirebaseAuth

protocol LocationViewDelegate: class {
    func sendCloseRequestWithResult(result: Bool);
}

class LocationView: UIView, iCarouselDelegate, iCarouselDataSource {

    @IBOutlet weak var m_viewCarousel: iCarousel!
    @IBOutlet weak var m_txtEmail: UITextField!
    @IBOutlet weak var m_lblEmailKind: UILabel!

    weak var delegate: LocationViewDelegate?
    var m_userLocation: Location?
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        m_viewCarousel.type = .rotary
        m_userLocation = GlobalService.sharedInstance.getMyUniversity()
        if m_userLocation != nil {
            m_viewCarousel.delegate = self
            m_viewCarousel.dataSource = self
            self.m_lblEmailKind.text = self.m_userLocation?.aryUniversities?[0].universityEmail
            self.m_viewCarousel.reloadData()
        }
    }
    
    //pragma mark - iCarouselDataSource
    func numberOfItems(in carousel: iCarousel) -> Int {
        return (m_userLocation?.aryUniversities?.count)!
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let university = m_userLocation?.aryUniversities?[index]
        
        let view: UniversityView = Bundle.main.loadNibNamed("UniversityView", owner: nil, options: nil)?.first as! UniversityView
        view.frame = CGRect(x: 0, y: 0, width: carousel.frame.size.height - 60, height: carousel.frame.size.height)
        view.setViewsWithUniversity(university: university!)
        
        return view
    }
    
    //pragma mark - iCarouselDelegate
    func carouselDidScroll(_ carousel: iCarousel) {
        m_lblEmailKind.text = m_userLocation?.aryUniversities?[carousel.currentItemIndex].universityEmail
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == .spacing {
            return value * 3
        }
        
        return value
    }
    
    @IBAction func onClickBtnClose(_ sender: Any) {
        delegate?.sendCloseRequestWithResult(result: false)
    }
    
    @IBAction func onClickBtnSendEmail(_ sender: Any) {
        if self.validLoginForm() {
            let userEmail = "\(self.m_txtEmail.text!)\(self.m_lblEmailKind.text!)"
            
            SVProgressHUD.show(withStatus: "Sending...")
            FirebaseService.sharedInstance.updateUserEmail(userEmail: userEmail, completion: { (error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error)
                } else {
                    SVProgressHUD.dismiss()
                    self.delegate?.sendCloseRequestWithResult(result: true)
                }
            })
        }
    }
    
    func validLoginForm() -> Bool {
        var isValid = false
        
        if m_txtEmail.text?.characters.count == 0 {
            SVProgressHUD.showError(withStatus: Constants.Errors.NO_EMAIL)
        } else {
            isValid = true
        }
        
        return isValid
    }
}
