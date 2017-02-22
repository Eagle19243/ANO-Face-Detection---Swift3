//
//  PreviewViewController.swift
//  ANO
//
//  Created by Mychal Culpepper on 11/17/16.
//  Copyright © 2016 Blue Shift Group. All rights reserved.
//

import UIKit
import SCRecorder
import CoreLocation
import SVProgressHUD
import IQKeyboardManagerSwift
import Firebase
import CoreImage
import SCLAlertView

extension UIView
{
    func copyView() -> AnyObject
    {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self))! as AnyObject
    }
}


class PreviewViewController: UIViewController, UITextViewDelegate, SCVideoOverlay {
    
    enum TextViewStatus {
        case INVISIBLE
        case TRANSPARENT
        case IMAGED
    }
    
    var m_mediaType: Constants.MediaType!
    var m_imgPhoto: UIImage?
    var m_videoSession: SCRecordSession?
    var textView_Tapped = false
    
    var tvStatus:TextViewStatus = TextViewStatus.INVISIBLE
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var m_photoView: UIImageView!
    @IBOutlet weak var m_viewFilterSwitch: SCSwipeableFilterView!
    @IBOutlet weak var m_btnCreateEvent: ANOButton!
    
    let context = CIContext()
    
    let player = SCPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
       let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapToRemoveTextView(_:)))
        self.textView.addGestureRecognizer(tapGesture)
        
        textView.isHidden = true
        textView.backgroundColor = UIColor.clear
        tvStatus = TextViewStatus.INVISIBLE
        
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 8.0
        
        m_viewFilterSwitch.contentMode = .scaleAspectFit;
        
        let emptyFilter = SCFilter.empty()
        emptyFilter.name = "#nofilter"
        m_viewFilterSwitch.filters = [emptyFilter,
                                      SCFilter(ciFilterName: "CIPhotoEffectNoir"),
                                      SCFilter(ciFilterName: "CIPhotoEffectProcess"),
                                      SCFilter(ciFilterName: "CISepiaTone"),
                                      SCFilter(ciFilterName: "CIPhotoEffectTonal"),
                                      SCFilter(ciFilterName: "CIPhotoEffectFade")]
        
        // Do any additional setup after loading the view.
        if m_mediaType == Constants.MediaType.Video {
            player.scImageView = m_viewFilterSwitch
            player.loopEnabled = true
        } else {
            m_viewFilterSwitch.setImageBy(m_imgPhoto!)
        }
        
        m_btnCreateEvent.isHidden = m_mediaType == Constants.MediaType.Video;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if m_mediaType == Constants.MediaType.Video {
            player.setItemBy(m_videoSession?.assetRepresentingSegments())
            player.play()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        m_viewFilterSwitch.setNeedsDisplay()
    }
    
    func tapToRemoveTextView(_ sender: UITapGestureRecognizer){
        textView_Tapped = true
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player.pause()
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
    @IBAction func onClickBtnClose(_ sender: Any) {
        self.navigationController!.popViewController(animated: false)
    }
    
    @IBAction func onTapViewForText(_ sender: Any) {
        if (tvStatus == TextViewStatus.INVISIBLE) {
            textView.isHidden = false;
            textView.becomeFirstResponder()
            tvStatus = TextViewStatus.TRANSPARENT
        } else if (tvStatus == TextViewStatus.TRANSPARENT) {
            textView.backgroundColor = UIColor(patternImage: UIImage(named: "textfield_background")!)
            tvStatus = TextViewStatus.IMAGED
        } else if (tvStatus == TextViewStatus.IMAGED) {
            textView.backgroundColor = UIColor.clear
            tvStatus = TextViewStatus.TRANSPARENT
        }
    }
    
    @IBAction func onClickBtnCreateEvent(_ sender: Any) {
        let newEventVC = self.storyboard?.instantiateViewController(withIdentifier: "NewEventViewController") as! NewEventViewController
        newEventVC.m_imgPhoto = captureImageView()
        self.navigationController?.pushViewController(newEventVC, animated: true)
    }
    
    @IBAction func onClickBtnGo(_ sender: Any) {
        SVProgressHUD.show(withStatus: "Uploading media...")
        
        // upload image or video to firebase
        uploadMedia() {(videoUrl, imageUrl, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error)
                return
            }
            
            var liveEvent: Event?
            
            //check live event
            for event in GlobalService.sharedInstance.aryEvents {
                //check distance
                let eventLocation = CLLocation(latitude: event.eventLatitude!, longitude: event.eventLongitude!)
                if eventLocation.distance(from: GlobalService.sharedInstance.userLocation!) < Double(Constants.Numbers.EVENT_LIVE_DISTANCE) {
                    //check time
                    if Int(event.eventTime!.timeIntervalSinceNow) < Constants.Numbers.EVENT_LIVE_TIME * 60 {
                        liveEvent = event
                        break
                    }
                }
            }
            
            if liveEvent != nil {
                // media save to feed with live event id                
                SVProgressHUD.show(withStatus: "Saving Feed...")
                FirebaseService.sharedInstance.addMediaToFeed(eventID: (liveEvent?.eventID)!,
                                                              videoUrl: videoUrl!,
                                                              imageUrl: imageUrl!,
                                                              mediaType: self.m_mediaType!)  {(error) in
                                                                if error != nil {
                                                                    SVProgressHUD.showError(withStatus: error)
                                                                } else {
                                                                    SVProgressHUD.dismiss()
                                                                    let displayVC = self.storyboard?.instantiateViewController(withIdentifier: "DisplayViewController") as! DisplayViewController
                                                                    displayVC.m_selectedEvent = liveEvent
                                                                    self.navigationController?.pushViewController(displayVC, animated: true)
                                                                }
                }
            } else {
                SVProgressHUD.dismiss()
                let eventsVC = self.storyboard?.instantiateViewController(withIdentifier: "EventsViewController") as! EventsViewController
                eventsVC.videoUrl = videoUrl
                eventsVC.imageUrl = imageUrl
                eventsVC.mediaType = self.m_mediaType
                self.navigationController?.pushViewController(eventsVC, animated: true)
            }
        }
    }
    
    @IBAction func onClickBtnSaveCameraRoll(_ sender: Any) {
        let cameraRollOperation = SCSaveToCameraRollOperation()
        
        if m_mediaType == Constants.MediaType.Photo {
            cameraRollOperation.save(captureImageView()) {(error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                } else {
                    SVProgressHUD.showSuccess(withStatus: "Saved image to camera roll successfully.")
                }
            }
        } else {
            exportVideo() { _ in
                cameraRollOperation.saveVideoURL(self.m_videoSession?.outputUrl) {(path, error) in
                    if error != nil {
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    } else {
                        SVProgressHUD.showSuccess(withStatus: "Saved video to camera roll successfully.")
                    }
                }
            }
        }
    }
    
    //UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.characters.count == 0 {
            return true
        }
        
        if textView.text.characters.count == Constants.Numbers.PREVIEW_TEXT_MAX_LENGHT {
            return false
        }

        return true
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.autocorrectionType = UITextAutocorrectionType.yes
        return true;
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        textView.autocorrectionType = UITextAutocorrectionType.no
    }
    
    func captureImageView() -> UIImage {
        
        m_photoView.image = m_viewFilterSwitch.renderedUIImage()
        UIGraphicsBeginImageContext(m_photoView.frame.size)
       
        m_photoView.addSubview(textView)
        
        let watermarkImage = UIImageView()
        watermarkImage.image = UIImage(named: "icon_overlay")
        watermarkImage.contentMode = .scaleAspectFit
        watermarkImage.clipsToBounds = true
        watermarkImage.alpha = 0.5
        watermarkImage.sizeToFit()
        var watermarkFrame = watermarkImage.frame
        watermarkFrame.origin.x = m_photoView.frame.size.width - watermarkFrame.size.width - 8
        watermarkFrame.origin.y = m_photoView.frame.size.height - watermarkFrame.size.height - 8
        watermarkImage.frame = watermarkFrame
        
        m_photoView.addSubview(watermarkImage)
        m_photoView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    private func uploadMedia(completion: @escaping (String?, String?, String?) -> Void) {
        if m_mediaType == Constants.MediaType.Photo {
            let strImageName = "ano_\(String(Date.timeIntervalSinceReferenceDate)).jpg"
            let feedRef = FIRStorage.storage().reference().child("Feed").child("feed_images").child(strImageName)
            FirebaseService.sharedInstance.uploadImage(ref: feedRef, image: captureImageView()) {(imageUrl, error) in
                if imageUrl != nil {
                    completion("", imageUrl, nil)
                } else {
                    completion(nil, nil, error)
                }
            }
        } else {
            player.pause()
            
            exportVideo() {_ in
                let strVideoName = "ano_\(String(Date.timeIntervalSinceReferenceDate)).mov"
                let videoRef = FIRStorage.storage().reference().child("Feed").child("feed_videos").child(strVideoName)
                FirebaseService.sharedInstance.uploadVideo(ref: videoRef, file: (self.m_videoSession?.outputUrl)!) {(videoUrl, error) in
                    if videoUrl != nil {
                        let strImageName = "ano_\(String(Date.timeIntervalSinceReferenceDate)).jpg"
                        let imageRef = FIRStorage.storage().reference().child("Feed").child("feed_images").child(strImageName)
                        let thumbnail = (self.m_videoSession?.segments.first as! SCRecordSessionSegment).thumbnail
                        FirebaseService.sharedInstance.uploadImage(ref: imageRef, image: thumbnail!) {(imageUrl, error) in
                            if imageUrl != nil {
                                completion(videoUrl, imageUrl, nil)
                            } else {
                                completion(videoUrl, "", error)
                            }
                        }
                    } else {
                        completion(nil, nil, error)
                    }
                }
            }
        }
    }
    
    func exportVideo(completion: @escaping () -> Void) {
        let currentFilter = m_viewFilterSwitch.selectedFilter
        let exportSession = SCAssetExportSession(asset: m_videoSession!.assetRepresentingSegments())
        exportSession.videoConfiguration.filter = currentFilter
        exportSession.videoConfiguration.preset = SCPresetHighestQuality
        exportSession.audioConfiguration.preset = SCPresetHighestQuality
        
        // Setting overlay textview
        let overlay = SCWatermarkOverlayView()
        exportSession.videoConfiguration.overlay = overlay
        
        overlay.videoTextView.text = textView.text
        overlay.videoTextView.backgroundColor = textView.backgroundColor
        overlay.videoTextView.textColor = textView.textColor
        overlay.videoTextView.frame = textView.frame
        overlay.videoTextView.font = UIFont(name: textView.font!.fontName, size: (textView.font?.pointSize)!)
        overlay.videoTextView.resignFirstResponder()
        overlay.videoTextView.autocorrectionType = UITextAutocorrectionType.no
        overlay.videoTextView.becomeFirstResponder()
        overlay.videoTextView.resignFirstResponder()
        
        exportSession.videoConfiguration.maxFrameRate = 20
        exportSession.outputUrl = m_videoSession!.outputUrl
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        exportSession.contextType = .auto
        exportSession.exportAsynchronously(completionHandler: {
            completion()
        })
    }
}
