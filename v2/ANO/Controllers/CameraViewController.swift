//
//  CameraViewController.swift
//  ANO
//
//  Created by Jacob May on 12/13/16.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit
import ColorWithHex
import SCRecorder
import CircleProgressView

class CameraViewController: UIViewController, UIScrollViewDelegate, SCRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var m_viewPreview: UIView!
    @IBOutlet weak var m_viewBottom: UIView!
    @IBOutlet weak var m_scrollMenu: UIScrollView!
    @IBOutlet weak var m_viewProgress: CircleProgressView!
    @IBOutlet weak var m_lblVideoTime: UILabel!
    @IBOutlet weak var m_imgIcognitoMode: UIImageView!
    
    var m_scRecorder = SCRecorder()
    var m_mediaType: Constants.MediaType?
    let imagePicker = UIImagePickerController()
    var m_timerCounter: Timer?
    var m_fCount = 0.0
    var m_isIcognitoMode = false
    
    let aryColors = ["#E74B3B", "#15CCBB", "#F0C40F"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        initCamera()
    }
    
    private func initCamera() {
        m_scRecorder.maxRecordDuration = CMTimeMake(Int64(Constants.Numbers.VIDEO_MAX_SEC), 1);
        
        m_scRecorder.delegate = self;
        m_scRecorder.autoSetVideoOrientation = false;
        
        m_scRecorder.previewView = m_viewPreview;
        m_scRecorder.initializeSessionLazily = false;
        
        m_scRecorder.device = .front
        
        do {
            try m_scRecorder.prepare()
        } catch {
            print("Error camera prepare")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareSession()
    }
    
    private func prepareSession() {
        let session = SCRecordSession()
        session.fileType = AVFileTypeQuickTimeMovie;
        m_scRecorder.session = session;
        m_scRecorder.captureSessionPreset = SCRecorderTools.bestCaptureSessionPresetCompatibleWithAllDevices()
        m_scRecorder.mirrorOnFrontCamera = false
        m_scRecorder.startRunning();
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        m_scRecorder.previewViewFrameChanged()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        m_scrollMenu.contentOffset = CGPoint(x: m_scrollMenu.frame.size.width, y: 0)
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
        UIView.animate(withDuration: 0.3, animations: {
            self.m_viewBottom.backgroundColor = UIColor.colorWithHex(self.aryColors[nPage])
        })
        
        if nPage == 0 { // Video
            self.m_mediaType = Constants.MediaType.Video
            self.m_lblVideoTime.isHidden = false;
            m_lblVideoTime.text = "00:00"
            m_viewProgress.progress = 0.0
        } else if nPage == 1 { //
            self.m_mediaType = Constants.MediaType.Photo
            self.m_lblVideoTime.isHidden = true
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
                m_scRecorder.flashMode = .light;
                break;
            case .light:
                btnFlash.isSelected = false
                m_scRecorder.flashMode = .off;
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
            
            m_fCount = 0.0
            let timeInterval = Double(Constants.Numbers.VIDEO_MAX_SEC) / 100.0
            m_timerCounter = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: {(timer) in
                self.m_fCount += timeInterval
                self.m_lblVideoTime.text = "00:0\(Int(self.m_fCount))"
                
                if Int(self.m_fCount) == Constants.Numbers.VIDEO_MAX_SEC {
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
        previewVC.m_mediaType = self.m_mediaType
        previewVC.m_videoSession = recordSession
        previewVC.m_isIcognitoMode = m_isIcognitoMode
        
        self.navigationController?.pushViewController(previewVC, animated: false)
    }
    
    @IBAction func onClickBtnCamera(_ sender: Any) {
        m_scRecorder.capturePhoto({(error, image) in
            let previewVC = self.storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
            previewVC.m_mediaType = self.m_mediaType
            previewVC.m_imgPhoto = image
            previewVC.m_isIcognitoMode = self.m_isIcognitoMode
            
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
            previewVC.m_mediaType = self.m_mediaType
            previewVC.m_imgPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage?
            previewVC.m_isIcognitoMode = self.m_isIcognitoMode
            
            self.navigationController?.pushViewController(previewVC, animated: false)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    @IBAction func onClickBtnIcognito(_ sender: Any) {
        let btnIcognito = sender as! UIButton
        btnIcognito.isSelected = !btnIcognito.isSelected
        
        m_isIcognitoMode = btnIcognito.isSelected
        m_imgIcognitoMode.isHidden = m_isIcognitoMode
    }
    
    @IBAction func onClickBtnPublicChat(_ sender: Any) {
        
    }
    
    @IBAction func onClickBtnEvents(_ sender: Any) {
        let eventsVC = self.storyboard?.instantiateViewController(withIdentifier: "EventsViewController")
        self.navigationController?.pushViewController(eventsVC!, animated: true)
    }
    
    @IBAction func onClickBtnPrivateChat(_ sender: Any) {
        
    }
}
