//
//  ChangePasswordVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 27/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Async
import WowonderMessengerSDK

class ChangePasswordVC: BaseVC {

  
    @IBOutlet weak var repeatPasswordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var newPasswordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var currentPasswordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var resetPasswordView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()

        // Do any additional setup after loading the view.
    }
    
    private func updatePassword(){
        if (self.currentPasswordTextField.text?.isEmpty)!{
            self.view.makeToast("Please enter current password.")
        }else if (self.newPasswordTextField.text?.isEmpty)!{
              self.view.makeToast("Please enter current new password.")
        }else if (self.repeatPasswordTextField.text?.isEmpty)!{
            self.view.makeToast("Please enter current confirm password.")
        }else if self.newPasswordTextField.text != self.repeatPasswordTextField.text{
             self.view.makeToast("Password does not match. Try again!")
            
        }else {
            self.showProgressDialog(text: "Loading...")
            let sessionToken = AppInstance.instance.sessionId ?? ""
            let currentPassword = self.currentPasswordTextField.text ?? ""
            let newPassword = self.newPasswordTextField.text ?? ""
            
            Async.background({
                SettingsManager.instance.updatePassword(session_Token: sessionToken, currentPassword: currentPassword, newPassword: newPassword, completionBlock: { (success, sessionError, serverError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.message ?? "")")
                                self.view.makeToast("Password has been changed!")
                                AppInstance.instance.fetchUserProfile()
                                
                            }
                            
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.errors?.errorText)")
                                self.view.makeToast(sessionError?.errors?.errorText ?? "")
                            }
                            
                        })
                        
                        
                    }else if serverError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("serverError = \(serverError?.errors?.errorText ?? "")")
                                self.view.makeToast(serverError?.errors?.errorText ?? "")
                            }
                            
                        })
                        
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription)")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                            
                        })
                        
                    }
                })
              
            })
        }
      
        
        
    }
   

    private func setupUI(){
        self.currentPasswordTextField.placeholder = NSLocalizedString("Current Password", comment: "")
        self.newPasswordTextField.placeholder = NSLocalizedString("New Password", comment: "")
        self.repeatPasswordTextField.placeholder = NSLocalizedString("Repeat Password", comment: "")
        
        self.title = "Change Password"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let Save = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .done, target: self, action: Selector("Save"))
        self.navigationItem.rightBarButtonItem = Save
        
        let resetPasswordTapGesture = UITapGestureRecognizer(target: self, action: #selector(resetPasswordTapped(sender:)))
        self.resetPasswordView.addGestureRecognizer(resetPasswordTapGesture)
    }
    @objc func resetPasswordTapped(sender: UITapGestureRecognizer) {
        let vc = R.storyboard.main.forgetPasswordVC()
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    @objc func Save(){
log.verbose("savedPressed!!")
        self.updatePassword()
        
    }
    
    
    
}
