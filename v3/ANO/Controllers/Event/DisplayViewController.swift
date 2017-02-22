//
//  DisplayViewController.swift
//  ANO
//
//  Created by Jacob May on 1/5/17.
//  Copyright © 2017 DMSoft. All rights reserved.
//

import UIKit
import ASPVideoPlayer
import SVProgressHUD

class DisplayViewController: UIViewController {
    
    @IBOutlet weak var m_imgPhoto: UIImageView!
    @IBOutlet weak var m_videoPlayer: ASPVideoPlayer!
    @IBOutlet weak var m_activityVideoLoading: UIActivityIndicatorView!

    @IBOutlet weak var m_btnFlag: UIButton!
    
    @IBOutlet weak var m_lblMediaTime: UILabel!
    
    @IBOutlet weak var m_lblEventTitle: UILabel!
    @IBOutlet weak var m_lblEventTime: UILabel!
    @IBOutlet weak var m_lblEventDescription: UILabel!
    @IBOutlet weak var m_constraintEventBottom: NSLayoutConstraint!

    var m_selectedEvent: EventObj?
    var m_aryMedias = [MediaObj]()
    var m_nFeedIndex = 0
    
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        formatter.dateFormat = Constants.Strings.EVENT_TIME_FORMAT
    
        if let m_selectedEvent = GlobalService.sharedInstance().g_objLiveEvent {
            m_aryMedias = (m_selectedEvent.event_medias)!
            
            self.m_lblEventTitle.text = m_selectedEvent.event_name
            if m_selectedEvent.event_time != nil {
                self.m_lblEventTime.text = formatter.string(from: m_selectedEvent.event_time!)
            } else {
                self.m_lblEventTime.text = "00:00"
            }
            self.m_lblEventDescription.text = m_selectedEvent.event_description
        }
            
        m_videoPlayer.gravity = .aspectFit
        m_videoPlayer.shouldLoop = true
        
        showFeeds()
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
    
    @IBAction func onSwipeRight(_ sender: Any) {
        if m_aryMedias.count > 0 {
            m_nFeedIndex = (m_aryMedias.count + m_nFeedIndex - 1) % m_aryMedias.count
            showFeeds()
        }
    }
    
    @IBAction func onSwipeLeft(_ sender: Any) {
        if m_aryMedias.count > 0 {
            m_nFeedIndex = (m_nFeedIndex + 1) % m_aryMedias.count
            showFeeds()
        }
    }
    
    @IBAction func onSwipeDown(_ sender: Any) {
        m_videoPlayer.stopVideo()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickBtnFlag(_ sender: Any) {
        let alertController = UIAlertController(title: "ANO", message: "Are you sure to report this media to administrator?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {(_) in
            SVProgressHUD.show(withStatus: "Reporting media...")
            let objMedia = self.m_aryMedias[self.m_nFeedIndex]
            WebService.sharedInstance().reportMedia(MediaId: objMedia.media_id!)
            { (response, error) in
                if let error = error {
                    SVProgressHUD.showError(withStatus: error)
                } else {
                    SVProgressHUD.showSuccess(withStatus: response!)
                }
            }
        })
        alertController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
    
    private func showFeeds() {
        if m_aryMedias.count > 0 {
            let objMedia = m_aryMedias[m_nFeedIndex]
            if objMedia.media_is_read == false {
                objMedia.media_is_read = true
                WebService.sharedInstance().markMediaAsRead(MediaId: objMedia.media_id!)
                { (response, error) in
                    if let error = error {
                        print(error)
                    } else {
                        print(response!)
                    }
                }
            }
            
            m_lblMediaTime.text = " \(formatter.string(from: objMedia.media_created_at!)) "
            
            m_videoPlayer.stopVideo()
            if objMedia.media_type == "VIDEO" {
                m_imgPhoto.isHidden = true
                m_videoPlayer.isHidden = false
                m_activityVideoLoading.isHidden = false
                
                m_videoPlayer.videoURL = URL(string: Constants.Server.VIDEO_URL + objMedia.media_video_url!)
                m_videoPlayer.playVideo()
                m_videoPlayer.readyToPlayVideo = {
                    self.m_activityVideoLoading.isHidden = true
                }
            } else {
                m_imgPhoto.isHidden = false
                m_videoPlayer.isHidden = true
                m_activityVideoLoading.isHidden = true
                m_imgPhoto.kf.setImage(with: URL(string: Constants.Server.PHOTO_URL + objMedia.media_photo_url!))
            }
        }
    }
}
