//
//  LoginVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 23/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import FBSDKLoginKit
import GoogleSignIn
//import AES256CBC
import WowonderMessengerSDK

class LoginVC: BaseVC {
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var forgotPassBtn: UIButton!
    @IBOutlet weak var usernameTextFieldTF: UITextField!
    @IBOutlet weak var passwordTextFieldTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var privacyPolicyBtn: UIButton!
    @IBOutlet weak var termsOfServiceBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
    @IBOutlet weak var facebookBtn: FBButton!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.dismissKeyboard()
        setupUI()
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
    
    
    func setupUI(){
        if ControlSettings.showSocicalLogin{
            self.googleBtn.isHidden = false
            self.facebookBtn.isHidden = false
        }else{
            self.googleBtn.isHidden = true
            self.facebookBtn.isHidden = true
        }
        self.facebookBtn.setTitle(NSLocalizedString("Login with Facebook", comment: ""), for: .normal)
        self.facebookBtn.titleLabel?.textAlignment = .center
        facebookBtn.titleLabel?.font = UIFont(name: "Poppins", size: 12.0)
        self.termsOfServiceBtn.underline()
        self.privacyPolicyBtn.underline()
         self.nameLabel.text = NSLocalizedString("WoWonder", comment: "")
        self.versionLabel.text = NSLocalizedString("Messengerv2.3", comment: "")
        self.usernameTextFieldTF.whitePlaceHolder(text: NSLocalizedString("Username", comment: ""))
        self.passwordTextFieldTF.whitePlaceHolder(text: NSLocalizedString("Password", comment: ""))
        self.forgotPassBtn.setTitle(NSLocalizedString("Forgot your Password?", comment: ""), for: .normal)
          self.loginBtn.setTitle(NSLocalizedString("Log in", comment: ""), for: .normal)
         self.signupBtn.setTitle(NSLocalizedString("Sign up", comment: ""), for: .normal)
        self.googleBtn.setTitle(NSLocalizedString("Login with google", comment: ""), for: .normal)
        self.termsOfServiceBtn.setTitle(NSLocalizedString("Terms of Service", comment: ""), for: .normal)
         self.privacyPolicyBtn.setTitle(NSLocalizedString("Privacy Policy", comment: ""), for: .normal)
        
        
        self.view.applyGradient(colours: [UIColor.startColor, UIColor.endColor], start: CGPoint(x: 1.0, y: 0.0), end: CGPoint(x: 1.0, y: 1.0), borderColor: UIColor.clear)
    }
   
    
    @IBAction func googlePressed(_ sender: Any) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    @IBAction func facebookPressed(_ sender: Any) {
        self.facebookLogin()
    }
    
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        let vc = R.storyboard.main.forgetPasswordVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        loginPressed()
        
    }
    
    
    @IBAction func signupBtnPressed(_ sender: Any) {
        let vc = R.storyboard.main.signUpVC()
        self.navigationController?.pushViewController(vc!, animated: true)
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
    private func loginPressed(){
        if appDelegate.isInternetConnected{
            if (self.usernameTextFieldTF.text?.isEmpty)!{
                let securityAlertVC = R.storyboard.main.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Please enter username."
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else if (passwordTextFieldTF.text?.isEmpty)!{
                let securityAlertVC = R.storyboard.main.securityPopupVC()
                securityAlertVC?.titleText  = "Security"
                securityAlertVC?.errorText = "Please enter password."
                self.present(securityAlertVC!, animated: true, completion: nil)
            }else{
                self.showProgressDialog(text: "Loading...")
                let username = self.usernameTextFieldTF.text ?? ""
                let password = self.passwordTextFieldTF.text ?? ""
                let deviceId = self.deviceID ?? ""
                Async.background({
                    UserManager.instance.authenticateUser(UserName: username, Password: password, DeviceId: deviceId){ (success, sessionError, serverError, error) in
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
                    }
                })
            }
            
        }else{
            self.dismissProgressDialog {
                let securityAlertVC = R.storyboard.main.securityPopupVC()
                securityAlertVC?.titleText  = "Internet Error"
                securityAlertVC?.errorText = InterNetError ?? ""
                self.present(securityAlertVC!, animated: true, completion: nil)
                log.error("internetError - \(InterNetError)")
            }
        }
        
        
    }
    private func facebookLogin(){
        if Connectivity.isConnectedToNetwork(){
            let fbLoginManager : LoginManager = LoginManager()
            
            fbLoginManager.logIn(permissions: ["email"], from: self) { (result, error) in
                if (error == nil){
                    self.showProgressDialog(text: "Loading...")
                    let fbloginresult : LoginManagerLoginResult = result!
                    if (result?.isCancelled)!{
                        self.dismissProgressDialog{
                            log.verbose("result.isCancelled = \(result?.isCancelled)")
                        }
                        return
                    }
                    if fbloginresult.grantedPermissions != nil {
                        if(fbloginresult.grantedPermissions.contains("email")) {
                            if((AccessToken.current) != nil){
                                GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                                    if (error == nil){
                                        let dict = result as! [String : AnyObject]
                                        log.debug("result = \(dict)")
                                        guard let firstName = dict["first_name"] as? String else {return}
                                        guard let lastName = dict["last_name"] as? String else {return}
                                        guard let email = dict["email"] as? String else {return}
                                        let accessToken = AccessToken.current?.tokenString
                                        Async.background({
                                            UserManager.instance.socialLogin(Provider: "facebook", AccessToken: accessToken ?? "", GoogleApiKey: "", completionBlock: { (success, sessionError,serverError, error) in
                                                if success != nil{
                                                    Async.main{
                                                        self.dismissProgressDialog{
                                                            log.verbose("Success = \(success?.accessToken)")
                                                            AppInstance.instance.getUserSession()
                                                             AppInstance.instance.fetchUserProfile()
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
                                        log.verbose("FBSDKAccessToken.current() = \(AccessToken.current?.tokenString)")
                                        
                                    }
                                })
                            }
                        }
                    }
                }
            }
            
        }else{
            self.dismissProgressDialog {
                let securityAlertVC = R.storyboard.main.securityPopupVC()
                securityAlertVC?.titleText  = "Internet Error"
                securityAlertVC?.errorText = InterNetError ?? ""
                self.present(securityAlertVC!, animated: true, completion: nil)
                log.error("internetError - \(InterNetError)")
            }
        }

    }
    private func googleLogin(access_Token:String){
        if Connectivity.isConnectedToNetwork(){
            Async.background({
                UserManager.instance.socialLogin(Provider: "google", AccessToken: access_Token ?? "", GoogleApiKey: "AIzaSyA-JSf9CU1cdMpgzROCCUpl4wOve9S94ZU", completionBlock: { (success, sessionError, serverError,error) in
                    if success != nil{
                        Async.main{
                            self.dismissProgressDialog{
                                log.verbose("Success = \(success?.accessToken)")
                                AppInstance.instance.getUserSession()
                                AppInstance.instance.fetchUserProfile()
                                
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
            
            
        }else{
            self.dismissProgressDialog {
                let securityAlertVC = R.storyboard.main.securityPopupVC()
                securityAlertVC?.titleText  = "Internet Error"
                securityAlertVC?.errorText = InterNetError ?? ""
                self.present(securityAlertVC!, animated: true, completion: nil)
                log.error("internetError - \(InterNetError)")
            }
        }
      
        
    }
    
}
extension LoginVC:GIDSignInDelegate,GIDSignInUIDelegate{
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            let userId = user.userID
            let idToken = user.authentication.accessToken  // Safe to send to
            log.verbose("user auth = \(user.authentication.accessToken)")
            let accessToken = user.authentication.accessToken ?? ""
            self.googleLogin(access_Token: accessToken)
        } else {
            log.error(error.localizedDescription)
            
        }
    }
}
