//
//  UserManager.swift
//  WoWonder
//
//  Created by Macbook Pro on 29/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import WowonderMessengerSDK
class UserManager{
    static let instance = UserManager()
    
    func authenticateUser(UserName: String, Password: String,DeviceId:String, completionBlock: @escaping (_ Success:LoginModel.LoginSuccessModel?,_ AuthError:LoginModel.LoginErrorModel?,_ ServerKeyError:LoginModel.ServerKeyErrorModel?, Error?) ->()){
        let params = [
            API.Params.Username: UserName,
            API.Params.Password: Password,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.DeviceId : DeviceId
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.AUTH_Constants_Methods.LOGIN_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                log.verbose("Response = \(res)")
                guard let apiStatus = res["api_status"]  as? Any else {return}
                if apiStatus is Int{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(LoginModel.LoginSuccessModel.self, from: data)
                    log.debug("Success = \(result.accessToken ?? "")")
                    let User_Session = [Local.USER_SESSION.Access_token:result.accessToken,Local.USER_SESSION.User_id:result.userID] as [String : Any]
                    UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                    completionBlock(result,nil,nil,nil)
                }else{
                    let apiStatusString = apiStatus as? String
                    if apiStatusString == "400" {
                        log.verbose("apiStatus String = \(apiStatus)")
                        let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                        let result = try! JSONDecoder().decode(LoginModel.LoginErrorModel.self, from: data)
                        log.error("AuthError = \(result.errors!.errorText)")
                        completionBlock(nil,result,nil,nil)
                    }else if apiStatusString == "404" {
                        let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                        let result = try! JSONDecoder().decode(LoginModel.ServerKeyErrorModel.self, from: data)
                        log.error("AuthError = \(result.errors!.errorText)")
                        completionBlock(nil,nil,result,nil)
                    }
                }
                
                
            }else{
                log.error("error = \(response.error?.localizedDescription)")
                completionBlock(nil,nil,nil,response.error)
            }
        }
    }
    func RegisterUser(Email:String,UserName: String,DeviceId:String, Password: String,ConfirmPassword:String, completionBlock: @escaping (_ Success:RegisterModel.RegisterSuccessModel?,_ AuthError:RegisterModel.RegisterErrorModel?,_ ServerKeyError:RegisterModel.ServerKeyErrorModel?, Error?) ->()){
        let params = [
            
            API.Params.Username: UserName,
            API.Params.Email: Email,
            API.Params.Password: Password,
            API.Params.ConfirmPassword: ConfirmPassword,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.DeviceId : DeviceId
            
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.AUTH_Constants_Methods.REGISTER_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                log.verbose("Response = \(res)")
                guard let apiStatus = res["api_status"]  as? Any else {return}
                if apiStatus is Int{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(RegisterModel.RegisterSuccessModel.self, from: data)
                    log.debug("Success = \(result.accessToken ?? "")")
                    let User_Session = [Local.USER_SESSION.Access_token:result.accessToken,Local.USER_SESSION.User_id:result.userID] as [String : Any]
                    UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                    completionBlock(result,nil,nil,nil)
                }else{
                    let apiStatusString = apiStatus as? String
                    if apiStatusString == API.ERROR_CODES.E_400 {
                        log.verbose("apiStatus String = \(apiStatus)")
                        let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                        let result = try! JSONDecoder().decode(RegisterModel.RegisterErrorModel.self, from: data)
                        log.error("AuthError = \(result.errors!.errorText)")
                        completionBlock(nil,result,nil,nil)
                    }else if apiStatusString == API.ERROR_CODES.E_404{
                        let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                        let result = try! JSONDecoder().decode(RegisterModel.ServerKeyErrorModel.self, from: data)
                        log.error("AuthError = \(result.errors!.errorText)")
                        completionBlock(nil,nil,result,nil)
                    }
                }
            }else{
                log.error("error = \(response.error?.localizedDescription)")
                completionBlock(nil,nil,nil,response.error)
            }
        }
        
    }
    func forgetPassword(Email:String, completionBlock: @escaping (_ Success:ForgetPasswordModel.ForgetPasswordSuccessModel?,_ AuthError:ForgetPasswordModel.ForgetPasswordErrorModel?,_ ServerKeyError:ForgetPasswordModel.ServerKeyErrorModel?, Error?) ->()){
        let params = [
            API.Params.Email: Email,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.AUTH_Constants_Methods.FORGETPASSWORD_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                log.verbose("Response = \(res)")
                guard let apiStatus = res["api_status"]  as? Any else {return}
                if apiStatus is Int{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(ForgetPasswordModel.ForgetPasswordSuccessModel.self, from: data)
                    log.debug("Success = \(result.apiStatus ?? 0)")
                    completionBlock(result,nil,nil,nil)
                }else{
                    let apiStatusString = apiStatus as? String
                    if apiStatusString == API.ERROR_CODES.E_400 {
                        log.verbose("apiStatus String = \(apiStatus)")
                        let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                        let result = try! JSONDecoder().decode(ForgetPasswordModel.ForgetPasswordErrorModel.self, from: data)
                        log.error("AuthError = \(result.errors!.errorText)")
                        completionBlock(nil,result,nil,nil)
                    }else if apiStatusString == API.ERROR_CODES.E_404{
                        let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                        let result = try! JSONDecoder().decode(ForgetPasswordModel.ServerKeyErrorModel.self, from: data)
                        log.error("AuthError = \(result.errors!.errorText)")
                        completionBlock(nil,nil,result,nil)
                    }
                }
                
                
            }else{
                log.error("error = \(response.error?.localizedDescription)")
                completionBlock(nil,nil,nil,response.error)
            }
        }
        
    }
    func socialLogin(Provider:String,AccessToken:String,GoogleApiKey:String?, completionBlock: @escaping (_ Success:SocialLoginModel.SocialLoginSuccessModel?,_ AuthError:SocialLoginModel.SocialLoginErrorModel?,_ ServerKeyError:SocialLoginModel.ServerKeyErrorModel?, Error?) ->()){
        var params = [String:String]()
        if Provider == API.SOCIAL_PROVIDERS.FACEBOOK{
            params = [
                API.Params.Provider: Provider,
                API.Params.AccessToken: AccessToken,
                API.Params.ServerKey: API.SERVER_KEY.Server_Key
            ]
        }else{
            params = [
                API.Params.Provider: Provider,
                API.Params.AccessToken: AccessToken,
                API.Params.ServerKey: API.SERVER_KEY.Server_Key,
                API.Params.Google_Key : GoogleApiKey
                ] as! [String : String]
        }
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.AUTH_Constants_Methods.SOCIAL_LOGIN_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                log.verbose("Response = \(res)")
                guard let apiStatus = res["api_status"]  as? Any else {return}
                if apiStatus is Int{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(SocialLoginModel.SocialLoginSuccessModel.self, from: data)
                    log.debug("Success = \(result.apiStatus ?? 0)")
                    let User_Session = [Local.USER_SESSION.Access_token:result.accessToken,Local.USER_SESSION.User_id:result.userID] as [String : Any]
                    UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                    completionBlock(result,nil,nil,nil)
                }else{
                    let apiStatusString = apiStatus as? String
                    if apiStatusString == API.ERROR_CODES.E_400 {
                        log.verbose("apiStatus String = \(apiStatus)")
                        let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                        let result = try! JSONDecoder().decode(SocialLoginModel.SocialLoginErrorModel.self, from: data)
                        log.error("AuthError = \(result.errors!.errorText)")
                        completionBlock(nil,result,nil,nil)
                    }else if apiStatusString == API.ERROR_CODES.E_404{
                        let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                        let result = try! JSONDecoder().decode(SocialLoginModel.ServerKeyErrorModel.self, from: data)
                        log.error("AuthError = \(result.errors!.errorText)")
                        completionBlock(nil,nil,result,nil)
                    }
                }
                
                
            }else{
                log.error("error = \(response.error?.localizedDescription)")
                completionBlock(nil,nil,nil,response.error)
            }
        }
        
    }
    func deleteUser(sessionToken:String,password:String, completionBlock: @escaping (_ Success:DeleteUserModel.DeleteUserSuccessModel?,_ AuthError:DeleteUserModel.DeleteUserErrorModel?,_ ServerKeyError:DeleteUserModel.ServerKeyErrorModel?, Error?) ->()){
        let params = [
            
            API.Params.Password: password,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.AUTH_Constants_Methods.DELETE_USER_API + "\(sessionToken)", method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.result.value != nil){
                guard let res = response.result.value as? [String:Any] else {return}
                log.verbose("Response = \(res)")
                guard let apiStatus = res["api_status"]  as? Any else {return}
                if apiStatus is Int{
                    log.verbose("apiStatus Int = \(apiStatus)")
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(DeleteUserModel.DeleteUserSuccessModel.self, from: data)
                    log.debug("Success = \(result.apiStatus ?? 0)")
                    completionBlock(result,nil,nil,nil)
                }else{
                    let apiStatusString = apiStatus as? String
                    if apiStatusString == API.ERROR_CODES.E_400 {
                        log.verbose("apiStatus String = \(apiStatus)")
                        let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                        let result = try! JSONDecoder().decode(DeleteUserModel.DeleteUserErrorModel.self, from: data)
                        log.error("AuthError = \(result.errors!.errorText)")
                        completionBlock(nil,result,nil,nil)
                    }else if apiStatusString == API.ERROR_CODES.E_404{
                        let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                        let result = try! JSONDecoder().decode(DeleteUserModel.ServerKeyErrorModel.self, from: data)
                        log.error("AuthError = \(result.errors!.errorText)")
                        completionBlock(nil,nil,result,nil)
                    }
                }
                
                
            }else{
                log.error("error = \(response.error?.localizedDescription)")
                completionBlock(nil,nil,nil,response.error)
            }
        }
        
    }
    
}
