//
//  ShowStoryVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 07/05/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import CoreMedia
import Async
import WowonderMessengerSDK
class ShowStoryVC: BaseVC,SegmentedProgressBarDelegate {
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!

     var pageIndex : Int = 0
    var item: [GetStoriesModel.Story] = []
    var items: [GetStoriesModel.Story] = []
    var SPB: SegmentedProgressBar!
    var player: AVPlayer!
    var refreshStories: (() -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.height / 2;
        
        let url = URL.init(string:items[pageIndex].userData?.avatar ?? "")
        userProfileImage.sd_setImage(with: url , placeholderImage:R.image.ic_profileimage())
      
        lblUserName.text = items[pageIndex].userData?.username ?? ""
        item = [items[pageIndex]]
        
        SPB = SegmentedProgressBar(numberOfSegments: item.count, duration: 5)
        if #available(iOS 11.0, *) {
            SPB.frame = CGRect(x: 18, y: UIApplication.shared.statusBarFrame.height + 5, width: view.frame.width - 35, height: 3)
        } else {
            // Fallback on earlier versions
            SPB.frame = CGRect(x: 18, y: 15, width: view.frame.width - 35, height: 3)
        }
        
        SPB.delegate = self
        SPB.topColor = UIColor.white
        SPB.bottomColor = UIColor.white.withAlphaComponent(0.25)
        SPB.padding = 2
        SPB.isPaused = true
        SPB.currentAnimationIndex = 0
        SPB.duration = getDuration(at: 0)
        view.addSubview(SPB)
        view.bringSubviewToFront(SPB)
        
        let tapGestureImage = UITapGestureRecognizer(target: self, action: #selector(tapOn(_:)))
        tapGestureImage.numberOfTapsRequired = 1
        tapGestureImage.numberOfTouchesRequired = 1
        imagePreview.addGestureRecognizer(tapGestureImage)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log.verbose("items[pageIndex].userData?.userID = \(items[pageIndex].userData?.userID)")
          log.verbose("self.userId  = \(AppInstance.instance.userId)")
        
        if  items[pageIndex].userData?.userID  == AppInstance.instance.userId {
            self.deleteBtn.isHidden = false
        }else if items[pageIndex].userData?.admin == "1"{
            self.deleteBtn.isHidden = false
        }else{
            self.deleteBtn.isHidden = true
        }
        UIView.animate(withDuration: 0.8) {
            self.view.transform = .identity
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.SPB.startAnimation()
            self.playVideoOrLoadImage(index: 0)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DispatchQueue.main.async {
            self.SPB.currentAnimationIndex = 0
            self.SPB.cancel()
            self.SPB.isPaused = true
            self.resetPlayer()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - SegmentedProgressBarDelegate
    //1
    func segmentedProgressBarChangedIndex(index: Int) {
        playVideoOrLoadImage(index: index)
    }
    
    //2
    func segmentedProgressBarFinished() {
        print("segmentedProgressBarFinished")
        print(self.pageIndex)
        print(self.items.count)
        
        if  pageIndex == (self.items.count - 1) {
            
            self.dismiss(animated: true, completion: {
                self.refreshStories!()
            })
        } else {
            ContentViewControllerVC!.goNextPage(fowardTo: pageIndex + 1)
        }
    }
   
    
    @objc func tapOn(_ sender: UITapGestureRecognizer) {
        SPB.skip()
    }
    
    //MARK: - Play or show image
    func playVideoOrLoadImage(index: NSInteger) {
            self.SPB.duration = 5
            self.imagePreview.isHidden = false
            self.videoView.isHidden = true
        let url = URL.init(string:item[index].thumbnail ?? "")
        imagePreview.sd_setImage(with: url , placeholderImage:R.image.ic_profileimage())
        
    }
    
    // MARK: Private func
    private func getDuration(at index: Int) -> TimeInterval {
        var retVal: TimeInterval = 5.0
            retVal = 5.0
        return retVal
    }
    
    private func resetPlayer() {
        if player != nil {
            player.pause()
            player.replaceCurrentItem(with: nil)
            player = nil
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        self.deleteStory()
        
    }
    //MARK: - Button actions
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        resetPlayer()
    }
    private func deleteStory(){
        SPB.isPaused = false
        
        self.showProgressDialog(text: "Loading...")
        let sessionToken = AppInstance.instance.sessionId ?? ""
        let storyID = item[self.SPB.currentAnimationIndex].id ?? ""
        Async.background({
            StoriesManager.instance.deleteStory(session_Token: sessionToken, story_id: storyID, completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("success?.message = \(success?.message ?? nil)")
                            self.dismiss(animated: true, completion: nil)
                            
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
