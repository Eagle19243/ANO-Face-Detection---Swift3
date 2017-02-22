//
//  CameraViewController.swift
//  ANO
//
//  Created by Jacob May on 1/4/17.
//  Copyright © 2017 DMSoft. All rights reserved.
//

import UIKit
import ColorWithHex
import SCRecorder
import CircleProgressView
import CoreLocation
import Kingfisher

class CameraViewController: UIViewController, UIScrollViewDelegate, SCRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, EventVibeViewControllerDelegate {
    
    @IBOutlet weak var m_viewPreview: UIView!
    @IBOutlet weak var m_viewProgress: CircleProgressView!
    @IBOutlet weak var m_lblVideoTime: UILabel!
    
    @IBOutlet weak var m_lblLocation: UILabel!
    @IBOutlet weak var m_lblEvent: UILabel!
    
    @IBOutlet weak var m_viewStats: UIView!
    @IBOutlet weak var m_lblAveAge: UILabel!
    @IBOutlet weak var m_lblTotalUser: UILabel!
    
    @IBOutlet weak var m_imgEventMedia: UIImageView!
    @IBOutlet weak var m_lblEventMediaUnread: UILabel!
    
    @IBOutlet weak var m_constraintActionViewBottom: NSLayoutConstraint!
    
    var m_scRecorder = SCRecorder()
    var m_mediaType: String?
    let imagePicker = UIImagePickerController()
    var m_timerCounter: Timer?
    var m_fVideoCount = 0.0
    var m_isViewActionUp = false
    
