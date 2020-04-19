//
//  EditProfileVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 27/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SDWebImage
import Async
import WowonderMessengerSDK
class EditProfileVC: BaseVC {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var vkTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var youtubeTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var instagramTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var twitterTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var googleTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var facebookTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var workspaceTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var websiteTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var mobileTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var locationTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var genderTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var lastNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var firstNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    
     private let imagePickerController = UIImagePickerController()
    private var imageStatus:Bool? = false
    private var avatarImage:UIImage? = nil
    private var coverImageVar:UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.showUserData()
        

    }
    private func setupUI(){
        
        let profileImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped(tapGestureRecognizer:)))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(profileImageTapGestureRecognizer)
            
        let coverImageRapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(coverImageTapped(tapGestureRecognizer:)))
        coverImage.isUserInteractionEnabled = true
        coverImage.addGestureRecognizer(coverImageRapGestureRecognizer)
        
        self.profileImage.cornerRadiusV = self.profileImage.frame.height / 2
        self.title = "Edit Profile"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let Save = UIBarButtonItem(title: "Save", style: .done, target: self, action: Selector("Save"))
        self.navigationItem.rightBarButtonItem = Save
    }
    @objc func profileImageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let alert = UIAlertController(title: "", message: "Select Source", preferredStyle: .alert)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
             self.imageStatus = false
            self.imagePickerController.delegate = self
            
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.imageStatus = false
            self.imagePickerController.delegate = self
            
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
       
    }
    @objc func coverImageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        let alert = UIAlertController(title: "", message: "Select Source", preferredStyle: .alert)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
             self.imageStatus = true
            self.imagePickerController.delegate = self
            
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.imageStatus = true
            self.imagePickerController.delegate = self
            
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
       
    }
    private func updateUserProfile(){
        self.showProgressDialog(text: "Loading...")
        let sessionToken = AppInstance.instance.sessionId ?? ""
        let firstname = self.firstNameTextField.text ?? ""
        let lastname = self.lastNameTextField.text ?? ""
        let gender = self.genderTextField.text  ?? ""
        let location = self.locationTextField.text ?? ""
        let mobile = self.mobileTextField.text ?? ""
        let website = self.websiteTextField.text ?? ""
        let workspace = self.workspaceTextField.text ?? ""
        let facebook = self.facebookTextField.text ?? ""
        let google = self.googleTextField.text ?? ""
        let instagram = self.instagramTextField.text ?? ""
        let VK = self.vkTextField.text ?? ""
        let twitter = self.twitterTextField.text ?? ""
        let youtube = self.youtubeTextField.text ?? ""
        Async.background({
            if self.avatarImage == nil && self.coverImageVar == nil{
                SettingsManager.instance.updateUserProfile(session_Token:sessionToken , firstname: firstname, lastname: lastname, gender: gender, location: location, phone: mobile, website: website, school: workspace, facebook: facebook, google: google, twitter: twitter, youtube: youtube, VK: VK, instagram: instagram) { (success, sessionError, serverError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.message ?? "")")
                                self.view.makeToast(success?.message ?? "")
                                AppInstance.instance.fetchUserProfile()
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
                    
                }
                
            }else{
                
                if self.avatarImage != nil && self.coverImageVar == nil{
                   let avatarData = self.avatarImage?.jpegData(compressionQuality: 0.2)
                    SettingsManager.instance.updateUserDataWithCandA(session_Token:sessionToken , firstname: firstname, lastname: lastname, gender: gender, location: location, phone: mobile, website: website, school: workspace, facebook: facebook, google: google, twitter: twitter, youtube: youtube, VK: VK, instagram: instagram, type: "avatar", avatar_data: avatarData, cover_data: nil) { (success, sessionError, serverError, error) in
                        if success != nil{
                            Async.main({
                                self.dismissProgressDialog {
                                    log.debug("success = \(success?.message ?? "")")
                                    self.view.makeToast(success?.message ?? "")
                                    AppInstance.instance.fetchUserProfile()
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
                        
                    }
                    
                }else if self.avatarImage == nil && self.coverImageVar != nil{
                   let coverImageData = self.coverImageVar?.jpegData(compressionQuality: 0.2)
                    SettingsManager.instance.updateUserDataWithCandA(session_Token:sessionToken , firstname: firstname, lastname: lastname, gender: gender, location: location, phone: mobile, website: website, school: workspace, facebook: facebook, google: google, twitter: twitter, youtube: youtube, VK: VK, instagram: instagram, type: "cover", avatar_data: nil, cover_data: coverImageData) { (success, sessionError, serverError, error) in
                        if success != nil{
                            Async.main({
                                self.dismissProgressDialog {
                                    log.debug("success = \(success?.message ?? "")")
                                    self.view.makeToast(success?.message ?? "")
                                    AppInstance.instance.fetchUserProfile()
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
                        
                    }
                    
                }else{
                    let avatarData = self.avatarImage?.jpegData(compressionQuality: 0.2)
                    let coverData = self.coverImageVar?.jpegData(compressionQuality: 0.2)

                    SettingsManager.instance.updateUserDataWithCandA(session_Token:sessionToken , firstname: firstname, lastname: lastname, gender: gender, location: location, phone: mobile, website: website, school: workspace, facebook: facebook, google: google, twitter: twitter, youtube: youtube, VK: VK, instagram: instagram, type: "all", avatar_data: avatarData, cover_data: coverData) { (success, sessionError, serverError, error) in
                        if success != nil{
                            Async.main({
                                self.dismissProgressDialog {
                                    log.debug("success = \(success?.message ?? "")")
                                    self.view.makeToast(success?.message ?? "")
                                    AppInstance.instance.fetchUserProfile()
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
                        
                    }
                    
                }
                
            }
            
        })
    }
    private func showUserData(){
        self.fullNameLabel.text = AppInstance.instance.userProfile?.username ?? ""
        self.usernameLabel.text = "@\(AppInstance.instance.userProfile?.username ?? "")"
        self.firstNameTextField.text = AppInstance.instance.userProfile?.firstName ?? ""
        self.lastNameTextField.text = AppInstance.instance.userProfile?.lastName ?? ""
        self.genderTextField.text =  AppInstance.instance.userProfile?.gender ?? ""
        self.workspaceTextField.text = AppInstance.instance.userProfile?.school ?? ""
        self.websiteTextField.text = AppInstance.instance.userProfile?.website ?? ""
        self.mobileTextField.text = AppInstance.instance.userProfile?.phoneNumber ?? ""
        self.facebookTextField.text = AppInstance.instance.userProfile?.facebook ?? ""
        self.googleTextField.text = AppInstance.instance.userProfile?.google ?? ""
        self.twitterTextField.text = AppInstance.instance.userProfile?.twitter ?? ""
        self.vkTextField.text = AppInstance.instance.userProfile?.vk ?? ""
        self.twitterTextField.text = AppInstance.instance.userProfile?.twitter ?? ""
        self.youtubeTextField.text  = AppInstance.instance.userProfile?.youtube ?? ""
        self.locationTextField.text = AppInstance.instance.userProfile?.address ?? ""
        
        let profileImageURL = URL.init(string:AppInstance.instance.userProfile?.avatar ?? "")
        let coverImageURL = URL.init(string:AppInstance.instance.userProfile?.cover ?? "")
       profileImage.sd_setImage(with: profileImageURL ?? nil , placeholderImage:R.image.ic_profileimage())
        coverImage.sd_setImage(with: coverImageURL ?? nil , placeholderImage:R.image.ic_profileimage())
        
        
    }
    @objc func Save(){
        log.verbose("savePressed!!")
        self.updateUserProfile()
    }
    
}
extension  EditProfileVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        if imageStatus!{
            self.coverImage.image = image
            self.coverImageVar = image ?? nil
           
        }else{
            self.profileImage.image = image
            self.avatarImage  = image ?? nil
        }
        self.dismiss(animated: true, completion: nil)
}
}
