//
//  SignUpVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 23/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import WowonderMessengerSDK
class SignUpVC: BaseVC {
    @IBOutlet weak var registerNowLabel: UILabel!
    
    @IBOutlet weak var downTextLabel: UILabel!
    @IBOutlet weak var confirmPasswordTextFieldTF: UITextField!
    @IBOutlet weak var passwordTextFieldTF: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextFieldTF: UITextField!
    @IBOutlet weak var agreeTermsBtn: UIButton!
    @IBOutlet weak var privacyPolicyBtn: UIButton!
    @IBOutlet weak var termOfServiceBtn: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    
    private var agreeStatus:Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.dismissKeyboard()
        setupUI()
        log.verbose("self.deviceId = \(self.deviceID)")
      
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signupPressed(_ sender: Any) {
        self.registerPressed()
    }
    @IBAction func agreeTermsPressed(_ sender: Any) {
        self.agreeStatus = !self.agreeStatus!
        if self.agreeStatus!{
            self.agreeTermsBtn.setImage(UIImage(named: "ic_check"), for: .normal)
        }else{
            self.agreeTermsBtn.setImage(UIImage(named: "ic_uncheck"), for: .normal)
        }
    }
    @IBAction func termsOfServicePressed(_ sender: Any) {
        let vc = R.storyboard.main.webViewVC()
        vc?.url = ""
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func privacyPolicyPressed(_ sender: Any) {
        let vc = R.storyboard.main.webViewVC()
        vc?.url = ""
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    func setupUI(){
      
        self.emailTextFieldTF.whitePlaceHolder(text:   NSLocalizedString("Email", comment: ""))
        self.usernameTextField.whitePlaceHolder(text:   NSLocalizedString("Username", comment: ""))
        self.passwordTextFieldTF.whitePlaceHolder(text:   NSLocalizedString("Password", comment: ""))
        self.confirmPasswordTextFieldTF.whitePlaceHolder(text:   NSLocalizedString("Confirm Password", comment: ""))
        self.downTextLabel.text =  NSLocalizedString("Register now and start chatting with your friends", comment: "")
              self.registerNowLabel.text =  NSLocalizedString("Register now", comment: "")
        self.termOfServiceBtn.setTitle(NSLocalizedString("Terms of Service", comment: ""), for: .normal)
        self.privacyPolicyBtn.setTitle(NSLocalizedString("Privacy Policy", comment: ""), for: .normal)
        self.signupBtn.setTitle(NSLocalizedString("Sign Up", comment: ""), for: .normal)
        
        self.view.backgroundColor = UIColor.pinkColor
        
        self.privacyPolicyBtn.underline()
        self.termOfServiceBtn.underline()
    }
    private func registerPressed(){
        if appDelegate.isInternetConnected{
            if !self.agreeStatus!{
                let securityAlertVC = R.storyboard.main.securityPopupVC()
                 securityAlertVC?.titleText  = "Warning !"
                securityAlertVC?.errorText = "You can not access your disapproval of the Terms and Conditions."
                self.present(securityAlertVC!, animated: true, completion: nil)
            }  else if (self.usernameTextField.text?.isEmpty)!{
                let securityAlertVC = R.storyboard.main.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Please enter username."
                self.present(securityAlertVC!, animated: true, completion: nil)
            }else if (emailTextFieldTF.text?.isEmpty)!{
                let securityAlertVC = R.storyboard.main.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Please enter email."
                self.present(securityAlertVC!, animated: true, completion: nil)
            }else if (passwordTextFieldTF.text?.isEmpty)!{
                let securityAlertVC = R.storyboard.main.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Please enter password."
                self.present(securityAlertVC!, animated: true, completion: nil)
            }else if (confirmPasswordTextFieldTF.text?.isEmpty)!{
                let securityAlertVC = R.storyboard.main.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Please enter confirm password."
                self.present(securityAlertVC!, animated: true, completion: nil)
            }else if (passwordTextFieldTF.text != confirmPasswordTextFieldTF.text ){
                let securityAlertVC = R.storyboard.main.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Password do not match."
                self.present(securityAlertVC!, animated: true, completion: nil)
            }else if !((emailTextFieldTF.text?.isEmail)!){
                let securityAlertVC = R.storyboard.main.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Email is badly formatted."
                self.present(securityAlertVC!, animated: true, completion: nil)
            }
            else{
                self.showProgressDialog(text: "Loading...")
                let username = self.usernameTextField.text ?? ""
                let email = self.emailTextFieldTF.text ?? ""
                let password = self.passwordTextFieldTF.text ?? ""
                let confirmPassword = self.confirmPasswordTextFieldTF.text ?? ""
                let deviceId = self.deviceID ?? ""
                Async.background({
                    UserManager.instance.RegisterUser(Email: email, UserName: username, DeviceId: deviceId, Password: password, ConfirmPassword: confirmPassword, completionBlock: { (success, sessionError, serverError, error) in
                        if success != nil{
                            Async.main{
                                self.dismissProgressDialog{
                                    log.verbose("Success = \(success?.accessToken)")
                                    AppInstance.instance.getUserSession()
                                     AppInstance.instance.fetchUserProfile()
                                      UserDefaults.standard.setPassword(value: password, ForKey: Local.USER_SESSION.Current_Password)
                                    let vc = R.storyboard.main.introVC()
                                    self.navigationController?.pushViewController(vc!, animated: true)
                                    self.view.makeToast("Login Successfull!!")
                                }
                                
                            }
                        }else if sessionError != nil{
                            Async.main{
                                self.dismissProgressDialog {
                                    log.verbose("session Error = \(sessionError?.errors?.errorText)")
                                    let securityAlertVC = R.storyboard.main.securityPopupVC()
                                    securityAlertVC?.titleText  = "Security"
                                    securityAlertVC?.errorText = sessionError?.errors?.errorText ?? ""
                                    self.present(securityAlertVC!, animated: true, completion: nil)
                                    
                                }
                            }
                        }else if serverError != nil{
                            Async.main({
                                self.dismissProgressDialog {
                                    
                                    log.verbose("serverError = \(serverError?.errors?.errorText)")
                                    
                                    let securityAlertVC = R.storyboard.main.securityPopupVC()
                                    securityAlertVC?.titleText  = "Security"
                                    securityAlertVC?.errorText = sessionError?.errors?.errorText ?? ""
                                    self.present(securityAlertVC!, animated: true, completion: nil)
                                }
                            })
                            
                        }else {
                            Async.main({
                                self.dismissProgressDialog {
                                    log.verbose("error = \(error?.localizedDescription)")
                                    let securityAlertVC = R.storyboard.main.securityPopupVC()
                                    securityAlertVC?.titleText  = "Security"
                                    securityAlertVC?.errorText = error?.localizedDescription ?? ""
                                    self.present(securityAlertVC!, animated: true, completion: nil)
                                }
                            })
                        }
                    })
                  
                })
            }
            
        }else{
            self.dismissProgressDialog {
                let securityAlertVC = R.storyboard.main.securityPopupVC()
                securityAlertVC?.titleText  = "Internet Error "
                securityAlertVC?.errorText = InterNetError ?? ""
                self.present(securityAlertVC!, animated: true, completion: nil)
                log.error("internetError - \(InterNetError)")
            }
        }
        
        
    }
    
}
    

