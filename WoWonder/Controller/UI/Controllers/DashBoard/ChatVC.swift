//
//  ChatVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 24/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Async
import SDWebImage
import Alamofire
import SwiftEventBus
import WowonderMessengerSDK
import GoogleMobileAds
import GoogleMobileAds


class ChatVC: BaseVC {
    @IBOutlet weak var downTextLabel: UILabel!
    @IBOutlet weak var noMessagesLabel: UILabel!
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var noChatImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    private var userPbject: GetUserListModel.GetUserListSuccessModel?
    private  var refreshControl = UIRefreshControl()
    private var fetchSatus:Bool? = true
    private var timer = Timer()
    private var callId:Int? = 0
    private var callingStatus:String? = ""
    private var callType:String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_CONNECTED) { result in
            self.fetchData()
            
            
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_DIS_CONNECTED) { result in
            log.verbose("Internet dis connected!")
        }

       log.verbose("iosDeviceId = \(AppInstance.instance.userProfile?.iosMDeviceID ?? "")")
       if ControlSettings.shouldShowAddMobBanner{
                        
                        
                        interstitial = GADInterstitial(adUnitID:  ControlSettings.interestialAddUnitId)
                        let request = GADRequest()
                        interstitial.load(request)
                        
                    }
        
    }
    deinit {
        SwiftEventBus.unregister(self)  
    }
    func CreateAd() -> GADInterstitial {
           let interstitial = GADInterstitial(adUnitID:  ControlSettings.interestialAddUnitId)
           interstitial.load(GADRequest())
           return interstitial
       }
       func addBannerViewToView(_ bannerView: GADBannerView) {
           bannerView.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(bannerView)
           view.addConstraints(
               [NSLayoutConstraint(item: bannerView,
                                   attribute: .bottom,
                                   relatedBy: .equal,
                                   toItem: bottomLayoutGuide,
                                   attribute: .top,
                                   multiplier: 1,
                                   constant: 0),
                NSLayoutConstraint(item: bannerView,
                                   attribute: .centerX,
                                   relatedBy: .equal,
                                   toItem: view,
                                   attribute: .centerX,
                                   multiplier: 1,
                                   constant: 0)
               ])
       }
    
    
    @IBAction func followingPressed(_ sender: Any) {
        let vc = R.storyboard.dashboard.followingVC()
        self.navigationController?.pushViewController(vc!, animated: true)
        AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1

    }
    func setupUI(){
        self.noMessagesLabel.text = NSLocalizedString("No more Messages", comment: "")
        self.downTextLabel.text = NSLocalizedString("Start new conversations by going to contact", comment: "")
        self.noChatImage.isHidden = true
        self.showStack.isHidden = true
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        self.tableView.separatorStyle = .none
        tableView.register( R.nib.chatsTableCell(), forCellReuseIdentifier: R.reuseIdentifier.chats_TableCell.identifier)
    }
    @objc func refresh(sender:AnyObject) {
        fetchSatus = true
        self.userPbject?.users?.removeAll()
        self.tableView.reloadData()
        self.fetchData()
        
    }
    
    
    private func fetchData(){
        if fetchSatus!{
            fetchSatus = false
           self.showProgressDialog(text: "Loading...")
        }else{
            log.verbose("will not show Hud more...")
        }
        
        Async.background({
            GetUserListManager.instance.getUserList(user_id: AppInstance.instance.userId ?? "", session_Token: AppInstance.instance.sessionId ?? "") { (success,roomName,callId,senderName,senderProfileImage,callingType,accessToken2, sessionError, serverError, error)  in
                if success != nil{
                    Async.main({
                      
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.users ?? nil)")
                            if (success?.users?.isEmpty)!{
                                
                                self.noChatImage.isHidden = false
                                self.showStack.isHidden = false
                                 self.refreshControl.endRefreshing()
                            }else {
                                self.noChatImage.isHidden = true
                                self.showStack.isHidden = true
                                self.userPbject = success
                                self.tableView.reloadData()
                                log.verbose("Room name = \(roomName)")
                                log.verbose("CallID = \(callId)")
                                log.debug("userList = \(success?.agoraCall ?? false)")
                                self.callId = Int(callId ?? "")
                                let alert = UIAlertController(title: "Calling", message: "\(senderName ?? "") sends you an \(callingType) request..", preferredStyle: .alert)
                                if ControlSettings.agoraCall == true && ControlSettings.twilloCall == false{
                                    if success?.agoraCall == true{
                                        self.callingStatus = "agora"
                                        self.timer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
                                        
                                        let answer = UIAlertAction(title: "Answer", style: .default, handler: { (action) in
                                            log.verbose("Answer Call")
                                            
                                            
                                            self.agoraAnswerCall(callID: callId!, senderCalling: senderName ?? "", callingType: callingType ?? "", roomId: roomName ?? "", profileImage: senderProfileImage ?? "")
                                        })
                                        let decline = UIAlertAction(title: "Decline", style: .default, handler: { (action) in
                                            log.verbose("Call decline")
                                            log.verbose("Room name = \(roomName)")
                                            log.verbose("CallID = \(callId)")
                                            self.agoraDeclineCall(callID: callId!)
                                        })
                                        alert.addAction(answer)
                                        alert.addAction(decline)
                                        self.present(alert, animated: true, completion: nil)
                                    }else{
                                        alert.dismiss(animated: true, completion: nil)
                                        log.verbose("There is no call to answer..")
                                    }
                                }else{
                                    self.callingStatus = "twillo"
                                    if success?.videoCall == true{
                                        self.callType = "video"
                                        log.verbose("AccessToken2 = \(accessToken2 ?? "")")
                                        self.timer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
                                        
                                        let answer = UIAlertAction(title: "Answer", style: .default, handler: { (action) in
                                            log.verbose("Answer Call")
                                            self.TwilloVideoCallAnswer(callID: callId!, senderCalling: senderName ?? "", callingType:"video", roomId: roomName ?? "", profileImage: senderProfileImage ?? "", accessToken2: accessToken2!)
                                        })
                                        let decline = UIAlertAction(title: "Decline", style: .default, handler: { (action) in
                                            log.verbose("Call decline")
                                            log.verbose("Room name = \(roomName)")
                                            log.verbose("CallID = \(callId)")
                                            self.twilloDeclineVideoCall(callID: callId!)
                                        })
                                        alert.addAction(answer)
                                        alert.addAction(decline)
                                        self.present(alert, animated: true, completion: nil)
                                    }else if  success?.audioCall == true{
                                         self.callType = "audio"
                                        self.timer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
                                        
                                        let answer = UIAlertAction(title: "Answer", style: .default, handler: { (action) in
                                            log.verbose("Answer Call")
                                            
                                            self.twilloAudioCallAnswer(callID: callId!, senderCalling: senderName ?? "", callingType: "audio", roomId: roomName ?? "", profileImage: senderProfileImage ?? "")
                                        })
                                        let decline = UIAlertAction(title: "Decline", style: .default, handler: { (action) in
                                            log.verbose("Call decline")
                                            log.verbose("Room name = \(roomName)")
                                            log.verbose("CallID = \(callId)")
                                            self.twilloDeclineAudioCall(callID: callId!)
                                        })
                                        alert.addAction(answer)
                                        alert.addAction(decline)
                                        self.present(alert, animated: true, completion: nil)
                                        
                                    }else{
                                        alert.dismiss(animated: true, completion: nil)
                                        log.verbose("There is no call to answer..")
                                    }

                                    
                                }
                                
                                self.refreshControl.endRefreshing()
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
    private func agoraDeclineCall(callID:String){
         self.timer.invalidate()
        let userId = AppInstance.instance.userId ?? ""
        let sessionID = AppInstance.instance.sessionId ?? ""
        Async.background({
            CallManager.instance.agoraCallAction(user_id: userId, session_Token: sessionID, call_id: callID, answer_type: "decline", completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                          
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

            })
           
        })
    }
    private func twilloDeclineVideoCall(callID:String){
        self.timer.invalidate()
        let userId = AppInstance.instance.userId ?? ""
        let sessionID = AppInstance.instance.sessionId ?? ""
        Async.background({
            TwilloCallmanager.instance.twilloVideoCallAction(user_id: userId, session_Token: sessionID, call_id: callID, answer_type: "decline", completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
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
            })
            
            
        })
        
    }
    
    private func twilloDeclineAudioCall(callID:String){
        self.timer.invalidate()
        let userId = AppInstance.instance.userId ?? ""
        let sessionID = AppInstance.instance.sessionId ?? ""
        Async.background({
            TwilloCallmanager.instance.twilloAudioCallAction(user_id: userId, session_Token: sessionID, call_id: callID, answer_type: "decline", completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
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
            })
           
        })
        
    }
    private func agoraAnswerCall(callID:String,senderCalling:String,callingType:String,roomId:String,profileImage:String){
        let userId = AppInstance.instance.userId ?? ""
        let sessionID = AppInstance.instance.sessionId ?? ""
        Async.background({
            CallManager.instance.agoraCallAction(user_id: userId, session_Token: sessionID, call_id: callID, answer_type: "answer", completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.status ?? nil)")
                            if callingType == "video"{
                                let vc  = R.storyboard.call.videoCallVC()
                                vc?.callId = Int(callID)
                                vc?.roomID = roomId
                                self.navigationController?.pushViewController(vc!, animated: true)
                            }else{
                                let vc  = R.storyboard.call.agoraCallVC()
                                vc?.callId = Int(callID)
                                vc?.roomID = roomId
                                vc?.usernameString = senderCalling
                                vc?.profileImageUrlString = profileImage
                                self.navigationController?.pushViewController(vc!, animated: true)
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
                
            })
            
        })
        
    }
    private func twilloAudioCallAnswer(callID:String,senderCalling:String,callingType:String,roomId:String,profileImage:String){
        let userId = AppInstance.instance.userId ?? ""
        let sessionID = AppInstance.instance.sessionId ?? ""
        Async.background({
            TwilloCallmanager.instance.twilloAudioCallAction(user_id: userId, session_Token: sessionID, call_id: callID, answer_type: "answer", completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.status ?? nil)")
                            
                                let vc  = R.storyboard.call.agoraCallVC()
                                vc?.callId = Int(callID)
                                vc?.roomID = roomId
                            vc?.usernameString = senderCalling
                            vc?.profileImageUrlString = profileImage
                                self.navigationController?.pushViewController(vc!, animated: true)
                            
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
            })
         
        })
        
    }
    private func TwilloVideoCallAnswer(callID:String,senderCalling:String,callingType:String,roomId:String,profileImage:String,accessToken2:String){
        let userId = AppInstance.instance.userId ?? ""
        let sessionID = AppInstance.instance.sessionId ?? ""
        Async.background({
            TwilloCallmanager.instance.twilloVideoCallAction(user_id: userId, session_Token: sessionID, call_id: callID, answer_type: "answer", completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(callID)")
                            if callingType == "video"{
                                let storyboard = UIStoryboard(name: "Call", bundle: nil)
                                let vc  = R.storyboard.call.videoCallVC()
                                vc?.callId = self.callId
                                vc?.roomID = roomId
                                self.navigationController?.pushViewController(vc!, animated: true)
                            }else{
                                let vc  = R.storyboard.call.agoraCallVC()
                                vc?.callId = Int(callID)
                                vc?.roomID = roomId
                                vc?.usernameString = senderCalling
                                vc?.profileImageUrlString = profileImage
                                self.navigationController?.pushViewController(vc!, animated: true)
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
            })
          
            
        })
        
    }
    private func agoraCheckForAction(callID:Int){
        let userId = AppInstance.instance.userId ?? ""
        let sessionID = AppInstance.instance.sessionId ?? ""
        Async.background({
            CallManager.instance.checkForAgoraCall(user_id: userId, session_Token: sessionID, call_id: callID, call_Type: "", completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.callStatus ?? nil)")
                            
                            if success?.callStatus == "declined"{
                                self.dismiss(animated: true, completion: nil)
                                self.timer.invalidate()
                                log.verbose("Call Has Been Declined")
                            }else if success?.callStatus == "answered"{
                                log.verbose("Call Has Been Answered")
                                self.timer.invalidate()
                            }else if  success?.callStatus == "no_answer"{
                                self.dismiss(animated: true, completion: nil)
                                self.timer.invalidate()
                                log.verbose("No Answer")
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
            })
        })
        
    }
    private func twilloCheckForAction(callID:Int,callType:String){
        let userId = AppInstance.instance.userId ?? ""
        let sessionID = AppInstance.instance.sessionId ?? ""
        Async.background({
            TwilloCallmanager.instance.checkForTwilloCall(user_id: userId, session_Token: sessionID, call_id: callID, call_Type: callType, completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.callStatus ?? nil)")
                            
                            if success?.callStatus == 400{
                                self.dismiss(animated: true, completion: nil)
                                self.timer.invalidate()
                                log.verbose("Call Has Been Declined")
                            }else if success?.callStatus == 200{
                                log.verbose("Call Has Been Answered")
                                self.timer.invalidate()
                            }else if  success?.callStatus == 300{
                                log.verbose("Calling")
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
            })
        }) 
    }
    @objc func update() {
        if self.callingStatus == "agora"{
             self.agoraCheckForAction(callID: self.callId!)
        }else{
            self.twilloCheckForAction(callID: self.callId!, callType:  self.callType ?? "")
        }
    }
}
extension ChatVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userPbject?.users?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chats_TableCell.identifier) as? Chats_TableCell
        let object = self.userPbject?.users?[indexPath.row]
        cell?.usernameLabel.text = object?.name ?? ""
        cell?.messageLabel.text = object?.lastMessage?.text?.htmlAttributedString  ?? ""
        cell?.timeLabel.text = object?.lastseenTimeText ?? ""
        log.verbose("object?.profilePicture = \(object?.avatar)")
        let url = URL.init(string:object?.avatar ?? "")
        cell?.profileImage.sd_setImage(with: url , placeholderImage:R.image.ic_profileimage())
        cell?.profileImage.cornerRadiusV = (cell?.profileImage.frame.height)! / 2
        if object?.lastseen == "on"{
            cell?.showOnlineView.backgroundColor = UIColor.hexStringToUIColor(hex: "#39A43E")
        }else{
            cell?.showOnlineView.backgroundColor = UIColor.hexStringToUIColor(hex: "#ECECEC")
        }
        cell?.seenCheckImage.image = cell!.seenCheckImage.image?.withRenderingMode(.alwaysTemplate)
        let lightFont = UIFont(name: "Poppins-Regular", size: 17)
        if object?.lastMessage?.toID == AppInstance.instance.userId && object?.lastMessage?.fromID == AppInstance.instance.userId{
            if object?.lastMessage?.seen == "0" || object?.lastMessage?.seen == ""{
                cell?.usernameLabel.font = UIFont(name: "Poppins-Regular", size: 17)
                cell?.messageLabel.font = UIFont(name: "Poppins-Regular", size: 13)
                 cell?.seenCheckImage.isHidden = true
            }else{
                cell?.usernameLabel.font = UIFont(name: "Poppins-Regular", size: 17)
                cell?.messageLabel.font = UIFont(name: "Poppins-Regular", size: 13)
                cell?.seenCheckImage.isHidden = false
                 cell?.seenCheckImage.tintColor = .darkGray
                
            }
            
        }else{
            if object?.lastMessage?.seen == "0" || object?.lastMessage?.seen == ""{
                cell?.seenCheckImage.isHidden = false
                cell?.usernameLabel.font = UIFont(name: "Poppins-SemiBold", size: 17)
                cell?.messageLabel.font = UIFont(name: "Poppins-SemiBold", size: 13)
                cell?.seenCheckImage.tintColor = .darkGray
                
            }else{
                cell?.seenCheckImage.isHidden = false
                cell?.usernameLabel.font = UIFont(name: "Poppins-Regular", size: 17)
                cell?.messageLabel.font = UIFont(name: "Poppins-Regular", size: 13)
                cell?.seenCheckImage.tintColor = UIColor.hexStringToUIColor(hex: "#B46363")
                
            }
        }

//        if object?.lastMessage?.seen == "0"{
//            cell?.seenCheckImage.tintColor = .darkGray
//
//        }else{
//            cell?.seenCheckImage.tintColor = UIColor.hexStringToUIColor(hex: "#B46363")
//        }
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if AppInstance.instance.addCount == ControlSettings.interestialCount {
                   if interstitial.isReady {
                       interstitial.present(fromRootViewController: self)
                       interstitial = CreateAd()
                       AppInstance.instance.addCount = 0
                   } else {
                       
                       print("Ad wasn't ready")
                   }
               }
        AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1

       let vc = R.storyboard.chat.chatScreenVC()
        vc?.recipientID = self.userPbject?.users![indexPath.row].userID ?? ""
        vc!.userObject = self.userPbject?.users![indexPath.row]
        vc?.chatColorHex = self.userPbject?.users![indexPath.row].chatColor ?? ""
        self.navigationController?.pushViewController(vc!, animated: true)
    }
  
    
}

extension ChatVC:IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "CHATS")
    }
}
