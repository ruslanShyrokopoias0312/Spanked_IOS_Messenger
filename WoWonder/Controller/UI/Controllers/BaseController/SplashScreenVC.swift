//
//  SplashScreenVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 02/05/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import WowonderMessengerSDK

class SplashScreenVC: BaseVC {
    
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var showStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        self.loadingLabel.text = NSLocalizedString("Loading Profile...", comment: "")
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_CONNECTED) { result in
            log.verbose("Internet connected!")
            self.showStack.isHidden = false
            self.activityIndicator.startAnimating()
            self.fetchUserProfile()
            
            
        }
        
        //Internet connectivity event subscription
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_DIS_CONNECTED) { result in
            log.verbose("Internet dis connected!")
            self.showStack.isHidden = true
            self.activityIndicator.stopAnimating()
            
            
        }
        self.fetchUserProfile()
        
    }
    deinit {
        SwiftEventBus.unregister(self)
        
    }
    
    private func fetchUserProfile(){
        if appDelegate.isInternetConnected{
            self.activityIndicator.startAnimating()
            let status = AppInstance.instance.getUserSession()
            if status{
                let userId = AppInstance.instance.userId
                let sessionId = AppInstance.instance.sessionId
                Async.background({
                    GetUserDataManager.instance.getUserData(user_id: userId ?? "" , session_Token: sessionId ?? "", fetch_type: API.Params.User_data) { (success, sessionError, serverError, error) in
                        if success != nil{
                            Async.main({
                                log.debug("success = \(success?.userData)")
                                AppInstance.instance.userProfile = success?.userData ?? nil
                                SwiftEventBus.unregister(self)
                                self.showStack.isHidden = true
                                self.activityIndicator.stopAnimating()
                                let dashboardNav =  R.storyboard.dashboard.dashboard()
                                dashboardNav?.modalPresentationStyle = .fullScreen
                                self.present(dashboardNav!, animated: true, completion: nil)
                                
                                
                            })
                        }else if sessionError != nil{
                            Async.main({
                                self.activityIndicator.stopAnimating()
                                self.showStack.isHidden = true
                                log.error("sessionError = \(sessionError?.errors?.errorText)")
                                self.view.makeToast(sessionError?.errors?.errorText)
                            })
                            
                        }else if serverError != nil{
                            Async.main({
                                self.activityIndicator.stopAnimating()
                                self.showStack.isHidden = true
                                log.error("serverError = \(serverError?.errors?.errorText)")
                                self.view.makeToast(serverError?.errors?.errorText)
                                
                            })
                            
                        }else {
                            Async.main({
                                self.activityIndicator.stopAnimating()
                                self.showStack.isHidden = true
                                log.error("error = \(error?.localizedDescription)")
                                self.view.makeToast(error?.localizedDescription)
                                
                            })
                        }
                    }
                })
                
            }else{
                SwiftEventBus.unregister(self)
                let mainNav =  R.storyboard.main.main()
                self.appDelegate.window?.rootViewController = mainNav
            }
        }else {
            self.view.makeToast(InterNetError)
            
        }
        
    }
    
}