    var m_vibeVC: EventVibeViewController!
    var m_viewVibe: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onUpdatedEvents),
                                               name: NSNotification.Name(rawValue: Constants.Notifications.GET_EVENTS),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onUpdatedUserLocation),
                                               name: NSNotification.Name(rawValue: Constants.Notifications.GET_USER_LOCATION),
                                               object: nil)
        
        // add event vibe view
        m_vibeVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: EventVibeViewController.self)) as! EventVibeViewController
        m_vibeVC.delegate = self
        self.addChildViewController(m_vibeVC)
        m_viewVibe = m_vibeVC.view
        m_viewVibe.frame = CGRect(x: 0,
                                  y: self.view.frame.size.height,
                                  width: self.view.frame.size.width,
                                  height: 400)
        self.view.addSubview(m_viewVibe)
        
        m_imgEventMedia.layer.borderWidth = 3.0
        m_imgEventMedia.layer.borderColor = UIColor.colorWithHex("#007AFF")?.cgColor
        
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        initCamera()
    }
    
    func onUpdatedUserLocation() {
        m_lblLocation.text = ""
        if let objLocation = GlobalService.sharedInstance().g_userCurrentLocation {
            let imgLocation = NSTextAttachment()
            imgLocation.image = UIImage(named: objLocation.location_icon!)
            let imgLocationString = NSAttributedString(attachment: imgLocation)
            
            let strLocation = NSMutableAttributedString(string: "\(objLocation.location_address!) cam ")
            strLocation.append(imgLocationString)
            
            self.m_lblLocation.attributedText = strLocation
        }
    }
    
    func onUpdatedEvents() {
        if let objEvent = GlobalService.sharedInstance().g_objLiveEvent {
            // update event name
            m_lblEvent.text = objEvent.event_name
            
            if let aryMedias = objEvent.event_medias {
                // update event media
                if aryMedias.count > 0 {
                    let objEventMedia = aryMedias[0]
                    m_imgEventMedia.kf.setImage(with: URL(string: Constants.Server.PHOTO_URL + objEventMedia.media_photo_url!))
                } else {
                    m_imgEventMedia.image = UIImage(named: "camera_icon_media_plus")
                }
                // update event media unread count
                var nUnreadCount = 0
                for objEventMedia in aryMedias {
                    if objEventMedia.media_is_read == false {
                        nUnreadCount += 1
                    }
                }
                
                m_lblEventMediaUnread.text = "\(nUnreadCount)"
                m_lblEventMediaUnread.isHidden = nUnreadCount == 0
            }
            
            if let aryUsers = objEvent.event_users {
                updateStats(aryUsers)
            }
            
            m_vibeVC.m_selectedEvent = objEvent
            m_vibeVC.m_tblVibes.reloadData()
        }
    }
    
    private func initCamera() {
        m_scRecorder.maxRecordDuration = CMTimeMake(Int64(Constants.Numbers.VIDEO_MAX_SEC), 1);
        
        m_scRecorder.delegate = self
        m_scRecorder.autoSetVideoOrientation = false
        
        m_scRecorder.previewView = m_viewPreview
        m_scRecorder.initializeSessionLazily = false
        
        m_scRecorder.device = .front
        
        do {
            try m_scRecorder.prepare()
        } catch {
            print("Error camera prepare")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareSession()
        UIApplication.shared.isStatusBarHidden = true
        
        onUpdatedEvents()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = false
        super.viewDidDisappear(animated)
    }
    
    private func prepareSession() {
        let session = SCRecordSession()
        session.fileType = AVFileTypeQuickTimeMovie;
        m_scRecorder.session = session
        m_scRecorder.captureSessionPreset = SCRecorderTools.bestCaptureSessionPresetCompatibleWithAllDevices()
        m_scRecorder.mirrorOnFrontCamera = false
        m_scRecorder.startRunning()
        
        m_lblVideoTime.text = "00:00"
        m_viewProgress.progress = 0.0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        m_scRecorder.previewViewFrameChanged()
        m_viewVibe.layoutIfNeeded()
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
    
    //UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.size.width
        let nPage = Int(floor((scrollView.contentOffset.x - width / 2) / width) + 1)
        
        if nPage == 0 { // photo
            self.m_lblVideoTime.isHidden = true
        } else {
            self.m_lblVideoTime.isHidden = false
            m_lblVideoTime.text = "00:00"
            m_viewProgress.progress = 0.0
        }
    }
    
    @IBAction func onClickSwitchCamera(_ sender: Any) {
        m_scRecorder.switchCaptureDevices()
    }
    
    @IBAction func onClickBtnFlash(_ sender: Any) {
        if m_scRecorder.deviceHasFlash {
            let btnFlash = sender as! UIButton
            
            switch (m_scRecorder.flashMode) {
            case .off:
                btnFlash.isSelected = true
                m_scRecorder.flashMode = .light
                break;
            case .light:
                btnFlash.isSelected = false
                m_scRecorder.flashMode = .off
                break;
            default:
                break;
            }
        }
    }
    
    @IBAction func onClickBtnVideo(_ sender: Any) {
        if self.m_scRecorder.isRecording {
            if m_timerCounter != nil {
                m_timerCounter?.invalidate()
                m_timerCounter = nil
            }
            
            m_scRecorder.pause({
                self.saveVideo(recordSession: self.m_scRecorder.session!)
            })
        } else {
            self.m_viewProgress.progress = 0
            
            m_fVideoCount = 0.0
            let timeInterval = Double(Constants.Numbers.VIDEO_MAX_SEC) / 100.0
            m_timerCounter = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: {(timer) in
                self.m_fVideoCount += timeInterval
                self.m_lblVideoTime.text = "00:0\(Int(self.m_fVideoCount))"
                
                if Int(self.m_fVideoCount) == Constants.Numbers.VIDEO_MAX_SEC {
                    self.m_timerCounter?.invalidate()
                    self.m_timerCounter = nil
                }
                
                self.m_viewProgress.progress += 1.0 / 100.0
            })
            
            self.m_scRecorder.record()
        }
    }
    
    //SCRecorderDelegate
    func recorder(_ recorder: SCRecorder, didComplete session: SCRecordSession) {
        saveVideo(recordSession: session)
    }
    
    private func saveVideo(recordSession: SCRecordSession) {
        let previewVC = self.storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
        previewVC.m_mediaType = "VIDEO"
        previewVC.m_videoSession = recordSession
        
        self.navigationController?.pushViewController(previewVC, animated: false)
    }
    
    @IBAction func onClickBtnCamera(_ sender: Any) {
        m_scRecorder.capturePhoto({(error, image) in
            let previewVC = self.storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
            previewVC.m_mediaType = "CAMERA"
            previewVC.m_imgPhoto = image
            
            self.navigationController?.pushViewController(previewVC, animated: false)
        })
    }
    
    @IBAction func onClickBtnLibrary(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true)
    }
    
    //ImagePickerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: false) {
            let previewVC = self.storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
            previewVC.m_mediaType = "LIBRARY"
            previewVC.m_imgPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage?
            
            self.navigationController?.pushViewController(previewVC, animated: false)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    @IBAction func onTapEventMedia(_ sender: Any) {
        if let objEvent = GlobalService.sharedInstance().g_objLiveEvent {
            if (objEvent.event_medias?.count)! > 0 {
                let displayVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: DisplayViewController.self))
                self.present(displayVC!, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func onClickBtnStats(_ sender: Any) {
        m_viewStats.isHidden = !m_viewStats.isHidden
    }
    
    private func updateStats(_ aryUsers: [UserObj]) {
        var nFDating = 0
        var nFTalking = 0
        var nFSingle = 0

        var nMDating = 0
        var nMTalking = 0
        var nMSingle = 0

        var totalAge = 0

        let calendar = Calendar.current
        let thisYear = calendar.dateComponents([.year], from: Date()).year

        let formatter = DateFormatter()
        formatter.dateFormat = Constants.Strings.BIRTHDAY_TIME_FORMAT

        for objUser in aryUsers {
            if objUser.user_gender == Constants.Arrays.aryGender[0] {   //female
                if objUser.user_stats == Constants.Arrays.aryStatus[0] {
                    nFSingle = nFSingle + 1
                } else if objUser.user_stats == Constants.Arrays.aryStatus[1] {
                    nFTalking = nFTalking + 1
                } else {
                    nFDating = nFDating + 1
                }
            } else {    //male
                if objUser.user_stats == Constants.Arrays.aryStatus[0] {
                    nMSingle = nMSingle + 1
                } else if objUser.user_stats == Constants.Arrays.aryStatus[1] {
                    nMTalking = nMTalking + 1
                } else {
                    nMDating = nMDating + 1
                }
            }

            let userYear = calendar.dateComponents([.year], from: objUser.user_birthday!).year
            totalAge = totalAge + (thisYear! - userYear!)
        }

        let viewFemale = self.view.viewWithTag(100)
        let lblFDating = viewFemale?.viewWithTag(10) as! UILabel
        lblFDating.text = String(nFDating)

        let lblFTalking = viewFemale?.viewWithTag(11) as! UILabel
        lblFTalking.text = String(nFTalking)

        let lblFSingle = viewFemale?.viewWithTag(12) as! UILabel
        lblFSingle.text = String(nFSingle)

        let viewMale = self.view.viewWithTag(200)
        let lblMDating = viewMale?.viewWithTag(10) as! UILabel
        lblMDating.text = String(nMDating)

        let lblMTalking = viewMale?.viewWithTag(11) as! UILabel
        lblMTalking.text = String(nMTalking)
        
        let lblMSingle = viewMale?.viewWithTag(12) as! UILabel
        lblMSingle.text = String(nMSingle)
        
        if aryUsers.count > 0 {
            m_lblAveAge.text = String(format: "%.1f", Float(totalAge) / Float(aryUsers.count))
        } else {
            m_lblAveAge.text = "0.0"
        }
        m_lblTotalUser.text = String(aryUsers.count)
    }
    
    @IBAction func onClickBtnMessage(_ sender: Any) {
        if let homeVC = GlobalService.sharedInstance().g_homeVC {
            homeVC.setViewControllers([homeVC.aryViewControllers[0]], direction: .reverse, animated: true, completion: nil)
        }
    }
    
    @IBAction func onClickBtnEvent(_ sender: Any) {
        if let homeVC = GlobalService.sharedInstance().g_homeVC {
            homeVC.setViewControllers([homeVC.aryViewControllers[2]], direction: .forward, animated: true, completion: nil)
        }
    }
    
    @IBAction func onClickBtnComments(_ sender: Any) {
        UIView.animate(withDuration: 0.3) { 
            self.m_viewVibe.frame = CGRect(x: 0,
                                           y: self.view.frame.size.height - self.m_viewVibe.frame.size.height,
                                           width: self.m_viewVibe.frame.size.width,
                                           height: self.m_viewVibe.frame.size.height)
        }
    }
    
    // EventViewViewControllerDelegate
    func onClickBtnClose() {
        UIView.animate(withDuration: 0.3) {
            self.m_viewVibe.frame = CGRect(x: 0,
                                           y: self.view.frame.size.height,
                                           width: self.m_viewVibe.frame.size.width,
                                           height: self.m_viewVibe.frame.size.height)
        }
    }
    
    @IBAction func onSwipeUpView(_ sender: Any) {
        if m_isViewActionUp == false {
            UIView.animate(withDuration: 0.3, animations: {
                self.m_constraintActionViewBottom.constant = 0
                self.view.layoutIfNeeded()
            })
            { (_) in
                self.m_isViewActionUp = true
            }
        }
    }
    
    @IBAction func onSwipeDownView(_ sender: Any) {
        if m_isViewActionUp {
            UIView.animate(withDuration: 0.3, animations: {
                self.m_constraintActionViewBottom.constant = -140
                self.view.layoutIfNeeded()
            })
            { (_) in
                self.m_isViewActionUp = false
            }
        }
    }
    
}
