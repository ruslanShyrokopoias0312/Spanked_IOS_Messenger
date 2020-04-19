//
//  BaseVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 29/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Toast_Swift
import JGProgressHUD
import SwiftEventBus
import ContactsUI
import Async
import WowonderMessengerSDK
class BaseVC: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var hud : JGProgressHUD?
    
    private var noInternetVC: NoInternetDialogVC!
     var userId:String? = nil
     var sessionId:String? = nil
    var contactNameArray = [String]()
    var contactNumberArray = [String]()
    var deviceID:String? = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        self.dismissKeyboard()
        self.deviceID = UserDefaults.standard.getDeviceId(Key: Local.DEVICE_ID.DeviceId)
//        noInternetVC = R.storyboard.main.noInternetDialogVC()
//
//        //Internet connectivity event subscription
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_CONNECTED) { result in
//            self.CheckForUserCAll()
//            log.verbose("Internet connected!")
//            self.noInternetVC.dismiss(animated: true, completion: nil)
            
        }

        //Internet connectivity event subscription
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_DIS_CONNECTED) { result in
//            log.verbose("Internet dis connected!")
//                self.present(self.noInternetVC, animated: true, completion: nil)

        }
        
        
        
    
    }
//    deinit {
//        SwiftEventBus.unregister(self)
//    }
    override func viewWillAppear(_ animated: Bool) {
//        if !Connectivity.isConnectedToNetwork() {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
////                self.present(self.noInternetVC, animated: true, completion: nil)
//            })
//        }
    }
     func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        
        self.userId = localUserSessionData[Local.USER_SESSION.User_id] as! String
        self.sessionId = localUserSessionData[Local.USER_SESSION.Access_token] as! String
    }
    

    func showProgressDialog(text: String) {
        hud = JGProgressHUD(style: .dark)
        hud?.textLabel.text = text
        hud?.show(in: self.view)
    }
    
    func dismissProgressDialog(completionBlock: @escaping () ->()) {
          hud?.dismiss()
        completionBlock()
      
    }
    func fetchContacts(){
        
        let contactStore = CNContactStore()
        var contacts = [CNContact]()
        let keys = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey
            ] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request){
                (contact, stop) in
                // Array containing all unified contacts from everywhere
                contacts.append(contact)
                for phoneNumber in contact.phoneNumbers {
                    if let number = phoneNumber.value as? CNPhoneNumber, let label = phoneNumber.label {
                        let localizedLabel = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: label)
                        self.contactNameArray.append(contact.givenName)
                        self.contactNumberArray.append(number.stringValue)
                        print("\(contact.givenName) \(contact.familyName) tel:\(localizedLabel) -- \(number.stringValue), email: \(contact.emailAddresses)")
                    }
                }
            }
            print(contacts)
        } catch {
            print("unable to fetch contacts")
        }
        
    }
    private func CheckForUserCAll(){
        Async.background({
            GetUserListManager.instance.getUserList(user_id: AppInstance.instance.userId ?? "", session_Token: AppInstance.instance.sessionId ?? "") { (success,roomName,callId,senderName,senderProfileImage,callingType,acessToken2, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.agoraCall ?? false)")
                            let alert = UIAlertController(title: "Calling", message: "someone is calling you ", preferredStyle: .alert)
                            if success?.agoraCall == true{
                               
                                let answer = UIAlertAction(title: "Answer", style: .default, handler: { (action) in
                                    log.verbose("Answer Call")
                                   let vc = R.storyboard.call.videoCallVC()
                                    self.navigationController?.pushViewController(vc!, animated: true)
                                })
                                let decline = UIAlertAction(title: "Decline", style: .default, handler: { (action) in
                                    log.verbose("Call decline")
                                    log.verbose("Room name = \(roomName)")
                                    log.verbose("CallID = \(callId)")
                                })
                                alert.addAction(answer)
                                alert.addAction(decline)
                                self.present(alert, animated: true, completion: nil)
                            }else{
                                alert.dismiss(animated: true, completion: nil)
                                log.verbose("There is no call to answer..")
                            }
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors?.errorText)
                            log.error("sessionError = \(sessionError?.errors?.errorText)")
                            
                        }
                    })
                }else if serverError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(serverError?.errors?.errorText)
                            log.error("serverError = \(serverError?.errors?.errorText)")
                        }
                        
                    })
                    
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription)")
                        }
                    })
                }
            }
            
        })
        
    }

}
