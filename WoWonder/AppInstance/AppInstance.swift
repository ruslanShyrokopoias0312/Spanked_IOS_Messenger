//
//  AppInstance.swift
//  WoWonder
//
//  Created by Macbook Pro on 02/05/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Async
import UIKit
import WowonderMessengerSDK
class AppInstance {
    
    // MARK: - Properties
    
    static let instance = AppInstance()
    
    var userId:String? = nil
    var sessionId:String? = nil
    var genderText:String? = "all"
    var profilePicText:String? = "all"
    var statusText:String? = "all"
    var addCount:Int? = 0

    
    // MARK: -
    var userProfile:GetUserDataModel.UserData?
    
    func getUserSession()->Bool{
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        if localUserSessionData.isEmpty{
            return false
            
        }else {
            self.userId = localUserSessionData[Local.USER_SESSION.User_id] as! String
            self.sessionId = localUserSessionData[Local.USER_SESSION.Access_token] as! String
            return true
        }
        
    }
     func fetchUserProfile(){
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
                                
                                
                            })
                        }else if sessionError != nil{
                            Async.main({
                               
                                log.error("sessionError = \(sessionError?.errors?.errorText)")
                              
                            })
                            
                        }else if serverError != nil{
                            Async.main({
                            
                                log.error("serverError = \(serverError?.errors?.errorText)")
                            
                                
                            })
                            
                        }else {
                            Async.main({
                                log.error("error = \(error?.localizedDescription)")
                            })
                        }
                    }
                })
        }else {
            log.error(InterNetError)
         
            
        }
        
    }
}
