//
//  NewEventViewController.swift
//  ANO
//
//  Created by Jacob May on 12/14/16.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import SVProgressHUD
import CoreLocation
import BetterSegmentedControl
import SCLAlertView

class NewEventViewController: UIViewController, UITextViewDelegate, LocationViewDelegate {
    
    @IBOutlet weak var m_photoView: UIImageView!
    @IBOutlet weak var m_txtTitle: UITextField!
    @IBOutlet weak var m_txtStartTime: UITextField!
    @IBOutlet weak var m_txtAddress: UITextField!
    @IBOutlet weak var m_txtDescription: UITextView!
    @IBOutlet weak var m_lblCharacters: UILabel!
    @IBOutlet weak var m_txtHost: UITextField!
    @IBOutlet weak var m_viewVerifyEmail: UIView!
    @IBOutlet weak var m_segEventType: BetterSegmentedControl!
    
    var appDelegate : AppDelegate!
    var m_imgPhoto: UIImage!
    let defaults = UserDefaults.standard
    var m_locationView: LocationView?
    var m_eventType = EVENT_TYPE.PRIVATE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        m_txtDescription.text = "If this is not a public event, we recommend leaving a phone number so social media contact instead of an address"
        m_txtDescription.textColor = UIColor.lightGray
        
        // Do any additional setup after loading the view.
        self.m_photoView.image = m_imgPhoto
        
        m_segEventType.titles = ["Private", "Public"]
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
    
    @IBAction func onClickBtnStartTime(_ sender: Any) {
        ActionSheetDatePicker.show(withTitle: "Event Time",
                                   datePickerMode: .dateAndTime,
                                   selectedDate: Date(),
                                   minimumDate: Date(),
                                   maximumDate: nil,
                                   doneBlock: {(picker: ActionSheetDatePicker?, selectedDate, _) in
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = Constants.Strings.EVENT_TIME_FORMAT
                                    self.m_txtStartTime.text = formatter.string(from: selectedDate as! Date)
        },
                                   cancel: nil,
                                   origin: sender as! UIView)
    }
    
    @IBAction func onClickBtnSave(_ sender: Any) {
        if checkValidate() {
            SVProgressHUD.show(withStatus: "Getting location...")
            // get location from address string
            CLGeocoder().geocodeAddressString(m_txtAddress.text!, completionHandler: { (placemarks, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    return
                }
                
                if (placemarks?.count)! > 0 {
                    let placemark = placemarks?[0]
                    if let location = placemark?.location {
                        self.createEvent(location: location)
                    }
                }
            })
        } else {
            let alertController = UIAlertController(title: "Oops?!🤒", message: "It looks like you forgot some info", preferredStyle: .alert)
            let acceptAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(acceptAction)
            
            self.present(alertController, animated: true)
            
            return
        }
    }
    
    @IBAction func Home_Button_Pressed(_ sender: UIButton) {
        SVProgressHUD.show(withStatus: "Getting address...")
        // get location from address string
        CLGeocoder().reverseGeocodeLocation(GlobalService.sharedInstance.userLocation!, completionHandler: {(placemarks, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                return
            }
            
            SVProgressHUD.dismiss()
            if let placemark = placemarks?.first {
                self.m_txtAddress.text = "\(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? "") \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "")"
            }
        })
    }
    
    //UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "If this is not a public event, we recommend leaving a phone number or social media contact instead of an address"
            textView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func currentTimePressed(_ sender: UIButton) {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.Strings.EVENT_TIME_FORMAT
        self.m_txtStartTime.text = formatter.string(from: Date())
    }
    
    private func checkValidate() -> Bool {
        if ((m_txtTitle.text?.characters.count)! > 0
            || (m_txtStartTime.text?.characters.count)! > 0
            || (m_txtAddress.text?.characters.count)! > 0 || (m_txtDescription.text?.characters.count)! > 0) {
            return true
        } else {
            return false
        }
    }
    
    private func createEvent(location: CLLocation) {
        let strImageName = "ano_\(String(Date.timeIntervalSinceReferenceDate)).jpg"
        SVProgressHUD.show(withStatus: "Uploading image...")
        FirebaseService.sharedInstance.uploadImage(imageName: strImageName, image: m_imgPhoto) {(imageUrl, error) in
            if imageUrl != nil {
                let event = [
                    "imageUrl": imageUrl!,
                    "creatorID": (User.currentUser?.userID)!,
                    "title": self.m_txtTitle.text!,
                    "time": self.m_txtStartTime.text!,
                    "latitude": location.coordinate.latitude,
                    "longitude": location.coordinate.longitude,
                    "address": self.m_txtAddress.text!,
                    "description": self.m_txtDescription.text ?? "",
                    "host": self.m_txtHost.text!,
                    "type": self.m_eventType
                    ] as [String : Any]
                
                SVProgressHUD.show(withStatus: "Creating Event...")
                FirebaseService.sharedInstance.createEvent(event: event) {(eventID, error) in
                    if error == nil {
                        SVProgressHUD.dismiss()
                        let eventsVC = self.storyboard?.instantiateViewController(withIdentifier: "EventsViewController")
                        self.navigationController?.pushViewController(eventsVC!, animated: true)
                    } else {
                        SVProgressHUD.showError(withStatus: error)
                    }
                }
            } else {
                SVProgressHUD.showError(withStatus: error)
            }
        }
    }
    
    @IBAction func onClickBtnClose(_ sender: Any) {
        self.navigationController!.popViewController(animated: false)
    }
    
    //UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.characters.count == 0 {
            return true
        }
        
        if textView.text.characters.count == Constants.Numbers.EVENT_DESCRIPTION_MAX_LENGHT {
            return false
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let nDescriptionLength = textView.text.characters.count
        self.m_lblCharacters.text = "\(nDescriptionLength) / \(Constants.Numbers.EVENT_DESCRIPTION_MAX_LENGHT)"
    }
    
    @IBAction func onChangedType(_ sender: Any) {
        m_viewVerifyEmail.isHidden = m_segEventType.index == 0
        
        m_eventType = EVENT_TYPE(rawValue: Int(m_segEventType.index))!
    }
    
    @IBAction func onClickBtnVerifyEmail(_ sender: Any) {
        m_locationView = Bundle.main.loadNibNamed("LocationView", owner: nil, options: nil)?.first as? LocationView
        m_locationView?.frame = self.view.frame
        m_locationView?.delegate = self
        self.view.addSubview(m_locationView!)
    }
    
    //LocationViewDelegate
    func sendCloseRequestWithResult(result: Bool) {
        if m_locationView != nil {
            m_locationView?.removeFromSuperview()
            m_locationView = nil
            
            if result {
                m_eventType = .SEMI_PUBLIC
                SCLAlertView().showSuccess("ANO", subTitle: "We just sent verification email to you.\n Please verify your email to use app.")
            }
        }
    }
    
    @IBAction func onClickBtnHelp(_ sender: Any) {
        SCLAlertView().showNotice("Verify Email", subTitle: " If you are currently in school, you can filter people based on their school email. Check the box, provide your school email to make fun events for your classmates only")
    }
}
