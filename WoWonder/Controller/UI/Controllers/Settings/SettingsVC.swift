//
//  SettingsVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 26/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import WowonderMessengerSDK

class SettingsVC: UIViewController {
    @IBOutlet weak var whoCanFollowMeLabel: UILabel!
    
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var deleteAccountLabel: UILabel!
    @IBOutlet weak var reportAProblemLabel: UILabel!
    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var supportLabel: UILabel!
    @IBOutlet weak var clearCallLogLabel: UILabel!
    @IBOutlet weak var generalLable: UILabel!
    @IBOutlet weak var conversationTonesDownTextLabel: UILabel!
    @IBOutlet weak var conversationTonesLabel: UILabel!
    @IBOutlet weak var notificationPopupDownTextLabel: UILabel!
    @IBOutlet weak var notificationPopupLabel: UILabel!
    @IBOutlet weak var messageNotificationLabel: UILabel!
    @IBOutlet weak var whoCanSeeBirthdayLabel: UILabel!
    @IBOutlet weak var woCanMessegeMeLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var blockUsersLabel: UILabel!
    @IBOutlet weak var changePasswordLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var myAccountLabel: UILabel!
    @IBOutlet weak var aboutMeLable: UILabel!
    @IBOutlet weak var editProfileLabel: UILabel!
    @IBOutlet weak var birthPrivacyLabel: UILabel!
    @IBOutlet weak var messagePrivacyLabel: UILabel!
    @IBOutlet weak var followPrivacyLabel: UILabel!
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var myAccountView: UIView!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var deleteAccView: UIView!
    @IBOutlet weak var reportProblemVIew: UIView!
    @IBOutlet weak var helpVIew: UIView!
    @IBOutlet weak var conversationView: UIView!
    @IBOutlet weak var notificationsView: UIView!
    @IBOutlet weak var callLogView: UIView!
    @IBOutlet weak var languageView: UIView!
    @IBOutlet weak var birthdayView: UIView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var followView: UIView!
    @IBOutlet weak var blockUsersView: UIView!
    @IBOutlet weak var changePasswordView: UIView!
    @IBOutlet weak var aboutMeView: UIView!
    @IBOutlet weak var editProfileAndAvatarView: UIView!
    
    @IBOutlet weak var notficationSwitch: UISwitch!
    
