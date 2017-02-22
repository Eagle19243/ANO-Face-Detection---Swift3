//
//  ResetPasswordViewController.swift
//  ANO
//
//  Created by Jacob May on 1/4/17.
//  Copyright © 2017 DMSoft. All rights reserved.
//

import UIKit
import SVProgressHUD

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var m_txtNewPass: UITextField!
    @IBOutlet weak var m_txtConfirmPass: UITextField!
    
    var m_txtUserPhone: String?
    
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

    @IBAction func onClickBtnGoToLogin(_ sender: Any) {
        self.navigationController!.popToRootViewController(animated: true)
    }
    
    @IBAction func onClickBtnResetPassword(_ sender: Any) {
        if isValidForm() {
            SVProgressHUD.show(withStatus: "Please wait...")
            WebService.sharedInstance().resetPassword(PhoneNumber: m_txtUserPhone!,
                                                      NewPass: m_txtNewPass.text!)
            { (response, error) in
                if let error = error {
                    SVProgressHUD.showError(withStatus: error)
                } else {
                    SVProgressHUD.showSuccess(withStatus: response)
                }
            }
        }
    }
    
    func isValidForm() -> Bool {
        var isValid = false
        if (m_txtNewPass.text?.characters.count)! < Constants.Numbers.PASSWORD_LENGTH {
            self.view.makeToast(Constants.Toasts.SHORT_PASSWORD)
        } else if m_txtNewPass.text != m_txtConfirmPass.text {
            self.view.makeToast(Constants.Toasts.DISMATCH_PASSWORD)
        } else {
            isValid = true
        }
        
        return isValid
    }
}
