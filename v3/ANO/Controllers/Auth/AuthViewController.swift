//
//  AuthViewController.swift
//  ANO
//
//  Created by Jacob May on 12/30/16.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit
import Toast_Swift
import SVProgressHUD

class AuthViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var m_txtSignupUserName: UITextField!
    @IBOutlet weak var m_txtSignupPassword: UITextField!
    
    @IBOutlet weak var m_txtLoginUserName: UITextField!
    @IBOutlet weak var m_txtLoginPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    //UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == m_txtLoginUserName {
            m_txtLoginPassword.becomeFirstResponder()
        } else if textField == m_txtLoginPassword {
            m_txtLoginPassword.resignFirstResponder()
        } else if textField == m_txtSignupUserName {
            m_txtSignupPassword.becomeFirstResponder()
        } else {
            m_txtSignupPassword.resignFirstResponder()
        }
        
        return true
    }
    
    @IBAction func onClickBtnContinue(_ sender: Any) {
        if validSignUpForm() {
            let phoneNumberVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: PhoneNumberViewController.self)) as! PhoneNumberViewController
            phoneNumberVC.m_strUserName = m_txtSignupUserName.text
            phoneNumberVC.m_strUserPass = m_txtSignupPassword.text
            self.navigationController?.pushViewController(phoneNumberVC, animated: true)
        }
    }
    
    func validSignUpForm() -> Bool {
        var isValid = false
        if m_txtSignupUserName.text?.characters.count == 0 {
            self.view.makeToast(Constants.Toasts.NO_USERNAME)
        } else if (m_txtSignupPassword.text?.characters.count)! < Constants.Numbers.PASSWORD_LENGTH {
            self.view.makeToast(Constants.Toasts.SHORT_PASSWORD)
        } else {
            isValid = true
        }
        
        return isValid
    }
    
    @IBAction func onClickBtnForgotPassword(_ sender: Any) {
        let phoneNumberVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: PhoneNumberViewController.self))
        self.navigationController!.pushViewController(phoneNumberVC!, animated: true)
    }
    
    @IBAction func onClickBtnLogin(_ sender: Any) {
        if validLoginForm() {
            SVProgressHUD.show(withStatus: "Please wait...")
            WebService.sharedInstance().login(UserName: m_txtLoginUserName.text!,
                                              UserPass: m_txtLoginPassword.text!)
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
    
    func validLoginForm() -> Bool {
        var isValid = false
        if m_txtLoginUserName.text?.characters.count == 0 {
            self.view.makeToast(Constants.Toasts.NO_USERNAME)
        } else if (m_txtLoginPassword.text?.characters.count)! < Constants.Numbers.PASSWORD_LENGTH {
            self.view.makeToast(Constants.Toasts.SHORT_PASSWORD)
        } else {
            isValid = true
        }
        
        return isValid
    }
}