    private var agreeStatus:Bool? = false
    private var toneStatus:Bool? = false
    private var notificationStatus:Bool? = false
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewWillLayoutSubviews() {
        
        let color = UIColor.hexStringToUIColor(hex: "B3B3B3")
        self.editProfileAndAvatarView.addBottomBorderWithColor(color:color , width: 1.0)
        self.aboutMeView.addBottomBorderWithColor(color:color , width: 1.0)
        self.blockUsersView.addBottomBorderWithColor(color:color , width: 5.0)
        self.changePasswordView.addBottomBorderWithColor(color:color , width: 1.0)
        self.followView.addBottomBorderWithColor(color:color , width: 1.0)
        self.messageView.addBottomBorderWithColor(color:color , width: 1.0)
        self.birthdayView.addBottomBorderWithColor(color:color , width: 5.0)
        self.languageView.addBottomBorderWithColor(color:color , width: 1.0)
        self.callLogView.addBottomBorderWithColor(color:color , width: 5.0)
        self.notificationsView.addBottomBorderWithColor(color:color , width: 1.0)
        self.conversationView.addBottomBorderWithColor(color:color , width: 5.0)
        self.helpVIew.addBottomBorderWithColor(color:color , width: 1.0)
        self.reportProblemVIew.addBottomBorderWithColor(color:color , width: 1.0)
        self.deleteAccView.addBottomBorderWithColor(color:color , width: 1.0)
        self.myAccountView.addBottomBorderWithColor(color:color , width: 1.0)
    }
    @IBAction func checkPressed(_ sender: Any) {
        self.agreeStatus = !self.agreeStatus!
        if self.agreeStatus!{
            self.checkBtn.setImage(UIImage(named: "ic_check_red"), for: .normal)
            UserDefaults.standard.setConversationTone(value: true, ForKey: Local.CONVERSATION_TONE.ConversationTone)
        }else{
            self.checkBtn.setImage(UIImage(named: "ic_uncheck_red"), for: .normal)
            UserDefaults.standard.setConversationTone(value: false, ForKey: Local.CONVERSATION_TONE.ConversationTone)
        }
    }
    func setupUI(){
        self.editProfileLabel.text = NSLocalizedString("Edit Profile and avatar", comment: "")
         self.aboutMeLable.text = NSLocalizedString("About me", comment: "")
        self.myAccountLabel.text = NSLocalizedString("My Account", comment: "")
         self.passwordLabel.text = NSLocalizedString("Password", comment: "")
        self.blockUsersLabel.text = NSLocalizedString("Blocked Users", comment: "")
        self.privacyLabel.text = NSLocalizedString("Privacy", comment: "")
        self.privacyLabel.text = NSLocalizedString("Privacy", comment: "")
        self.whoCanFollowMeLabel.text = NSLocalizedString("Who can follow me?", comment: "")
         self.woCanMessegeMeLabel.text = NSLocalizedString("Who can message me?", comment: "")
         self.whoCanSeeBirthdayLabel.text = NSLocalizedString("Who can see my birthday?", comment: "")
        self.messageNotificationLabel.text = NSLocalizedString("Message Notifications", comment: "")
        self.notificationPopupLabel.text = NSLocalizedString("Notification Popup", comment: "")
        self.notificationPopupDownTextLabel.text = NSLocalizedString("Get notifications when you receive messages", comment: "")
        self.conversationTonesLabel.text = NSLocalizedString("Conversation tones", comment: "")
        self.conversationTonesDownTextLabel.text = NSLocalizedString("Play sounds for incoming and outgoing messages", comment: "")
        self.generalLable.text = NSLocalizedString("General", comment: "")
        self.clearCallLogLabel.text = NSLocalizedString("Clear call log", comment: "")
        self.supportLabel.text = NSLocalizedString("Support", comment: "")
        self.helpLabel.text = NSLocalizedString("Help", comment: "")
        self.reportAProblemLabel.text = NSLocalizedString("Report a Problem", comment: "")
         self.deleteAccountLabel.text = NSLocalizedString("Delete Account", comment: "")
        self.logoutLabel.text = NSLocalizedString("Logout", comment: "")
        
        self.toneStatus = UserDefaults.standard.getConversationTone(Key: Local.CONVERSATION_TONE.ConversationTone)
        
        if toneStatus!{
            self.checkBtn.setImage(UIImage(named: "ic_check_red"), for: .normal)
        }else{
            self.checkBtn.setImage(UIImage(named: "ic_uncheck_red"), for: .normal)
        }
        let NotificationStatus = UserDefaults.standard.getNotification(Key:Local.NOTIFICATIONS.Notfication)
        if NotificationStatus{
            self.notficationSwitch.isOn = true
        }else{
            self.notficationSwitch.isOn = false
        }
        if AppInstance.instance.userProfile?.messagePrivacy == "0"{
            self.messagePrivacyLabel.text = "Everyone"
        }else{
            self.messagePrivacyLabel.text = "People I follow"
        }
        if AppInstance.instance.userProfile?.followPrivacy == "0"{
            self.followPrivacyLabel.text = "Everyone"
        }else{
            self.followPrivacyLabel.text = "People I follow"
        }
        if AppInstance.instance.userProfile?.birthPrivacy == "0"{
            self.birthPrivacyLabel.text = "Everyone"
        }else if  AppInstance.instance.userProfile?.birthPrivacy == "1"{
            self.birthPrivacyLabel.text = "People I follow"
        }else{
            self.birthPrivacyLabel.text = "Nobody"
        }
        self.title = "Settings"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        
        let editProfileTapGesture = UITapGestureRecognizer(target: self, action: #selector(profileAndAvatarTapped(sender:)))
        editProfileAndAvatarView.addGestureRecognizer(editProfileTapGesture)
        
        let aboutMeTapGesture = UITapGestureRecognizer(target: self, action: #selector(aboutMeTapped(sender:)))
        self.aboutMeView.addGestureRecognizer(aboutMeTapGesture)
        
        let blockUsersTapGesture = UITapGestureRecognizer(target: self, action: #selector(blockUsersTapped(sender:)))
        self.blockUsersView.addGestureRecognizer(blockUsersTapGesture)
        
        let logoutTapGesture = UITapGestureRecognizer(target: self, action: #selector(logoutTapped(sender:)))
        self.logoutView.addGestureRecognizer(logoutTapGesture)
        
        let deleteAccountTapGesture = UITapGestureRecognizer(target: self, action: #selector(deleteAccountTapped(sender:)))
        self.deleteAccView.addGestureRecognizer(deleteAccountTapGesture)
        let myAccountTapGesture = UITapGestureRecognizer(target: self, action: #selector(myAccountTapped(sender:)))
        self.myAccountView.addGestureRecognizer(myAccountTapGesture)
        let changePasswordTapGesture = UITapGestureRecognizer(target: self, action: #selector(changePasswordTapped(sender:)))
        self.changePasswordView.addGestureRecognizer(changePasswordTapGesture)
        let followTapGesture = UITapGestureRecognizer(target: self, action: #selector(followTapped(sender:)))
        self.followView.addGestureRecognizer(followTapGesture)
        let messageTapGesture = UITapGestureRecognizer(target: self, action: #selector(messageTapped(sender:)))
        self.messageView.addGestureRecognizer(messageTapGesture)
        let birthdayTapGesture = UITapGestureRecognizer(target: self, action: #selector(birthdayTapped(sender:)))
        self.birthdayView.addGestureRecognizer(birthdayTapGesture)
        let conversationTapGesture = UITapGestureRecognizer(target: self, action: #selector(conversationTapped(sender:)))
        self.conversationView.addGestureRecognizer(conversationTapGesture)
        let notificationTapGesture = UITapGestureRecognizer(target: self, action: #selector(notificationTapped(sender:)))
        self.notificationsView.addGestureRecognizer(notificationTapGesture)
        let callLogTapGesture = UITapGestureRecognizer(target: self, action: #selector(callLogTapped(sender:)))
        self.callLogView.addGestureRecognizer(callLogTapGesture)
        let languageTapGesture = UITapGestureRecognizer(target: self, action: #selector(languageTapped(sender:)))
        self.languageView.addGestureRecognizer(languageTapGesture)
        let helpTapGesture = UITapGestureRecognizer(target: self, action: #selector(helpTapped(sender:)))
        self.helpVIew.addGestureRecognizer(helpTapGesture)
        let reportProblemTapGesture = UITapGestureRecognizer(target: self, action: #selector(reportProblemTapped(sender:)))
        self.reportProblemVIew.addGestureRecognizer(reportProblemTapGesture)
        
        
    }
    @objc func reportProblemTapped(sender: UITapGestureRecognizer) {

        let url = URL(string: "")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)

            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                print("Open url : \(success)")
            })
        }
        
    }
    @objc func helpTapped(sender: UITapGestureRecognizer) {
        
        let url = URL(string: "")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            //If you want handle the completion block than
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                print("Open url : \(success)")
            })
        }
        
    }
    @objc func languageTapped(sender: UITapGestureRecognizer) {
        
        let vc = R.storyboard.settings.changeLanguageVC()
        self.present(vc!, animated: true, completion: nil)
        
    }
    @objc func callLogTapped(sender: UITapGestureRecognizer) {
        let callLogs = UserDefaults.standard.getCallsLogs(Key: Local.CALL_LOGS.CallLogs)
        if callLogs.isEmpty{
            self.view.makeToast("There are no call Logs to clear")
        }else{
            UserDefaults.standard.removeValuefromUserdefault(Key: Local.CALL_LOGS.CallLogs)
            self.view.makeToast("Call Logs Cleared")
        }
    }
    @objc func notificationTapped(sender: UITapGestureRecognizer) {
        
        self.notificationStatus = !self.notificationStatus!
        if self.notificationStatus!{
            self.notficationSwitch.isOn = true
            UserDefaults.standard.setNotification(value: true, ForKey: Local.NOTIFICATIONS.Notfication)
            self.view.makeToast("Notification Enabled")
        }else{
            
            self.notficationSwitch.isOn = false
            UserDefaults.standard.setNotification(value: false, ForKey: Local.NOTIFICATIONS.Notfication)
            self.view.makeToast("Notification Disabled")
        }
        
    }
    
    
    @IBAction func notificationPressed(_ sender: Any) {
        self.notificationStatus = !self.notificationStatus!
        if self.notificationStatus!{
            self.notficationSwitch.isOn = true
            UserDefaults.standard.setNotification(value: true, ForKey: Local.CONVERSATION_TONE.ConversationTone)
            self.view.makeToast("Notification Enabled")
        }else{
            
            self.notficationSwitch.isOn = false
            UserDefaults.standard.setNotification(value: false, ForKey: Local.CONVERSATION_TONE.ConversationTone)
            self.view.makeToast("Notification Disabled")
        }
    }
    @objc func conversationTapped(sender: UITapGestureRecognizer) {
        self.agreeStatus = !self.agreeStatus!
        if self.agreeStatus!{
            self.checkBtn.setImage(UIImage(named: "ic_check_red"), for: .normal)
            UserDefaults.standard.setConversationTone(value: true, ForKey: Local.CONVERSATION_TONE.ConversationTone)
        }else{
            self.checkBtn.setImage(UIImage(named: "ic_uncheck_red"), for: .normal)
            UserDefaults.standard.setConversationTone(value: false, ForKey: Local.CONVERSATION_TONE.ConversationTone)
        }
    }
    @objc func birthdayTapped(sender: UITapGestureRecognizer) {
        let vc = R.storyboard.settings.birthdayPopupVC()
        self.present(vc!, animated: true, completion: nil)
        
    }
    
    @objc func messageTapped(sender: UITapGestureRecognizer) {
        let vc = R.storyboard.settings.settingsSelectionPopupVC()
        vc?.status = false
        self.present(vc!, animated: true, completion: nil)
        
    }
    @objc func followTapped(sender: UITapGestureRecognizer) {
        let vc = R.storyboard.settings.settingsSelectionPopupVC()
        vc?.status = true
        self.present(vc!, animated: true, completion: nil)
        
    }
    
    @objc func profileAndAvatarTapped(sender: UITapGestureRecognizer) {
        let vc = R.storyboard.settings.editProfileVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @objc func aboutMeTapped(sender: UITapGestureRecognizer) {
        let vc = R.storyboard.settings.aboutMeVC()
        self.present(vc!, animated: true, completion: nil)
        
    }
    @objc func blockUsersTapped(sender: UITapGestureRecognizer) {
        let vc = R.storyboard.dashboard.blockedUsersVC()
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    @objc func logoutTapped(sender: UITapGestureRecognizer) {
        let vc = R.storyboard.settings.logoutVC()
        self.present(vc!, animated: true, completion: nil)
        
    }
    @objc func deleteAccountTapped(sender: UITapGestureRecognizer) {
        let vc = R.storyboard.settings.deleteAccountVC()
        self.present(vc!, animated: true, completion: nil)
        
    }
    @objc func myAccountTapped(sender: UITapGestureRecognizer) {
        let vc = R.storyboard.settings.myAccountVC()
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    @objc func changePasswordTapped(sender: UITapGestureRecognizer) {
        let vc = R.storyboard.settings.changePasswordVC()
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
}

