//
//  DisplayViewController.swift
//  ANO
//
//  Created by Jacob May on 12/14/16.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit
import SDWebImage
import ASPVideoPlayer
import SVProgressHUD

class DisplayViewController: UIViewController {
    
    var m_selectedEvent: Event!
    
    @IBOutlet weak var m_imgPhoto: UIImageView!
    @IBOutlet weak var m_videoPlayer: ASPVideoPlayer!
    @IBOutlet weak var m_btnFlag: UIButton!
    
    @IBOutlet weak var m_lblMediaTime: UILabel!
    @IBOutlet weak var m_viewStats: UIView!
    
    @IBOutlet weak var m_lblAvgAge: UILabel!
    @IBOutlet weak var m_lblTotal: UILabel!
    
    @IBOutlet weak var m_lblEventTitle: UILabel!
    @IBOutlet weak var m_lblEventTime: UILabel!
    @IBOutlet weak var m_lblEventDescription: UILabel!
    @IBOutlet weak var m_constraintEventBottom: NSLayoutConstraint!
    
    var m_nFeedIndex = 0
    var m_aryFeeds = [Feed]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        m_lblMediaTime.clipsToBounds = true
        m_lblMediaTime.layer.cornerRadius = 8.0
        
        m_lblMediaTime.isHidden = true
        let input = m_lblEventDescription.text!
        let types: NSTextCheckingResult.CheckingType = [.address, .phoneNumber, .link]
        let detector = try! NSDataDetector(types: types.rawValue )
        let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: (input.utf16.count)))
        
        for match in matches {
            let url = (input as NSString).substring(with: match.range)
            print(url)
        }
        
        m_viewStats.isHidden = true
        m_btnFlag.isHidden = false
        
        // Do any additional setup after loading the view.
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a MM/dd/yy"
        
        self.m_lblEventTitle.text = m_selectedEvent.eventTitle
        if m_selectedEvent.eventTime != nil {
            self.m_lblEventTime.text = formatter.string(from: m_selectedEvent.eventTime!)
        } else {
            self.m_lblEventTime.text = "00:00"
        }
        self.m_lblEventDescription.text = m_selectedEvent.eventDescription
        
        m_videoPlayer.gravity = .aspectFill
        m_videoPlayer.shouldLoop = true
        
        // get all event users
        FirebaseService.sharedInstance.getAllEventUsers(eventID: m_selectedEvent.eventID!) {(aryUsers) in
            self.updateStats(aryUsers: aryUsers!)
        }
        
        // get all event feeds
        FirebaseService.sharedInstance.getAllEventFeeds(eventID: m_selectedEvent.eventID!) {(aryFeeds) in
            self.m_aryFeeds = aryFeeds!
            self.m_nFeedIndex = 0
            self.showFeeds()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // update user eventID
        if User.currentUser != nil {
            FirebaseService.sharedInstance.updateUserEventID(eventID: m_selectedEvent.eventID!) {(error) in
                if error != nil {
                    print(error!)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //update user eventID
        if User.currentUser != nil {
            FirebaseService.sharedInstance.updateUserEventID(eventID: "0") {(error) in
                if error != nil {
                    print(error!)
                }
            }
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
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
    @IBAction func onClickBtnShowTime(_ sender: Any) {
        m_lblMediaTime.isHidden = !m_lblMediaTime.isHidden
    }
    
    @IBAction func onClickBtnShowStats(_ sender: Any) {
        m_viewStats.isHidden = !m_viewStats.isHidden
    }
    
    @IBAction func onClickBtnCamera(_ sender: Any) {
        self.navigationController!.popToViewController(GlobalService.sharedInstance.cameraVC!, animated: true)
    }
    
    @IBAction func onSwipeRight(_ sender: Any) {
        if m_aryFeeds.count > 0 {
            m_nFeedIndex = (m_aryFeeds.count + m_nFeedIndex - 1) % m_aryFeeds.count
            showFeeds()
        }
    }
    
    @IBAction func onSwipeLeft(_ sender: Any) {
        if m_aryFeeds.count > 0 {
            m_nFeedIndex = (m_nFeedIndex + 1) % m_aryFeeds.count
            showFeeds()
        }
    }
    
    @IBAction func onClickBtnEventCollapse(_ sender: Any) {
        let btnCollapse = sender as! UIButton
        btnCollapse.isSelected = !btnCollapse.isSelected
        
        if btnCollapse.isSelected {
            UIView.animate(withDuration: 0.3, animations: {() in
                self.m_constraintEventBottom.constant = 0
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {() in
                self.m_constraintEventBottom.constant = -100
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func onClickBtnFlag(_ sender: Any) {
        let alertController = UIAlertController(title: "ANO", message: "Are you sure to report this media to administrator?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {(_) in
            SVProgressHUD.show(withStatus: "Reporting media...")
            
            let feed = self.m_aryFeeds[self.m_nFeedIndex]
            FirebaseService.sharedInstance.reportMedia(eventID: self.m_selectedEvent.eventID!, feedID: feed.feedID!) {(error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error)
                } else {
                    SVProgressHUD.showSuccess(withStatus: "Reported successfully.")
                }
            }
        })
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
    
    private func updateStats(aryUsers: [User]) {
//        var nFDating = 0
//        var nFTalking = 0
//        var nFSingle = 0
//        
//        var nMDating = 0
//        var nMTalking = 0
//        var nMSingle = 0
//        
//        var totalAge = 0
//        
//        let calendar = Calendar.current
//        let thisYear = calendar.dateComponents([.year], from: Date()).year
//        
//        let formatter = DateFormatter()
//        formatter.dateFormat = Constants.Strings.BIRTHDAY_TIME_FORMAT
//        
//        for user in aryUsers {
//            if user.userGender == Constants.Arrays.aryGender[0] {   //female
//                if user.userRealStatus == Constants.Arrays.aryStatus[0] {
//                    nFSingle = nFSingle + 1
//                } else if user.userRealStatus == Constants.Arrays.aryStatus[1] {
//                    nFTalking = nFTalking + 1
//                } else {
//                    nFDating = nFDating + 1
//                }
//            } else {    //male
//                if user.userRealStatus == Constants.Arrays.aryStatus[0] {
//                    nMSingle = nMSingle + 1
//                } else if user.userRealStatus == Constants.Arrays.aryStatus[1] {
//                    nMTalking = nMTalking + 1
//                } else {
//                    nMDating = nMDating + 1
//                }
//            }
//            
//            let userYear = calendar.dateComponents([.year], from: formatter.date(from: user.userBirthday!)!).year
//            totalAge = totalAge + (thisYear! - userYear!)
//        }
//        
//        let viewFemale = self.view.viewWithTag(100)
//        let lblFDating = viewFemale?.viewWithTag(10) as! UILabel
//        lblFDating.text = String(nFDating)
//        
//        let lblFTalking = viewFemale?.viewWithTag(11) as! UILabel
//        lblFTalking.text = String(nFTalking)
//        
//        let lblFSingle = viewFemale?.viewWithTag(12) as! UILabel
//        lblFSingle.text = String(nFSingle)
//        
//        let viewMale = self.view.viewWithTag(200)
//        let lblMDating = viewMale?.viewWithTag(10) as! UILabel
//        lblMDating.text = String(nMDating)
//        
//        let lblMTalking = viewMale?.viewWithTag(11) as! UILabel
//        lblMTalking.text = String(nMTalking)
//        
//        let lblMSingle = viewMale?.viewWithTag(12) as! UILabel
//        lblMSingle.text = String(nMSingle)
//        
//        if aryUsers.count > 0 {
//            m_lblAvgAge.text = String(format: "%.1f", Float(totalAge) / Float(aryUsers.count))
//        } else {
//            m_lblAvgAge.text = "0.0"
//        }
//        m_lblTotal.text = String(aryUsers.count)
    }
    
    private func showFeeds() {
        if m_aryFeeds.count > 0 {
            let feed = m_aryFeeds[m_nFeedIndex]
            
            m_videoPlayer.isHidden = true
            m_imgPhoto.isHidden = false
            m_videoPlayer.pauseVideo()
            
            m_lblMediaTime.text = feed.feedCreatedAt
            m_imgPhoto.sd_setImage(with: URL(string: feed.feedImageUrl!), placeholderImage: UIImage(named: "image_display_placeholder"))
            if feed.feedMediaType == Constants.MediaType.Video {
                m_videoPlayer.videoURL = URL(string: feed.feedVideoUrl!)
                self.m_videoPlayer.playVideo()
                m_videoPlayer.readyToPlayVideo = {
                    self.m_imgPhoto.isHidden = true
                    self.m_videoPlayer.isHidden = false
                }
            }
        } else {
            m_imgPhoto.image = UIImage(named: "image_display_placeholder")
        }
        
        if User.currentUser != nil {
            m_btnFlag.isHidden = m_aryFeeds.count == 0
        } else {
            m_btnFlag.isHidden = true
        }
    }
}
