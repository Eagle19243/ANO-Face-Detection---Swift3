//
//  PreviewViewController.swift
//  ANO
//
//  Created by Jacob May on 12/14/16.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit
import SCRecorder
import SVProgressHUD

enum TextFieldStatus {
    case INVISIBLE
    case TRANSPARENT
    case IMAGED
}

extension UITextField {
    func copyView() -> UITextField {
        let copyTextField = UITextField.init(frame: self.frame)
        
        copyTextField.text = self.text
        copyTextField.backgroundColor = self.backgroundColor
        copyTextField.isHidden = self.isHidden
        copyTextField.font = self.font
        copyTextField.textColor = self.textColor
        copyTextField.textAlignment = self.textAlignment
        
        return copyTextField
    }
}

class PreviewViewController: UIViewController, UITextFieldDelegate {
    
    var m_mediaType: Constants.MediaType!
    var m_imgPhoto: UIImage?
    var m_videoSession: SCRecordSession?
    var m_isIcognitoMode = false
    
    @IBOutlet weak var m_viewFilterSwitch: SCSwipeableFilterView!
    @IBOutlet weak var m_txtOverlay: UITextField!
    
    let player = SCPlayer()
    var m_statusText = TextFieldStatus.INVISIBLE
    var m_isTextEditingMode = false
    var m_isPanStart = false
    var m_viewOverlay = Bundle.main.loadNibNamed("ANOVideoOverlay", owner: nil, options: nil)?.first as! ANOVideoOverlay
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        
        if m_isIcognitoMode {
            m_viewOverlay.m_lblUsername.text = ""
        } else {
            m_viewOverlay.m_lblUsername.text = User.currentUser?.userName
        }
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
        
        m_viewOverlay.frame = self.view.frame
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

    @IBAction func onTapPreview(_ sender: Any) {
        if (m_statusText == .INVISIBLE) {
            m_txtOverlay.isHidden = false;
            m_txtOverlay.becomeFirstResponder()
            m_statusText = .TRANSPARENT
        } else if (m_statusText == .TRANSPARENT) {
            m_txtOverlay.backgroundColor = UIColor(patternImage: UIImage(named: "camera_background_text")!)
            m_statusText = .IMAGED
        } else {
            m_txtOverlay.backgroundColor = UIColor.clear
            m_statusText = .TRANSPARENT
        }
    }
    
    @IBAction func onPanPreview(_ sender: Any) {
        let panGesture = sender as! UIPanGestureRecognizer
        let point = panGesture.location(in: m_viewOverlay)
        
        if panGesture.state == .began {
            if m_statusText != .INVISIBLE && !m_isTextEditingMode && m_txtOverlay.frame.contains(point) {
                m_isPanStart = true
            }
        } else if panGesture.state == .changed {
            if m_isPanStart {
                var frame = m_txtOverlay.frame
                frame.origin.y = point.y
                m_txtOverlay.frame = frame
            }
        } else {
            m_isPanStart = false
        }
    }
    
    //UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        m_isTextEditingMode = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.characters.count == 0 {
            m_statusText = .INVISIBLE
            textField.isHidden = true
        }
        
        m_isTextEditingMode = false
    }
    
    @IBAction func onClickBtnClose(_ sender: Any) {
        self.navigationController!.popViewController(animated: false)
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
            SVProgressHUD.show(withStatus: "Saving...")
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
    
    @IBAction func onClickBtnGo(_ sender: Any) {
        SVProgressHUD.show(withStatus: "Uploading media...")
        
        // upload image or video to firebase
        uploadMedia() {(videoUrl, imageUrl, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error)
                return
            }
            
            if let liveEvent = GlobalService.sharedInstance.getLiveEvent() {
                // media save to feed with live event id
                SVProgressHUD.show(withStatus: "Saving Feed...")
                FirebaseService.sharedInstance.addMediaToFeed(eventID: (liveEvent.eventID)!,
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
    
    func captureImageView() -> UIImage {
        m_viewOverlay.layoutIfNeeded()
        
        let imgViewPhoto = UIImageView.init(frame: m_viewOverlay.frame)
        imgViewPhoto.backgroundColor = UIColor.black
        imgViewPhoto.contentMode = .scaleAspectFit
        imgViewPhoto.image = m_viewFilterSwitch.renderedUIImage()
        m_viewOverlay.insertSubview(imgViewPhoto, at: 0)
        
        let copyTextOverlay = m_txtOverlay.copyView()
        m_viewOverlay.addSubview(copyTextOverlay)
        
        UIGraphicsBeginImageContext(m_viewOverlay.frame.size)
        m_viewOverlay.layer.render(in: UIGraphicsGetCurrentContext()!)
        let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // remove temp views
        imgViewPhoto.removeFromSuperview()
        copyTextOverlay.removeFromSuperview()
        
        return capturedImage!
    }
    
    private func uploadMedia(completion: @escaping (String?, String?, String?) -> Void) {
        if m_mediaType == Constants.MediaType.Photo {
            let strImageName = "ano_\(String(Date.timeIntervalSinceReferenceDate)).jpg"
            FirebaseService.sharedInstance.uploadImage(imageName: strImageName, image: captureImageView()) {(imageUrl, error) in
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
                FirebaseService.sharedInstance.uploadVideo(videoName: strVideoName, file: (self.m_videoSession?.outputUrl)!) {(videoUrl, error) in
                    if videoUrl != nil {
                        let strImageName = "ano_\(String(Date.timeIntervalSinceReferenceDate)).jpg"
                        let thumbnail = (self.m_videoSession?.segments.first as! SCRecordSessionSegment).thumbnail
                        FirebaseService.sharedInstance.uploadImage(imageName: strImageName, image: thumbnail!) {(imageUrl, error) in
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
        
        m_viewOverlay.m_overlayText = m_txtOverlay.copyView()
        m_viewOverlay.addSubview(m_viewOverlay.m_overlayText!)
        
        exportSession.videoConfiguration.overlay = m_viewOverlay
        exportSession.videoConfiguration.maxFrameRate = 30
        exportSession.outputUrl = m_videoSession!.outputUrl
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        exportSession.contextType = .auto
        exportSession.exportAsynchronously(completionHandler: {
            self.m_viewOverlay.m_overlayText?.removeFromSuperview()
            self.m_viewOverlay.m_overlayText = nil
            completion()
        })
    }
}
