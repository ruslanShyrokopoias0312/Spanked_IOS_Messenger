
//
//  ForgetPasswordVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 23/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import WowonderMessengerSDK
class ForgetPasswordVC: BaseVC {
    
    @IBOutlet weak var downTextLabel: UILabel!
    @IBOutlet weak var forgetPassLabel: UILabel!
    @IBOutlet weak var emailTextFieldTF: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.dismissKeyboard()
        setupUI()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    func setupUI(){
        self.view.backgroundColor = UIColor.pinkColor
        self.emailTextFieldTF.whitePlaceHolder(text: NSLocalizedString("Please write your email", comment: ""))
        self.forgetPassLabel.text = NSLocalizedString("Forgot your password", comment: "")
        self.downTextLabel.text = NSLocalizedString("Don't worry type your email here and will will recover it for you.", comment: "")
        self.sendBtn.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        self.forgetPasswordPressed()
    }
    private func forgetPasswordPressed(){
        
        if appDelegate.isInternetConnected{
            
            if (self.emailTextFieldTF.text?.isEmpty)!{
                let securityAlertVC = R.storyboard.main.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Please enter email."
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else if !(emailTextFieldTF.text?.isEmail)!{
                let securityAlertVC = R.storyboard.main.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Email is badly formatted."
                self.present(securityAlertVC!, animated: true, completion: nil)
            }else{
                self.showProgressDialog(text: "Loading...")
                
                let email = self.emailTextFieldTF.text ?? ""
                
                Async.background({
                    UserManager.instance.forgetPassword(Email: email, completionBlock: { (success, sessionError, serverError, error) in
                        if success != nil{
                            Async.main{
                                self.dismissProgressDialog{
                                    log.verbose("Success = \(success?.apiStatus)")
                                    let securityAlertVC = R.storyboard.main.securityPopupVC()
                                    securityAlertVC?.titleText = "Check your email"
                                    securityAlertVC?.errorText = "We Sent email to \(email). Click the link in the email to reset your password."
                                    self.present(securityAlertVC!, animated: true, completion: nil)
                                    
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



