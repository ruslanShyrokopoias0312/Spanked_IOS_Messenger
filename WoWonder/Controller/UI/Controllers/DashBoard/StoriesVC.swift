//
//  StoriesVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 24/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Floaty
import Async
import WowonderMessengerSDK
import GoogleMobileAds


class StoriesVC: BaseVC {
    
    @IBOutlet weak var downTextLable: UILabel!
    @IBOutlet weak var noStoriesLabel: UILabel!
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var cameraImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private var floaty = Floaty()
    private var storiesArray = [GetStoriesModel.Story]()
    private  var refreshControl = UIRefreshControl()
    private let imagePickerController = UIImagePickerController()
    var delegate:ImagePickerDelegate?
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.fetchData()
    }
    func setupUI(){
        self.noStoriesLabel.text = NSLocalizedString("There are no stories", comment: "")
        self.downTextLable.text = NSLocalizedString("Photos and videos shared in stories are only visible for 24 hours after they have been added.", comment: "")
        self.cameraImage.isHidden = true
        self.showStack.isHidden = true
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        self.tableView.separatorStyle = .none
        tableView.register( R.nib.storiesTableCell(), forCellReuseIdentifier: R.reuseIdentifier.stories_TableCell.identifier)
        
        floaty.buttonColor = UIColor.hexStringToUIColor(hex: "B46363")
        floaty.itemImageColor = .white
        
        let videoItem = FloatyItem()
        videoItem.hasShadow = true
        videoItem.buttonColor = UIColor.hexStringToUIColor(hex: "B46363")
        videoItem.circleShadowColor = UIColor.black
        videoItem.titleShadowColor = UIColor.black
        videoItem.titleLabelPosition = .left
        videoItem.title = "Video"
        videoItem.iconImageView.image = R.image.ic_video()
        videoItem.handler = { item in
            let alert = UIAlertController(title: "", message: "Select Source", preferredStyle: .actionSheet)
            let gallery = UIAlertAction(title: "Gallery", style: .default) { (action) in
                self.openVideoGallery()
            }
            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            
            alert.addAction(gallery)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            
            
        }
        let cameraItem = FloatyItem()
        cameraItem.hasShadow = true
        cameraItem.buttonColor = UIColor.hexStringToUIColor(hex: "B46363")
        cameraItem.circleShadowColor = UIColor.black
        cameraItem.titleShadowColor = UIColor.black
        cameraItem.titleLabelPosition = .left
        cameraItem.title = "camera"
        cameraItem.iconImageView.image = R.image.ic_camera()
        cameraItem.handler = { item in
            
            let alert = UIAlertController(title: "", message: "Select Source", preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
                self.delegate = self
                self.imagePickerController.delegate = self
                self.imagePickerController.allowsEditing = true
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
            let gallery = UIAlertAction(title: "Gallery", style: .default) { (action) in
                self.delegate = self
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
        
        floaty.addItem(item: videoItem)
        floaty.addItem(item: cameraItem)
        self.view.addSubview(floaty)
        
        if ControlSettings.shouldShowAddMobBanner{
            
            interstitial = GADInterstitial(adUnitID:  ControlSettings.interestialAddUnitId)
            let request = GADRequest()
            interstitial.load(request)
        }
        
        
    }
    func CreateAd() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID:  ControlSettings.interestialAddUnitId)
        interstitial.load(GADRequest())
        return interstitial
    }
    @objc func refresh(sender:AnyObject) {
        self.storiesArray.removeAll()
        self.tableView.reloadData()
        self.fetchData()
        
    }
    private func fetchData(){
        
        Async.background({
            StoriesManager.instance.getStories(session_Token: AppInstance.instance.sessionId ?? "", limit: 0, completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.stories ?? nil)")
                            if (success?.stories?.isEmpty)!{
                                
                                self.cameraImage.isHidden = false
                                self.showStack.isHidden = false
                                self.refreshControl.endRefreshing()
                            }else {
                                self.cameraImage.isHidden = true
                                self.showStack.isHidden = true
                                self.storiesArray = (success?.stories) ?? []
                                
                                self.tableView.reloadData()
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
                
            })
            
            
        })
        
    }
    
    func openVideoGallery()
    {
        let picker = UIImagePickerController()
        self.delegate = self
        picker.delegate = self
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum)!
        picker.mediaTypes = ["public.movie"]
        
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }
    
}
extension StoriesVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.storiesArray.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.stories_TableCell.identifier) as? Stories_TableCell
        let object = storiesArray[indexPath.row]
        cell?.usernameLabel.text = object.userData?.username ?? ""
        cell?.storyTextLabel.text = object.description ?? ""
        let url = URL.init(string:object.userData?.avatar ?? "")
        cell?.profileImage.sd_setImage(with: url , placeholderImage:R.image.ic_profileimage())
        cell?.profileImage.cornerRadiusV = (cell?.profileImage.frame.height)! / 2
        cell?.selectionStyle = .none
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            if AppInstance.instance.addCount == ControlSettings.interestialCount {
                if self.interstitial.isReady {
                    self.interstitial.present(fromRootViewController: self)
                    self.interstitial = self.CreateAd()
                    AppInstance.instance.addCount = 0
                } else {
                    print("Ad wasn't ready")
                }
            }
            AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1
            
            let vc = R.storyboard.story.contentVC()
            vc!.modalPresentationStyle = .overFullScreen
            vc!.pages = self.storiesArray
            vc!.currentIndex = indexPath.row
            self.present(vc!, animated: true, completion: nil)
        }
    }
    
}
extension StoriesVC:IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "STORIES")
    }
    
}
extension  StoriesVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if  let image:UIImage? = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            log.verbose("image = \(image ?? nil)")
            let imageData = image?.jpegData(compressionQuality: 0.1)
            self.delegate?.pickImage(image: image, videoData: nil, videoURL: nil, Status: true)
        }
        
        if let fileURL:URL? = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            
            if let url = fileURL {
                let videoData = try? Data(contentsOf: url)
                print(videoData)
                self.delegate?.pickImage(image: nil, videoData: videoData, videoURL: url, Status: false)
            }
            self.dismiss(animated: true, completion: nil)
            
            
        }
    }
}
extension StoriesVC:ImagePickerDelegate{
    
    
    func pickImage(image: UIImage?, videoData: Data?, videoURL: URL?,Status: Bool?) {
        if Status!{
            log.verbose("ImagePickerDelegate image = \(image)")
            let vc = R.storyboard.story.createStoryVC()
            vc?.status = Status ?? false
            vc!.pickedImage = image ?? nil
            self.navigationController?.pushViewController(vc!, animated: true)
        }else{
            log.verbose("ImagePickerDelegate video = \(videoData)")
            let vc = R.storyboard.story.createStoryVC()
            vc?.status = Status ?? false
            vc?.videoUrl = videoURL
            vc?.videoData = videoData
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    
}
