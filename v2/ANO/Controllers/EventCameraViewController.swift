//
//  EventCameraViewController.swift
//  ANO
//
//  Created by Jacob May on 12/14/16.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit
import SCRecorder

class EventCameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var m_viewPreview: UIView!
    
    var m_scRecorder = SCRecorder()
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        initCamera()
    }
    
    private func initCamera() {
        m_scRecorder.maxRecordDuration = CMTimeMake(Int64(Constants.Numbers.VIDEO_MAX_SEC), 1);
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
    
    @IBAction func onClickBtnCamera(_ sender: Any) {
        m_scRecorder.capturePhoto({(error, image) in
            let newEventVC = self.storyboard?.instantiateViewController(withIdentifier: "NewEventViewController") as! NewEventViewController
            newEventVC.m_imgPhoto = image
            self.navigationController?.pushViewController(newEventVC, animated: false)
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
            let newEventVC = self.storyboard?.instantiateViewController(withIdentifier: "NewEventViewController") as! NewEventViewController
            newEventVC.m_imgPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage?
            self.navigationController?.pushViewController(newEventVC, animated: false)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    @IBAction func onClickBtnClose(_ sender: Any) {
        self.navigationController!.popViewController(animated: false)
    }
}
