//
//  CameraViewController.swift
//  ANO
//
//  Created by Mychal Culpepper on 11/17/2016.
//  Copyright © 2016 Blue Shift Group. All rights reserved.
//

import UIKit
import SCRecorder
import AirPlay

class CameraViewController: UIViewController, SCRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var is17 = false 
    @IBOutlet weak var m_viewPreview: UIView!
    @IBOutlet weak var m_lblVideoTime: UILabel!
    @IBOutlet weak var m_lblAirPlayStatus: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var libraryButton: ANOButton!
    var m_scRecorder: SCRecorder!
    
    var m_mediaType: Constants.MediaType?
    var m_timerHold: Timer?
    var m_timerCounter: Timer?
    
    var m_nCount: Int?
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        initCamera()
        
        airplayStuffs()
    }
    
    private func airplayStuffs() {
        AirPlay.whenPossible = { _ in
            print("Possible = \(AirPlay.isPossible)")
            self.updateUI()
        }
        
        AirPlay.whenNotPossible = { _ in
            print("Not Possible = \(AirPlay.isPossible)")
            self.updateUI()
        }
        
        AirPlay.whenConnectionChanged = { _ in
            print("Connection has changed... Connected: \(AirPlay.isConnected)")
            self.updateUI()
        }
    }
    
    private func updateUI() {
        if AirPlay.isConnected {
            let device = AirPlay.connectedDevice ?? "Unknown Device"
            m_lblAirPlayStatus.text = "Connected to: \(device)"
        } else {
            m_lblAirPlayStatus.text = ""
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if is17 == true {
            cameraButton.isEnabled = false
            libraryButton.isEnabled = false
            print("value was saved")
        }
        
        m_lblVideoTime.isHidden = true
        m_scRecorder.session = nil
        m_mediaType = Constants.MediaType.Photo
        
        prepareSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        m_scRecorder.previewViewFrameChanged()
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
    @IBAction func onClickSwitchCamera(_ sender: Any) {
        m_scRecorder.switchCaptureDevices()
    }

    @IBAction func onClickBtnFlash(_ sender: Any) {
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
    
    @IBAction func onTouchDownSnapCamera(_ sender: Any) {
        if #available(iOS 10.0, *) {
            m_timerHold = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false, block: {(timer) in
                timer.invalidate()
                self.m_timerHold = nil
                
                self.m_mediaType = Constants.MediaType.Video
                self.m_scRecorder.captureSessionPreset = SCRecorderTools.bestCaptureSessionPresetCompatibleWithAllDevices()
                self.m_scRecorder.record()
                
                self.m_lblVideoTime.isHidden = false;
                self.m_nCount = Constants.Numbers.VIDEO_MAX_SEC
                self.m_lblVideoTime.text = ":0\(self.m_nCount!)"
                
                self.m_timerCounter = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {(timer) in
                    self.m_nCount = self.m_nCount! - 1
                    self.m_lblVideoTime.text = ":0\(self.m_nCount!)"
                    
                    if self.m_nCount == 0 {
                        self.m_timerCounter?.invalidate()
                        self.m_timerCounter = nil
                    }
                })
            })
        } else {
            // Fallback on earlier versions
        }
    }

    @IBAction func onTouchUpSnapCamera(_ sender: Any) {
        if (m_mediaType == Constants.MediaType.Photo) {
            // stop hold timer
            if m_timerHold != nil {
                m_timerHold?.invalidate()
                m_timerHold = nil
            }
            
            takePhoto()
        } else {
            if m_timerCounter != nil {
                m_timerCounter?.invalidate()
                m_timerCounter = nil
            }
            
            m_scRecorder.pause({ 
                self.saveVideo(recordSession: self.m_scRecorder.session!)
            })
        }
    }
    
    @IBAction func onClickBtnEvents(_ sender: Any) {
        if is17 == true{
            let eventsVC = self.storyboard?.instantiateViewController(withIdentifier: "EventsViewController") as! EventsViewController
            
            eventsVC.isStill17 = true
            self.navigationController?.pushViewController(eventsVC, animated: true)
        }
        if is17 == false{
        let eventsVC = self.storyboard?.instantiateViewController(withIdentifier: "EventsViewController")
        self.navigationController?.pushViewController(eventsVC!, animated: true)
        }
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
            
            self.navigationController?.pushViewController(previewVC, animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    private func initCamera() {
        m_scRecorder = SCRecorder();
        m_scRecorder.maxRecordDuration = CMTimeMake(Int64(Constants.Numbers.VIDEO_MAX_SEC), 1);

        m_scRecorder.delegate = self;
        m_scRecorder.autoSetVideoOrientation = false;

        m_scRecorder.previewView = self.m_viewPreview;
        m_scRecorder.initializeSessionLazily = false;

        do {
            try m_scRecorder.prepare()
        } catch {
            print("Error camera prepare")
        }
    }
    
    private func prepareSession() {
        let session = SCRecordSession()
        session.fileType = AVFileTypeQuickTimeMovie;
        
        m_scRecorder.captureSessionPreset = AVCaptureSessionPresetPhoto;
        m_scRecorder.session = session;
        
        m_scRecorder.startRunning();
    }
    
    private func takePhoto() {
        m_scRecorder.capturePhoto({(error, image) in
            let previewVC = self.storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
            previewVC.m_mediaType = self.m_mediaType
            previewVC.m_imgPhoto = image
            
            self.navigationController?.pushViewController(previewVC, animated: true)
        })
    }
    
    private func saveVideo(recordSession: SCRecordSession) {
        let previewVC = self.storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
        previewVC.m_mediaType = self.m_mediaType
        previewVC.m_videoSession = recordSession
        
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
    
    //SCRecorderDelegate
    func recorder(_ recorder: SCRecorder, didComplete session: SCRecordSession) {
        saveVideo(recordSession: session)
    }
}
