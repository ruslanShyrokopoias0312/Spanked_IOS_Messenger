//
//  MyAccountVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 27/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Async
import WowonderMessengerSDK
class MyAccountVC: BaseVC {
    
    @IBOutlet weak var femaleLabel: UILabel!
    @IBOutlet weak var maleLabel: UILabel!
    @IBOutlet weak var maleRadioBtn: UIButton!
    @IBOutlet weak var femaleRadioBtn: UIButton!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var usernameTextField: SkyFloatingLabelTextField!
    
    private var gender:String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.showData()
        
    }
    
    
    @IBAction func maleRadioPressed(_ sender: Any) {
        maleRadioBtn.setImage(R.image.ic_radio_on(), for: .normal)
        femaleRadioBtn.setImage(R.image.ic_radio_off(), for: .normal)
        self.gender = "male"
    }
    
    @IBAction func femaleRadioPressed(_ sender: Any) {
        maleRadioBtn.setImage(R.image.ic_radio_off(), for: .normal)
        femaleRadioBtn.setImage(R.image.ic_radio_on(), for: .normal)
        self.gender = "female"
    }
    private func setupUI(){
        
        self.maleLabel.text = NSLocalizedString("Male", comment: "")
         self.femaleLabel.text = NSLocalizedString("Female", comment: "")
        maleRadioBtn.setImage(R.image.ic_radio_on(), for: .normal)
        self.title = "My Account"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let Save = UIBarButtonItem(title: "Save", style: .done, target: self, action: Selector("Save"))
        self.navigationItem.rightBarButtonItem = Save
    }
    private func updateMyAccount(){
        self.showProgressDialog(text: "Loading...")
        let sessionToken = AppInstance.instance.sessionId ?? ""
        let email = emailTextField.text ?? ""
        let username = usernameTextField.text ?? ""
        let genderbind = self.gender ?? ""
        
        Async.background({
            SettingsManager.instance.updateMyAccount(session_Token: sessionToken, email: email, username: username, gender: genderbind, completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("success = \(success?.message ?? "")")
                            self.view.makeToast(success?.message ?? "")
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
    private func showData(){
        self.usernameTextField.text = AppInstance.instance.userProfile?.username ?? ""
        self.emailTextField.text = AppInstance.instance.userProfile?.email ?? ""
        if AppInstance.instance.userProfile?.genderText == "Male" || AppInstance.instance.userProfile?.genderText == "male"{
            maleRadioBtn.setImage(R.image.ic_radio_on(), for: .normal)
            femaleRadioBtn.setImage(R.image.ic_radio_off(), for: .normal)
            
        }else{
            maleRadioBtn.setImage(R.image.ic_radio_off(), for: .normal)
            femaleRadioBtn.setImage(R.image.ic_radio_on(), for: .normal)
        }
    }

    @objc func Save(){
        log.verbose("savePressed!!")
        self.updateMyAccount()
    }

}
