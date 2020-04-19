//
//  SelectRandomPopupVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 26/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import WowonderMessengerSDK

class SelectRandomPopupVC: BaseVC {

    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var searchObject:SearchModel.User?
    var delegate:SelectRandomDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()

    }
    
    
    
    @IBAction func followPressed(_ sender: Any) {
    self.followUnfollow()
        
    }
    @IBAction func chatPressed(_ sender: Any) {
       
        self.dismiss(animated: true) {
            self.delegate?.selectRandom(recipientID: self.searchObject?.userID ?? "", searchObject: self.searchObject!)
        }
    }
    
   
    private func setupUI(){
        let name = searchObject?.name ?? ""
        let usermame = searchObject?.username ?? ""
        self.nameLabel.text = name
        self.userNameLabel.text = usermame
        let url = URL.init(string:searchObject!.avatar ?? "")
        profileImage.sd_setImage(with: url , placeholderImage:R.image.ic_profileimage())
        self.profileImage.cornerRadiusV = self.profileImage.frame.height / 2
        let dismissView = UITapGestureRecognizer(target: self, action: #selector(dismissView(sender:)))
        self.view.addGestureRecognizer(dismissView)
        log.verbose("userId = \(searchObject?.userID ?? "")")
        if searchObject?.isFollowing == 0{
            self.followBtn.backgroundColor = UIColor.hexStringToUIColor(hex: "#444444")
            self.followBtn.setImage(R.image.ic_add(), for: .normal)
        }else{
            self.followBtn.backgroundColor = .white
            self.followBtn.setImage(R.image.ic_checkblack(), for: .normal)
            
        }
    }
    @objc func dismissView(sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
        
        
    }
    private func followUnfollow(){
        self.showProgressDialog(text: "Loading...")
        let userId = AppInstance.instance.userId ?? ""
        let sessionToken = AppInstance.instance.sessionId ?? ""
        Async.background({
            FollowingManager.instance.followUnfollow(user_id: userId, session_Token: sessionToken, completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.followStatus ?? "")")
                            self.view.makeToast(success?.followStatus ?? "")
                            if success?.followStatus  ?? "" == "followed"{
                                self.view.makeToast("You have followed the user successfully")
                                self.followBtn.backgroundColor = .white
                                self.followBtn.setImage(R.image.ic_checkblack(), for: .normal)
                                
                            }else{
                                self.followBtn.backgroundColor = UIColor.hexStringToUIColor(hex: "#444444")
                                self.followBtn.setImage(R.image.ic_add(), for: .normal)
                                self.view.makeToast("The user has been unfollowed")
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
}
