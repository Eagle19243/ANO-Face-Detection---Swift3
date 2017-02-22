//
//  PhoneNumberViewController.swift
//  ANO
//
//  Created by Jacob May on 12/30/16.
//  Copyright © 2016 DMSoft. All rights reserved.
//

import UIKit
import SVProgressHUD

class PhoneNumberViewController: UIViewController {

    @IBOutlet weak var m_txtPhoneNumber: UITextField!
    
    var m_strUserName: String?
    var m_strUserPass: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.m_txtPhoneNumber.becomeFirstResponder()
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
    @IBAction func onClickBtnSend(_ sender: Any) {
        if let strPhoneNumber = m_txtPhoneNumber.text {
            let strCode = GlobalService.sharedInstance().makeVerificationCode()
            print(strCode)
            
            SVProgressHUD.show(withStatus: "Please wait...")
            WebService.sharedInstance().sendVerificationCode(PhoneNumber: strPhoneNumber,
                                                             VerificationCode: strCode,
                                                             IsSignUp: m_strUserName != nil)
            {(result, error) in
                if let error = error {
                    SVProgressHUD.showError(withStatus: error)
                } else {
                    SVProgressHUD.dismiss()
                    
                    let codeVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: CodeViewController.self)) as! CodeViewController
                    codeVC.m_strUserName = self.m_strUserName
                    codeVC.m_strUserPass = self.m_strUserPass
                    codeVC.m_strUserPhone = strPhoneNumber
                    codeVC.m_strVerificationCode = strCode
                    self.navigationController?.pushViewController(codeVC, animated: true)
                }
            }
        }
    }

    @IBAction func onClickBtnBack(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
    }
}
