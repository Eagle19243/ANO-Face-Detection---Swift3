//
//  LoginViewController.swift
//  ANO
//
//  Created by Jacob May on 17/11/2016.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import ActionSheetPicker_3_0
import SCLAlertView
import iCarousel
import CoreLocation

class LoginViewController: UIViewController, iCarouselDelegate, iCarouselDataSource {
    
    @IBOutlet weak var m_viewCarousel: iCarousel!
    @IBOutlet weak var m_viewLoading: UIActivityIndicatorView!
    @IBOutlet weak var m_txtEmail: UITextField!
    @IBOutlet weak var m_lblEmailKind: UILabel!
    @IBOutlet weak var m_lblExplanation: UILabel!
    @IBOutlet weak var m_btnSave: UIButton!
    
    let appearance = SCLAlertView.SCLAppearance(
        showCloseButton: false
    )
    
    var m_aryLocations: [Location]?
    var m_userLocation: Location?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseService.sharedInstance.getAllLocations { (aryLocations) in
            self.m_aryLocations = aryLocations
            self.handleLocations()
        }
        
        m_viewCarousel.type = .rotary
        m_lblExplanation.text = ""
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLocations), name: NSNotification.Name(rawValue: Constants.Strings.NOTIFICATION_GOL_LOCATION), object: nil)
        handleEnterForeground()
    }
    
    func handleLocations() {
        if m_aryLocations != nil && GlobalService.sharedInstance.userLocation != nil {
            //get neareast location
            for location in m_aryLocations! {
                let objLocation = CLLocation(latitude: location.locationLatitude!, longitude: location.locationLongitude!)
                
                let fDistance = objLocation.distance(from: GlobalService.sharedInstance.userLocation!)
                // check event distance
                if fDistance < Double(Constants.Numbers.EVENT_LIST_DISTANCE) {
                    self.m_userLocation = location
                    break
                }
            }
            
            if self.m_userLocation == nil {
                self.m_userLocation = m_aryLocations?[0]
            }
            
            self.m_viewLoading.stopAnimating()
            
            self.m_lblEmailKind.text = self.m_userLocation?.aryUniversities?[0].universityEmail
            self.m_viewCarousel.dataSource = self
            self.m_viewCarousel.delegate = self
            self.m_viewCarousel.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleEnterForeground(){
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Accept", target:self, selector:#selector(accept))
        alert.addButton("Reject", target:self, selector:#selector(reject))
        
        alert.addButton("Read Policy") {
            let url = NSURL(string: "http://www.exploreano.com/policies.html")
            UIApplication.shared.openURL(url! as URL)
        }
        // alert.showCloseButton = false
        
        alert.showNotice("Please read!", subTitle: " & accept terms!")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func accept(){
        print("user accepted")
        //UserDefaults.standard.set("userAccepted", forKey: "newUser")
        
    }
    
    func reject(){
        //        UIControl().sendAction(#selector(suspend), to: UIApplication.shared, for: nil)
    }
    
    @IBAction func onClickBtnSave(_ sender: Any) {
        if (validLoginForm()) {
            let userEmail = "\(self.m_txtEmail.text!)\(self.m_lblEmailKind.text!)"
            
            SVProgressHUD.show(withStatus: "Logging in...")
            FIRAuth.auth()!.signIn(withEmail: userEmail, password: Constants.Strings.ANO_PASSWORD) { (user, error) in
                if error != nil {
                    FIRAuth.auth()!.createUser(withEmail: userEmail, password: Constants.Strings.ANO_PASSWORD) { (user, error) in
                        SVProgressHUD.dismiss()
                        if let error = error {
                            self.m_lblExplanation.text = error.localizedDescription
                        } else {
                            self.sendVerificationEmail(user: user!)
                        }
                    }
                } else {
                    SVProgressHUD.dismiss()                    
                    if (user?.isEmailVerified)! {
                        let cameraVC = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController")
                        GlobalService.sharedInstance.cameraVC = cameraVC
                        self.navigationController?.pushViewController(cameraVC!, animated: true)
                    } else {
                        let alertController = UIAlertController(title: "ANO", message: "You must verify your email address to use this app", preferredStyle: .alert)
                        let sendAction = UIAlertAction(title: "Send verification email again", style: .default) {_ in
                            self.sendVerificationEmail(user: user!)
                        }
                        alertController.addAction(sendAction)
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        alertController.addAction(cancelAction)
                        self.present(alertController, animated: true)
                    }
                }
            }
        }
    }
    
    func sendVerificationEmail(user: FIRUser) {
        user.sendEmailVerification() {(error) in
            if let error = error {
                self.m_lblExplanation.text = error.localizedDescription
            } else {
                self.m_lblExplanation.text = Constants.Strings.VERIFY_EMAIL
            }
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
}
