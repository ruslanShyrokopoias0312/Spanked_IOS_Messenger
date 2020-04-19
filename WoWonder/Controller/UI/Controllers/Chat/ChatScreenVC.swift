//
//  ChatScreenVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 07/05/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DropDown
import AVFoundation
import AVKit
import ActionSheetPicker_3_0
import WowonderMessengerSDK

class ChatScreenVC: BaseVC {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var statusBarView: UIView!
    @IBOutlet weak var showAudioCancelBtn: UIButton!
    @IBOutlet weak var showAudioPlayBtn: UIButton!
    @IBOutlet weak var showAudioView: UIView!
    @IBOutlet weak var microBtn: UIButton!
    @IBOutlet weak var lastSeenLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var messageTxtView: UITextView!
    @IBOutlet weak var textViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var moreBtn: UIButton!
    
    
    var userObject:GetUserListModel.User?
    var searchUserObject:SearchModel.User?
    var followingUserObject:FollowingModel.Following?
    var recipientID:String? = ""
    var audioPlayer = AVAudioPlayer()
    var chatColorHex:String? = ""
    private var messagesArray = [UserChatModel.Message]()
    private var stopArray = [UserChatModel.Message]()
    private var userChatCount:Int? = 0
    private var player = AVPlayer()
    private var playerItem:AVPlayerItem!
    private var playerController = AVPlayerViewController()
    private let moreDropdown = DropDown()
    private let imagePickerController = UIImagePickerController()
    private let MKColorPicker = ColorPickerViewController()
    private var sendMessageAudioPlayer: AVAudioPlayer?
    private var receiveMessageAudioPlayer: AVAudioPlayer?
    private var toneStatus: Bool? = false
    private var scrollStatus:Bool? = true
    private var messageCount:Int? = 0
    private var admin:String? = ""
    private let chatColors = [
        UIColor.hexStringToUIColor(hex: "#a84849"),
        UIColor.hexStringToUIColor(hex: "#a84849"),
        UIColor.hexStringToUIColor(hex: "#0ba05d"),
        UIColor.hexStringToUIColor(hex: "#609b41"),
        UIColor.hexStringToUIColor(hex: "#8ec96c"),
        UIColor.hexStringToUIColor(hex: "#51bcbc"),
        UIColor.hexStringToUIColor(hex: "#b582af"),
        UIColor.hexStringToUIColor(hex: "#01a5a5"),
        UIColor.hexStringToUIColor(hex: "#ed9e6a"),
        UIColor.hexStringToUIColor(hex: "#aa2294"),
        UIColor.hexStringToUIColor(hex: "##f33d4c"),
        UIColor.hexStringToUIColor(hex: "#a085e2"),
        UIColor.hexStringToUIColor(hex: "#ff72d2"),
        UIColor.hexStringToUIColor(hex: "#056bba"),
        UIColor.hexStringToUIColor(hex: "#f9c270"),
        UIColor.hexStringToUIColor(hex: "#fc9cde"),
        UIColor.hexStringToUIColor(hex: "#0e71ea"),
        UIColor.hexStringToUIColor(hex: "#008484"),
        UIColor.hexStringToUIColor(hex: "#c9605e"),
        UIColor.hexStringToUIColor(hex: "#5462a5"),
        UIColor.hexStringToUIColor(hex: "#2b87ce"),
        UIColor.hexStringToUIColor(hex: "#f2812b"),
        UIColor.hexStringToUIColor(hex: "#f9a722"),
        UIColor.hexStringToUIColor(hex: "#56c4c5"),
        UIColor.hexStringToUIColor(hex: "#70a0e0"),
        UIColor.hexStringToUIColor(hex: "#a1ce79")
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.customizeDropdown()
        self.fetchData()
        self.fetchUserProfile()
        
        MKColorPicker.allColors = chatColors
        MKColorPicker.selectedColor = { color in
            log.verbose("selected Color = \(color.toHexString())")
            UserDefaults.standard.setChatColorHex(value: color.toHexString(), ForKey: Local.CHAT_COLOR_HEX.ChatColorHex)
            self.topView.backgroundColor = color ?? UIColor.hexStringToUIColor(hex: "#a84849")
            self.statusBarView.backgroundColor = color ?? UIColor.hexStringToUIColor(hex: "#a84849")
            self.sendBtn.backgroundColor = color
            self.changeChatColor(colorHexString: color.toHexString())
            self.tableView.reloadData()
            
        }
        log.verbose("recipientID = \(recipientID)")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_CONNECTED) { result in
            self.fetchData()
            
        }
        SwiftEventBus.onMainThread(self, name: EventBusConstants.EventBusConstantsUtils.EVENT_INTERNET_DIS_CONNECTED) { result in
            log.verbose("Internet dis connected!")
        }
    }
    deinit {
        SwiftEventBus.unregister(self)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        SwiftEventBus.unregister(self)
    }
    
    
    @IBAction func callPressed(_ sender: Any) {
        let vc = R.storyboard.call.agoraCallNotificationPopupVC()
        vc?.callingType = "calling..."
        vc?.callingStatus = "audio"
        if userObject != nil{
            vc?.callUserObject = userObject
        }else if searchUserObject != nil{
             vc?.searchUserObject =  searchUserObject
        }else{
            vc?.followingUserObject =  followingUserObject
        }
       
        vc?.delegate = self
        self.present(vc!, animated: true, completion: nil)
        
    }
    
    @IBAction func videoCallPressed(_ sender: Any) {
        let vc = R.storyboard.call.agoraCallNotificationPopupVC()
        vc?.callingType = "calling Video..."
        vc?.callingStatus = "video"
        vc?.delegate = self
        if userObject != nil{
            vc?.callUserObject = userObject
        }else if searchUserObject != nil{
            vc?.searchUserObject =  searchUserObject
        }else{
            vc?.followingUserObject =  followingUserObject
        }
        self.present(vc!, animated: true, completion: nil)
        
    }
    
    @IBAction func pickColorPressed(_ sender: UIButton) {
        
        if let popoverController = MKColorPicker.popoverPresentationController{
            popoverController.delegate = MKColorPicker
            popoverController.permittedArrowDirections = .any
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        self.present(MKColorPicker, animated: true, completion: nil)
    }
    
    
    @IBAction func selectVideoPressed(_ sender: Any) {
        openVideoGallery()
    }
    
    @IBAction func contactPressed(_ sender: Any) {
        let vc = R.storyboard.dashboard.inviteFriendsVC()
        vc?.status = true
        vc?.delegate = self
        self.present(vc!, animated: true, completion: nil)
        
        
    }
    @IBAction func selectPhotoPressed(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "Upload", rows: ["camera", "gallery"], initialSelection: 0, doneBlock: { (picker, index, values) in
            
            
            if index == 0{
                self.imagePickerController.delegate = self
                self.imagePickerController.allowsEditing = true
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true, completion: nil)
            }else{
                self.imagePickerController.delegate = self
                self.imagePickerController.allowsEditing = true
                self.imagePickerController.sourceType = .photoLibrary
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
            
            return
            
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
    }
    
    @IBAction func microPressed(_ sender: Any) {
    }
    
    @IBAction func selectFilePressed(_ sender: Any) {
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item","public.data", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content", "public.text"], in: .import)
        
        
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    @IBAction func sendPressed(_ sender: UIButton) {
//        if self.messageTxtView.text == "Your Message here..."{
//            log.verbose("will not send message as it is PlaceHolder...")
//        }else{
//            
//            self.sendMessage()
//            
//        }
//        
        self.sendMessage()

        
    }
    
    @IBAction func morePressed(_ sender: Any) {
        self.moreDropdown.show()
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        SwiftEventBus.unregister(self)
        
        
    }
    func fetchUserProfile(){
        let status = AppInstance.instance.getUserSession()
        if status{
            let recipientID =  self.recipientID ?? ""
            let sessionId = AppInstance.instance.sessionId ?? ""
            Async.background({
                GetUserDataManager.instance.getUserData(user_id: recipientID , session_Token: sessionId ?? "", fetch_type: API.Params.User_data) { (success, sessionError, serverError, error) in
                    if success != nil{
                        Async.main({
                            log.debug("success = \(success?.userData)")
                            self.admin = success?.userData?.admin ?? ""
                            log.verbose("Admin = \(self.admin)")
                           
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
    private func fetchData(){
        self.messagesArray.removeAll()
        let userId = AppInstance.instance.userId ?? ""
        let sessionID = AppInstance.instance.sessionId ?? ""
        Async.background({
            ChatManager.instance.getUserChats(user_id: userId, session_Token: sessionID, receipent_id: self.recipientID ?? "", completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.messages?.count ?? nil)")
                            for item in stride(from: (success?.messages!.count)! - 1, to: -1, by: -1){
                                self.messagesArray.append((success?.messages![item])!)
                            }
                            
//                            self.messagesArray = success?.messages ?? []
//                            success?.messages?.forEach({ (it) in
//                                self.messagesArray.append(it)
//                            })
                            self.tableView.reloadData()
                            if self.scrollStatus!{
                                
                                if self.messagesArray.count == 0{
                                    log.verbose("Will not scroll more")
                                }else{
                                    
                                    self.scrollStatus = false
                                    self.messageCount = self.messagesArray.count ?? 0
                                    let indexPath = NSIndexPath(item: ((self.messagesArray.count) - 1), section: 0)
                                    self.tableView.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                                }
                                
                            }else{
                                if self.messagesArray.count > self.messageCount!{
                                    if self.toneStatus!{
                                        self.playReceiveMessageSound()
                                    }else{
                                        log.verbose("To play sound please enable conversation tone from settings..")
                                    }
                                    self.messageCount = self.messagesArray.count ?? 0
                                    let indexPath = NSIndexPath(item: ((self.messagesArray.count) - 1), section: 0)
                                    self.tableView.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                                }else{
                                    log.verbose("Will not scroll more")
                                }
                                log.verbose("Will not scroll more")
                                
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
    
    
    func playSendMessageSound() {
        guard let url = Bundle.main.url(forResource: "Popup_SendMesseges", withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            sendMessageAudioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            sendMessageAudioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let aPlayer = sendMessageAudioPlayer else { return }
            aPlayer.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    func playReceiveMessageSound() {
        guard let url = Bundle.main.url(forResource: "Popup_GetMesseges", withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            receiveMessageAudioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            receiveMessageAudioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let aPlayer = receiveMessageAudioPlayer else { return }
            aPlayer.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    private func sendMessage(){
        let messageHashId = Int(arc4random_uniform(UInt32(100000)))
        let messageText = messageTxtView.text ?? ""
        let recipientId = self.recipientID ?? ""
        let sessionID = AppInstance.instance.sessionId ?? ""
        
        Async.background({
            ChatManager.instance.sendMessage(message_hash_id: messageHashId, receipent_id: recipientId, text: messageText, session_Token: sessionID, completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            if self.messagesArray.count == 0{
                                log.verbose("Will not scroll more")
//                                self.textViewPlaceHolder()
                                self.view.resignFirstResponder()
                            }else{
                                if self.toneStatus!{
                                    self.playSendMessageSound()
                                }else{
                                    log.verbose("To play sound please enable conversation tone from settings..")
                                }
                                self.messageTxtView.text = ""
                                
//                                self.textViewPlaceHolder()
                                self.view.resignFirstResponder()
                                log.debug("userList = \(success?.messageData ?? [])")
                                let indexPath = NSIndexPath(item: ((self.messagesArray.count) - 1), section: 0)
                                self.tableView.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
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
    private func deleteChat(){
        self.showProgressDialog(text: "Loading...")
        let sessionID = AppInstance.instance.sessionId ?? ""
        Async.background({
            
            ChatManager.instance.deleteChat(user_id: self.recipientID ?? "", session_Token: sessionID, completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.message ?? "")")
                            
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
    private func blockUser(){
        if self.admin == "1"{
           let alert = UIAlertController(title: "", message: "You cannot block this user because it is administrator", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(okay)
            self.present(alert, animated: true, completion:nil)
        }else{
            self.showProgressDialog(text: "Loading...")
            let sessionToken = AppInstance.instance.sessionId ?? ""
            Async.background({
                BlockUsersManager.instanc.blockUnblockUser(session_Token: sessionToken, blockTo_userId: self.recipientID ?? "", block_Action: "block", completionBlock: { (success, sessionError, serverError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.blockStatus ?? "")")
                                self.view.makeToast("User has been unblocked!!")
                                self.navigationController?.popViewController(animated: true)
                                
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
    }
    
    private func changeChatColor(colorHexString:String){
        let sessionToken = AppInstance.instance.sessionId ?? ""
        Async.background({
            ColorManager.instanc.changeChatColor(session_Token: sessionToken, receipentId: self.recipientID ?? "", colorHexString: colorHexString, completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.color ?? "")")
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
    private func customizeDropdown(){
        moreDropdown.dataSource = ["View Profile","Block User" , "Clear Chat"]
        moreDropdown.backgroundColor = UIColor.hexStringToUIColor(hex: "454345")
        moreDropdown.textColor = UIColor.white
        moreDropdown.anchorView = self.moreBtn
        //        moreDropdown.bottomOffset = CGPoint(x: 312, y:-270)
        moreDropdown.width = 200
        moreDropdown.direction = .any
        moreDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0{
                let vc = R.storyboard.chat.viewProfileVC()
                vc?.profileId = self.recipientID ?? ""
                self.navigationController?.pushViewController(vc!, animated: true)
            }else if index == 1{
                self.blockUser()
            }else{
                self.deleteChat()
            }
            print("Index = \(index)")
        }
        
    }
    
    private func setupUI(){
        self.toneStatus = UserDefaults.standard.getConversationTone(Key: Local.CONVERSATION_TONE.ConversationTone)
        self.topView.backgroundColor = UIColor.hexStringToUIColor(hex: self.chatColorHex ?? "#a84849")
        self.statusBarView.backgroundColor = UIColor.hexStringToUIColor(hex: self.chatColorHex ?? "#a84849")
        self.sendBtn.backgroundColor = UIColor.hexStringToUIColor(hex: self.chatColorHex ?? "#a84849")
        self.microBtn.isHidden = true
        self.sendBtn.isHidden = false
        self.showAudioView.isHidden = true
        self.usernameLabel.text = userObject?.username ?? searchUserObject?.username ?? followingUserObject?.username ?? ""
        self.lastSeenLabel.text = "last seen \(self.userObject?.lastseenTimeText ?? searchUserObject?.lastseen ?? followingUserObject?.lastseen ?? "")"
        self.sendBtn.cornerRadiusV = self.sendBtn.frame.height / 2
        self.microBtn.cornerRadiusV = self.microBtn.frame.height / 2
        self.showAudioPlayBtn.cornerRadiusV = self.showAudioPlayBtn.frame.height / 2
        self.tableView.separatorStyle = .none
        tableView.register( R.nib.chatSenderTableCell(), forCellReuseIdentifier: R.reuseIdentifier.chatSender_TableCell.identifier)
        tableView.register( R.nib.chatReceiverTableCell(), forCellReuseIdentifier: R.reuseIdentifier.chatReceiver_TableCell.identifier)
        tableView.register( R.nib.chatSenderImageTableCell(), forCellReuseIdentifier: R.reuseIdentifier.chatSenderImage_TableCell.identifier)
        tableView.register( R.nib.chatReceiverImageTableCell(), forCellReuseIdentifier: R.reuseIdentifier.chatReceiverImage_TableCell.identifier)
        tableView.register( R.nib.chatSenderContactTableCell(), forCellReuseIdentifier: R.reuseIdentifier.chatSenderContact_TableCell.identifier)
        tableView.register( R.nib.chatReceiverContactTableCell(), forCellReuseIdentifier: R.reuseIdentifier.chatReceiverContact_TableCell.identifier)
        tableView.register( R.nib.chatSenderStickerTableCell(), forCellReuseIdentifier: R.reuseIdentifier.chatSenderSticker_TableCel.identifier)
        tableView.register( R.nib.chatReceiverStrickerTableCell(), forCellReuseIdentifier: R.reuseIdentifier.chatReceiverStricker_TableCell.identifier)
        
        tableView.register( R.nib.chatSenderAudioTableCell(), forCellReuseIdentifier: R.reuseIdentifier.chatSenderAudio_TableCell.identifier)
        
        tableView.register( R.nib.chatReceiverAudioTableCell(), forCellReuseIdentifier: R.reuseIdentifier.chatReceiverAudio_TableCell.identifier)
        
        tableView.register( R.nib.chatSenderDocumentTableCell(), forCellReuseIdentifier: R.reuseIdentifier.chatSenderDocument_TableCell.identifier)
        tableView.register( R.nib.chatReceiverDocumentTableCell(), forCellReuseIdentifier: R.reuseIdentifier.chatReceiverDocument_TableCell.identifier)
        self.adjustHeight()
//        self.textViewPlaceHolder()
        
    }
    private func adjustHeight(){
        let size = self.messageTxtView.sizeThatFits(CGSize(width: self.messageTxtView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        textViewHeightContraint.constant = size.height
        self.viewDidLayoutSubviews()
        self.messageTxtView.setContentOffset(CGPoint.zero, animated: false)
    }
    private func textViewPlaceHolder(){
        messageTxtView.delegate = self
        messageTxtView.text = "Your Message here..."
        messageTxtView.textColor = UIColor.lightGray
    }
    private func openVideoGallery(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum)!
        picker.mediaTypes = ["public.movie"]
        
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }
    
    
    
}

extension  ChatScreenVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if  let image:UIImage? = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            log.verbose("image = \(image ?? nil)")
            let imageData = image?.jpegData(compressionQuality: 0.1)
            log.verbose("MimeType = \(imageData?.mimeType)")
            sendSelectedData(imageData: imageData, videoData: nil, imageMimeType: imageData?.mimeType, VideoMimeType: nil, Type: "image", fileData: nil, fileExtension: nil, FileMimeType: nil)
            
        }
        
        if let fileURL:URL? = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            
            if let url = fileURL {
                let videoData = try? Data(contentsOf: url)

                log.verbose("MimeType = \(videoData?.mimeType)")
                print(videoData?.mimeType)
                sendSelectedData(imageData: nil, videoData: videoData, imageMimeType: nil, VideoMimeType: videoData?.mimeType, Type: "video", fileData: nil, fileExtension: nil, FileMimeType: nil)
                
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    private func sendSelectedData(imageData:Data?,videoData:Data?, imageMimeType:String?,VideoMimeType:String?,Type:String?,fileData:Data?,fileExtension:String?,FileMimeType:String?){
        let messageHashId = Int(arc4random_uniform(UInt32(100000)))
        let sessionId = AppInstance.instance.sessionId ?? ""
        let dataType = Type ?? ""
        
        if dataType == "image"{
            Async.background({
                ChatManager.instance.sendChatData(message_hash_id: messageHashId, receipent_id: self.recipientID ?? "", session_Token: sessionId, type: dataType, image_data: imageData, video_data: nil, imageMimeType: imageMimeType, videoMimeType: nil, text: "", file_data: nil, file_Extension: nil, fileMimeType: nil) { (success, sessionError, serverError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.messageData ?? [])")
                                let indexPath = NSIndexPath(item: ((self.messagesArray.count) - 1), section: 0)
                                self.tableView.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                                
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
        }else if dataType == "video"{
            
            Async.background({
                ChatManager.instance.sendChatData(message_hash_id: messageHashId, receipent_id: self.recipientID ?? "", session_Token: sessionId, type: dataType, image_data: nil, video_data: videoData, imageMimeType: nil, videoMimeType: VideoMimeType, text: "", file_data: nil, file_Extension: nil, fileMimeType: nil) { (success, sessionError, serverError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.messageData ?? [])")
                                let indexPath = NSIndexPath(item: ((self.messagesArray.count) - 1), section: 0)
                                self.tableView.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                                
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
            
        }else{
            Async.background({
                ChatManager.instance.sendChatData(message_hash_id: messageHashId, receipent_id: self.recipientID ?? "", session_Token: sessionId, type: dataType, image_data: nil, video_data: nil, imageMimeType: nil, videoMimeType: nil, text: "", file_data: fileData, file_Extension: fileExtension, fileMimeType: FileMimeType) { (success, sessionError, serverError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("userList = \(success?.messageData ?? [])")
                                let indexPath = NSIndexPath(item: ((self.messagesArray.count) - 1), section: 0)
                                self.tableView.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                                
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
}
extension ChatScreenVC:SelectContactDetailDelegate {
    func selectContact(key:String,value:String) {
        var extendedParam = ["key":key,"value":value] as? [String:String]
        
        if let theJSONData = try?  JSONSerialization.data(withJSONObject:extendedParam,options: []){
            let theJSONText = String(data: theJSONData,encoding: String.Encoding.utf8)
            log.verbose("JSON string = \(theJSONText)")
            self.sendContact(jsonPayload: theJSONText)
        }
    }
    
    
    
    
    private func sendContact(jsonPayload:String?){
        let messageHashId = Int(arc4random_uniform(UInt32(100000)))
        let jsonPayloadString = jsonPayload ??  ""
        let recipientId = self.recipientID ?? ""
        let sessionID = AppInstance.instance.sessionId ?? ""
        Async.background({
            ChatManager.instance.sendContact(message_hash_id: messageHashId, receipent_id: recipientId, jsonPayload: jsonPayload ?? "",session_Token: sessionID, completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.messageData ?? [])")
                            let indexPath = NSIndexPath(item: ((self.messagesArray.count) - 1), section: 0)
                            self.tableView.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                            
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
    
}

extension ChatScreenVC: UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL?) {
        let cico = url as? URL
        print(cico)
        print(url)
        print(url!.lastPathComponent.split(separator: ".").last)
        print(url!.pathExtension)
        if let urlfile = url {
            let fileData = try? Data(contentsOf: urlfile)
            log.verbose("File Data = \(fileData)")
            log.verbose("MimeType = \(fileData?.mimeType)")
            
            let fileExtension = String(url!.lastPathComponent.split(separator: ".").last!)
            sendSelectedData(imageData: nil, videoData: nil, imageMimeType: nil, VideoMimeType: nil, Type: "file", fileData: fileData, fileExtension: fileExtension, FileMimeType: fileData?.mimeType)
        }
        
        
    }
}
extension ChatScreenVC:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.adjustHeight()
        
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            self.messageTxtView.text = ""
            textView.textColor = UIColor.black
            
            
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Your message here..."
            textView.textColor = UIColor.lightGray
            
            
        }
    }
}

extension ChatScreenVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messagesArray.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.messagesArray.count == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatSender_TableCell.identifier) as? ChatSender_TableCell
            return cell ?? UITableViewCell()
        }
        let object = self.messagesArray[indexPath.row]
        
        if object.media == ""{
            if object.type == "right_text"{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatSender_TableCell.identifier) as? ChatSender_TableCell
                cell?.selectionStyle = .none
                cell?.messageTxtView.text = (object.text?.htmlAttributedString!)! + "\n\n\(object.timeText?.htmlAttributedString ?? "")" ?? ""
                cell?.messageTxtView.isEditable = false
                cell?.messageTxtView.backgroundColor = UIColor.hexStringToUIColor(hex: self.chatColorHex ?? "#a84849")
                
                return cell!
                
                
            }else if object.type == "left_text"{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatReceiver_TableCell.identifier) as? ChatReceiver_TableCell
                
                cell?.messageTxtView.text = (object.text?.htmlAttributedString!)! + "\n\n\(object.timeText?.htmlAttributedString ?? "")" ?? ""
                cell?.messageTxtView.isEditable = false
                
                return cell!
            }else if object.type == "right_contact"{
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatSenderContact_TableCell.identifier) as? ChatSenderContact_TableCell
                let data = object.text?.htmlAttributedString!.data(using: String.Encoding.utf8)
                let result = try! JSONDecoder().decode(ContactModel.self, from: data!)
                log.verbose("Result Model = \(result)")
                let dic = convertToDictionary(text: (object.text?.htmlAttributedString!)!)
                log.verbose("dictionary = \(dic)")
                cell?.nameLabel.text = "\(dic!["key"] ?? "")"
                cell?.contactLabel.text  =  "\(dic!["value"] ?? "")"
                cell?.timeLabel.text = object.timeText ?? ""
                cell?.profileImage.cornerRadiusV = (cell?.profileImage.frame.height)! / 2
                cell?.backView.backgroundColor = UIColor.hexStringToUIColor(hex: self.chatColorHex ?? "#a84849")
                log.verbose("object.text?.htmlAttributedString? = \(object.text?.htmlAttributedString)")
                let newString = object.text?.htmlAttributedString!.replacingOccurrences(of: "\\\\", with: "")
                log.verbose("newString= \(newString)")
                
                return cell!
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatReceiverContact_TableCell.identifier) as? ChatReceiverContact_TableCell
                log.verbose("object.text?.htmlAttributedString? = \(object.text?.htmlAttributedString)")
                let newString = object.text?.htmlAttributedString!.replacingOccurrences(of: "\\\\", with: "")
                log.verbose("newString= \(newString)")
                let data = object.text?.htmlAttributedString?.data(using: String.Encoding.utf8)
                let result = try! JSONDecoder().decode(ContactModel.self, from: data!)
                let dic = convertToDictionary(text: (object.text?.htmlAttributedString!)!)
                log.verbose("dictionary = \(dic)")
                cell?.nameLabel.text = "\(dic!["key"] ?? "")"
                cell?.contactLabel.text  =  "\(dic!["value"] ?? "")"
               
                cell?.timeLabel.text = object.timeText ?? ""
                cell?.profileImage.cornerRadiusV = (cell?.profileImage.frame.height)! / 2
                
                return cell!
            }
            
            
        }else{
            if object.type == "right_image"{
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatSenderImage_TableCell.identifier) as? ChatSenderImage_TableCell
                cell?.fileImage.isHidden = false
                cell?.videoView.isHidden = true
                cell?.playBtn.isHidden = true
                let url = URL.init(string:object.media ?? "")
                cell?.fileImage.sd_setImage(with: url , placeholderImage:R.image.ic_profileimage())
                cell?.timeLabel.text = object.timeText ?? ""
                cell?.backView.backgroundColor = UIColor.hexStringToUIColor(hex: self.chatColorHex ?? "#a84849")
                
                return cell!
                
                
            }else if object.type == "left_image" {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatReceiverImage_TableCell.identifier) as? ChatReceiverImage_TableCell
                cell?.fileImage.isHidden = false
                cell?.videoView.isHidden = true
                cell?.playBtn.isHidden = true
                let url = URL.init(string:object.media ?? "")
                cell?.fileImage.sd_setImage(with: url , placeholderImage:R.image.ic_profileimage())
                cell?.timeLabel.text = object.timeText ?? ""
                
                return cell!
            }else  if object.type == "right_video"{
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatSenderImage_TableCell.identifier) as? ChatSenderImage_TableCell
                cell?.fileImage.isHidden = true
                cell?.videoView.isHidden = false
                cell?.playBtn.isHidden = false
                cell?.delegate = self
                cell?.index  = indexPath.row
                cell?.timeLabel.text = object.timeText ?? ""
                cell?.backView.backgroundColor = UIColor.hexStringToUIColor(hex: self.chatColorHex ?? "#a84849")
                let videoURL = URL(string: object.media ?? "")
                player = AVPlayer(url: videoURL! as URL)
                let playerController = AVPlayerViewController()
                playerController.player = player
                self.addChild(playerController)
                playerController.view.frame = self.view.frame
                cell?.videoView.addSubview(playerController.view)
                player.pause()
                return cell!
                
            }else if object.type == "left_video"{
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatReceiverImage_TableCell.identifier) as? ChatReceiverImage_TableCell
                cell?.fileImage.isHidden = true
                cell?.videoView.isHidden = false
                cell?.playBtn.isHidden = false
                cell?.delegate = self
                cell?.index  = indexPath.row
                let videoURL = URL(string: object.media ?? "")
                player = AVPlayer(url: videoURL! as URL)
                let playerController = AVPlayerViewController()
                playerController.player = player
                self.addChild(playerController)
                playerController.view.frame = self.view.frame
                cell?.videoView.addSubview(playerController.view)
                player.pause()
                cell?.timeLabel.text = object.timeText ?? ""
                return cell!
                
            }else if object.type == "right_sticker"{
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatSenderSticker_TableCel.identifier) as? ChatSenderSticker_TableCell
                let url = URL.init(string:object.media ?? "")
                cell?.stickerImage.sd_setImage(with: url , placeholderImage:nil)
                cell?.timeLabel.text = object.timeText ?? ""
                cell?.backView.backgroundColor = UIColor.hexStringToUIColor(hex: self.chatColorHex ?? "#a84849")
                return cell!
                
                
            }else if object.type == "left_sticker"{
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatReceiverStricker_TableCell.identifier) as? ChatReceiverStricker_TableCell
                let url = URL.init(string:object.media ?? "")
                cell?.stickerImage.sd_setImage(with: url , placeholderImage:nil)
                cell?.timeLabel.text = object.timeText ?? ""
                
                return cell!
            }else if  object.type == "right_audio"{
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatSenderAudio_TableCell.identifier) as? ChatSenderAudio_TableCell
                cell?.delegate = self
                cell?.index = indexPath.row
                cell?.url = object.media ?? ""
                cell?.backView.backgroundColor = UIColor.hexStringToUIColor(hex: self.chatColorHex ?? "#a84849")
                cell?.timeLabel.text = object.timeText ?? ""
                
                return cell!
            }else if object.type == "left_audio"{
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatReceiverAudio_TableCell.identifier) as? ChatReceiverAudio_TableCell
                cell?.delegate = self
                cell?.index = indexPath.row
                cell?.url = object.media ?? ""
                
                return cell!
                
            }else if object.type == "right_file"{
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatSenderDocument_TableCell.identifier) as? ChatSenderDocument_TableCell
                cell?.fileNameLabel.text = object.mediaFileName ?? ""
                cell?.timeLabel.text = object.timeText ?? ""
                cell?.backView.backgroundColor = UIColor.hexStringToUIColor(hex: self.chatColorHex ?? "#a84849")
                return cell!
                
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatReceiverDocument_TableCell.identifier) as? ChatReceiverDocument_TableCell
                cell?.nameLabel.text = object.mediaFileName ?? ""
                cell?.timeLabel.text = object.timeText ?? ""
                return cell!
            }
            
        }
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let vc = R.storyboard.chat.showChatIntentsVC()
        let object = self.messagesArray[indexPath.row]
        if object.type == "right_image"{
            vc?.imageUrl = object.media ?? ""
        }else if object.type == "left_image"{
            vc?.imageUrl = object.media ?? ""
        }else if object.type == "right_video"{
            vc?.videoUrl = object.media ?? ""
        }else if object.type == "left_video"{
               vc?.videoUrl = object.media ?? ""
        }
       
        self.present(vc!, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

}

extension ChatScreenVC:PlayVideoDelegate{
    func playVideo(index: Int, status: Bool) {
        if status{
//            self.player.play()
            log.verbose(" self.player.play()")
        }else{
              log.verbose("self.player.pause()")
//            self.player.pause()
        }
    }
    
    
}
extension ChatScreenVC:PlayAudioDelegate{
    func playAudio(index: Int, status: Bool, url: URL, button: UIButton) {
        if status{
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!//since it sys
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
            log.verbose("destinationUrl is = \(destinationUrl)")
            
            self.playerItem = AVPlayerItem(url: destinationUrl)
            self.player=AVPlayer(playerItem: self.playerItem)
            let playerLayer=AVPlayerLayer(player: self.player)
            self.player.play()
            
            
            self.player.play()
            button.setImage(R.image.ic_pauseBtn(), for: .normal)
        }else{
            self.player.pause()
            button.setImage(R.image.ic_playBtn(), for: .normal)
        }
        
        
    }
}


extension ChatScreenVC:CallReceiveDelegate{
    func receiveCall(callId: Int, RoomId: String, callingType: String, username: String, profileImage: String,accessToken:String?) {
    if callingType == "video"{
//        let storyboard = UIStoryboard(name: "Call", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "TwilloVideoCallVC") as? TwilloVideoCallVC
//        vc?.accessToken = accessToken!
//        vc?.roomId = RoomId
//        self.navigationController?.pushViewController(vc!, animated: true)
        let vc  = R.storyboard.call.videoCallVC()
        vc?.callId = callId
        vc?.roomID = RoomId
        self.navigationController?.pushViewController(vc!, animated: true)
    }else{
        let vc  = R.storyboard.call.agoraCallVC()
        vc?.callId = callId
        vc?.roomID = RoomId
        vc?.usernameString = username
        vc?.profileImageUrlString = profileImage
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    }
}
