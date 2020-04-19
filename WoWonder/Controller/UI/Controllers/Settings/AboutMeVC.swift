//
//  AboutMeVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 26/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import WowonderMessengerSDK
class AboutMeVC: BaseVC {
    @IBOutlet weak var okBtn: UIButton!
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var aboutMeTextField: CustomTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func okPressed(_ sender: Any) {
        self.updateAboutMe()
    }
    
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    private func setupUI(){
        self.aboutMeLabel.text = NSLocalizedString("About me", comment: "")
        self.cancelBtn.setTitle("CANCEL", for: .normal)
        self.okBtn.setTitle("OK", for: .normal)
        self.aboutMeTextField.text = AppInstance.instance.userProfile?.about ?? ""
    }
    private func updateAboutMe(){
        self.showProgressDialog(text: "Loading...")
        let sessionToken = AppInstance.instance.sessionId ?? ""
        let aboutMe  = self.aboutMeTextField.text ?? ""
        
        Async.background({
            SettingsManager.instance.updateAboutMe(session_Token: sessionToken, aboutme: aboutMe, completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("success = \(success?.message ?? "")")
                            self.view.makeToast(success?.message ?? "")
                            AppInstance.instance.fetchUserProfile()
                            self.dismiss(animated: true, completion: nil)
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
