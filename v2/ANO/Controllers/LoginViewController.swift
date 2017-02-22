//
//  LoginViewController.swift
//  ANO
//
//  Created by Jacob May on 12/13/16.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit
import SVProgressHUD
import SCLAlertView

class LoginViewController: UIViewController {

    @IBOutlet weak var m_txtUserName: UITextField!
    @IBOutlet weak var m_txtPassword: UITextField!
    
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
    
    @IBAction func onClickBtnSave(_ sender: Any) {
        if (validLoginForm()) {
            SVProgressHUD.show(withStatus: "Logging in...")
            FirebaseService.sharedInstance.authUser(username: m_txtUserName.text!, password: m_txtPassword.text!) {(objUser, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error)
                } else {
                    SVProgressHUD.dismiss()
                    User.currentUser = objUser
                    let cameraVC = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController")
                    GlobalService.sharedInstance.cameraVC = cameraVC
                    self.navigationController?.pushViewController(cameraVC!, animated: true)
                }
            }
        }
    }
    
    func validLoginForm() -> Bool {
        var isValid = false
        
        if m_txtUserName.text?.characters.count == 0 {
            SVProgressHUD.showError(withStatus: Constants.Errors.NO_USERNAME)
        } else if (m_txtPassword.text?.characters.count)! < Constants.Numbers.PASSWORD_LENGTH {
            SVProgressHUD.showError(withStatus: Constants.Errors.SHORT_PASSWORD)
        } else {
            isValid = true
        }
        
        return isValid
    }
}
