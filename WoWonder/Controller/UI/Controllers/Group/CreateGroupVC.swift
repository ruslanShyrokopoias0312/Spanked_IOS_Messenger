//
//  CreateGroupVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 26/09/2019.
//  Copyright © 2019 ScriptSun. All rights reserved.
//

import UIKit
import Async
import WowonderMessengerSDK
protocol participantsCollectionDelegate {
    func selectParticipantsCollection(idsString:String,participantsArray:[AddParticipantModel])
}

class CreateGroupVC: BaseVC {
    
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var groupImage: UIImageView!
    
    private var selectedUsersArray = [AddParticipantModel]()
    private var idsString:String? = ""
    private var idsArray = [Int]()
    private let imagePickerController = UIImagePickerController()
    private var imageData:Data? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    @IBAction func addParticipantPressed(_ sender: Any) {
        
    }
    
    @IBAction func selectImagePressed(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "Select Source", preferredStyle: .alert)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePickerController.delegate = self
            
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (action) in
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
    private func setupUI(){
        
        collectionView.register( R.nib.addParticipantCollectionCell(), forCellWithReuseIdentifier: R.reuseIdentifier.addParticipant_CollectionCell.identifier)
        
        collectionView.register( R.nib.createGroupCollectionCell(), forCellWithReuseIdentifier: R.reuseIdentifier.createGroup_CollectionCell.identifier)
        
        self.title = "Create Group"
        let add = UIBarButtonItem(title: "Add", style: .done, target: self, action: Selector("Add"))
        self.navigationItem.rightBarButtonItem = add
        
    }
    
    @objc func Add(){
        if imageData == nil{
            let securityAlertVC = R.storyboard.main.securityPopupVC()
            securityAlertVC?.titleText  = "Security"
            securityAlertVC?.errorText = "Please select group avatar."
            self.present(securityAlertVC!, animated: true, completion: nil)
        }else if self.groupNameTextField.text!.isEmpty{
            let securityAlertVC = R.storyboard.main.securityPopupVC()
            securityAlertVC?.titleText  = "Security"
            securityAlertVC?.errorText = "Please enter group name."
            self.present(securityAlertVC!, animated: true, completion: nil)
        }else if self.idsString == ""{
            let securityAlertVC = R.storyboard.main.securityPopupVC()
            securityAlertVC?.titleText  = "Security"
            securityAlertVC?.errorText = "Please select Atleast one participant."
            self.present(securityAlertVC!, animated: true, completion: nil)
        }else{
            self.createGroup()
            
        }
    }
    private func createGroup(){
        self.showProgressDialog(text: "Loading...")
        let sessionToken = AppInstance.instance.sessionId ?? ""
        let groupName  = self.groupNameTextField.text ?? ""
        let imageData = self.imageData ?? Data()
        let parts = self.idsString ?? ""
        Async.background({
            GroupChatManager.instance.createGroup(session_Token: sessionToken, groupName: groupName, parts: parts, type: "create", avatar_data: imageData, completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("success = \(success?.apiStatus ?? 0)")
                            self.navigationController?.popViewController(animated: true)
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
            })
        
        })
        
        
    }
}
extension CreateGroupVC:UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else{
            return self.selectedUsersArray.count ?? 0

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.addParticipant_CollectionCell.identifier, for: indexPath) as? AddParticipant_CollectionCell
            return cell!
        }else{
            let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.createGroup_CollectionCell.identifier, for: indexPath) as? CreateGroup_CollectionCell
            cell?.delegate = self
            cell?.selectedParticipantArray = self.selectedUsersArray
            cell?.indexPath = indexPath.row
            let object = self.selectedUsersArray[indexPath.row]
            cell?.usernameLabel.text = object.username
            let url = URL.init(string:object.profileImage ?? "")
            cell?.profileImage.sd_setImage(with: url , placeholderImage:R.image.ic_profileimage())
            return cell!
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = R.storyboard.group.addParticipantsVC()
        vc!.delegate = self
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
extension  CreateGroupVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
       self.groupImage.image = image
        self.imageData = image.jpegData(compressionQuality: 0.1)
        self.dismiss(animated: true, completion: nil)
        
        
    }
}

extension CreateGroupVC:participantsCollectionDelegate{
    func selectParticipantsCollection(idsString: String, participantsArray: [AddParticipantModel]) {
        self.selectedUsersArray = participantsArray
        self.idsString = idsString
        log.verbose("Self.idString = \(self.idsString)")
        log.verbose(".idString = \(idsString)")
        
        log.verbose("self.selectedUsersArray = \(self.selectedUsersArray)")
        self.collectionView.reloadData()
       
    }
}
extension CreateGroupVC:deleteParticipantDelegate{
    func deleteParticipant(index: Int, status: Bool, selectedUseArray: [AddParticipantModel]) {
        self.idsString = ""
            
        self.selectedUsersArray.removeAll()
        self.selectedUsersArray = selectedUseArray
        selectedUsersArray.forEach { (it) in
            self.idsArray.append(it.id ?? 0)
        }
        var stringArray = self.idsArray.map { String($0) }
        self.idsString = stringArray.joined(separator: ",")
        log.verbose("genresString = \(idsString)")
        
        self.collectionView.reloadData()
    }  
}
