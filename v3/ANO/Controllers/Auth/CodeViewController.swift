//
//  CodeViewController.swift
//  ANO
//
//  Created by Jacob May on 12/30/16.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit
import SVProgressHUD

class CodeViewController: UIViewController {
    @IBOutlet weak var m_txtVerificationCode: UITextField!
    
    var m_strUserName: String?
    var m_strUserPass: String?
    var m_strUserPhone: String?
    var m_strVerificationCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.m_txtVerificationCode.becomeFirstResponder()
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
    
    @IBAction func onClickBtnBack(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func onClickBtnResendCode(_ sender: Any) {
        m_strVerificationCode = GlobalService.sharedInstance().makeVerificationCode()
        print(m_strVerificationCode!)
        
        SVProgressHUD.show(withStatus: "Please wait...")
        WebService.sharedInstance().sendVerificationCode(PhoneNumber: m_strUserPhone!,
                                                         VerificationCode: m_strVerificationCode!,
                                                         IsSignUp: m_strUserName != nil)
        {(result, error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: error)
            } else {
                SVProgressHUD.dismiss()
                
            }
        }
    }

    @IBAction func onClickBtnOk(_ sender: Any) {
        if let strCode = m_txtVerificationCode.text {
            if strCode == m_strVerificationCode {
                if m_strUserName != nil {   // signup
                    signupUser()
                } else {
                    // move to reset password
                    let resetPasswordVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ResetPasswordViewController.self)) as! ResetPasswordViewController
                    resetPasswordVC.m_txtUserPhone = m_strUserPhone
                    self.navigationController?.pushViewController(resetPasswordVC, animated: true)
                }
            } else {
                self.view.makeToast("Invalid Code", duration: 1.5, position: .center)
            }
        }
    }
    
    func signupUser() {
        SVProgressHUD.show(withStatus: "Please wait...")
        WebService.sharedInstance().signup(UserName: m_strUserName!,
                                           UserPass: m_strUserPass!,
                                           UserPhone: m_strUserPhone!)
        { (objUser, error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: error)
            } else {
                SVProgressHUD.dismiss()
                
                GlobalService.sharedInstance().g_userMe = objUser
                GlobalService.sharedInstance().saveUserObj()
                
                GlobalService.sharedInstance().g_appDelegate?.startApplication(animated: true)
            }
        }
    }
}
