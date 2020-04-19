//
//  SearchRandomVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 25/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import WowonderMessengerSDK
import GoogleMobileAds

class SearchRandomVC: BaseVC {
    
    @IBOutlet weak var downTextLable: UILabel!
    @IBOutlet weak var searchContactLabel: UILabel!
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchRandomBtn: UIButton!
    
    var statusIndex:Int? = nil
    var searchText:String? = "random"
    private lazy var searchBar = UISearchBar(frame: .zero)
    private  var refreshControl = UIRefreshControl()
    private var userArray = [SearchModel.User]()
    private let color = UIColor.hexStringToUIColor(hex: "A84849")
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if statusIndex == 0{
            self.tableView.isHidden = true
            self.showStack.isHidden = false
            searchRandomBtn.isHidden = false
            
        }else {
            self.fetchData(textForSearch: searchText ?? "random")
        }
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
    
    @IBAction func setChangePressed(_ sender: Any) {
        let vc = R.storyboard.dashboard.searchByVC()
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    @IBAction func searchRandomPressed(_ sender: Any) {
        self.fetchData(textForSearch: "all")
    }
    
    func setupUI(){
        self.searchRandomBtn.setTitle(NSLocalizedString("Search", comment: ""), for: .normal)
        self.searchContactLabel.text = NSLocalizedString("Search Contact", comment: "")
        self.downTextLable.text = NSLocalizedString("Start writing to search", comment: "")
        self.showStack.isHidden = true
        searchRandomBtn.isHidden = true
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        self.tableView.isHidden = true
        searchBar.placeholder = "Search..."
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableView.automaticDimension
        tableView.register( R.nib.searchRandomTableCell(), forCellReuseIdentifier: R.reuseIdentifier.searchRandom_TableCell.identifier)
        
    }
    @objc func refresh(sender:AnyObject) {
        self.userArray.removeAll()
        self.tableView.reloadData()
        self.fetchData(textForSearch: searchText ?? "random")
        
    }
    
    private func fetchData(textForSearch:String){
        self.showProgressDialog(text: "Loading...")
        self.userArray.removeAll()
        self.tableView.reloadData()
        let sessionToken = AppInstance.instance.sessionId ?? ""
        let gender = AppInstance.instance.genderText ?? "All"
        Async.background({
            SearchManager.instance.searchUser(session_Token: sessionToken, search_Key: textForSearch, gender:gender , completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.users ?? [])")
                            if (success?.users?.isEmpty)!{
                                self.showStack.isHidden = false
                                self.searchRandomBtn.isHidden = false
                                self.tableView.isHidden = true
                                self.refreshControl.endRefreshing()
                            }else {
                                self.tableView.isHidden = false
                                self.showStack.isHidden = true
                                self.searchRandomBtn.isHidden = true
                                self.userArray = success?.users ?? []
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
    
}

extension SearchRandomVC: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        //Show Cancel
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.tintColor = .white
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        self.searchText = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        self.fetchData(textForSearch: self.searchText ?? "random")
        
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        //Hide Cancel
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = String()
        searchBar.resignFirstResponder()
        
        
    }
}

extension SearchRandomVC: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userArray.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.searchRandom_TableCell.identifier) as? SearchRandom_TableCell
        let object = self.userArray[indexPath.row]
        cell?.delegate = self
        cell?.indexPath = indexPath.row
        cell?.userId  = object.userID ?? ""
        cell?.usernameLabel.text = object.username ?? ""
        cell?.timeLabel.text = "Hi there I am using WoWonder"
        let url = URL.init(string:object.avatar ?? "")
        cell?.profileImage.sd_setImage(with: url , placeholderImage:R.image.ic_profileimage())
        cell?.profileImage.cornerRadiusV = (cell?.profileImage.frame.height)! / 2
        if object.isFollowing == 0{
            cell!.followBtn.backgroundColor = UIColor.white
            cell!.followBtn.borderColorV = self.color
            cell!.followBtn.borderWidthV = 1
            cell!.followBtn.setTitleColor(self.color, for: .normal)
            cell!.followBtn.setTitle("follow", for: .normal)
        }else{
            cell!.followBtn.backgroundColor = self.color
            cell!.followBtn.setTitleColor(UIColor.white, for: .normal)
            cell?.followBtn.setTitle("following", for: .normal)
        }
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72;
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
        let vc = R.storyboard.dashboard.selectRandomPopupVC()
        let userObject = userArray[indexPath.row]
        vc?.searchObject = userObject
        vc?.delegate = self
        self.present(vc!, animated: true, completion: nil)
    }
}
extension SearchRandomVC:FollowUnFollowDelegate{
    
    func followUnfollow(user_id: String, index: Int, cellBtn: UIButton) {
//        self.showProgressDialog(text: "Loading...")
        let sessionToken = AppInstance.instance.sessionId ?? ""
        Async.background({
            FollowingManager.instance.followUnfollow(user_id: user_id, session_Token: sessionToken, completionBlock: { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.followStatus ?? "")")
                            self.view.makeToast(success?.followStatus ?? "")
                            if success?.followStatus  ?? "" == "followed"{
                                cellBtn.backgroundColor = self.color
                                cellBtn.setTitleColor(UIColor.white, for: .normal)
                                cellBtn.setTitle("following", for: .normal)
//                                self.view.makeToast(success?.followStatus ?? "")
                                
                            }else{
                                cellBtn.backgroundColor = UIColor.white
                                cellBtn.borderColorV = self.color
                                cellBtn.borderWidthV = 1
                                cellBtn.setTitleColor(self.color, for: .normal)
                                cellBtn.setTitle("follow", for: .normal)
//                                self.view.makeToast(success?.followStatus ?? "")
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
extension SearchRandomVC:SelectRandomDelegate{
    func selectRandom(recipientID: String, searchObject: SearchModel.User) {
        
        let chatColor = UserDefaults.standard.getChatColorHex(Key: Local.CHAT_COLOR_HEX.ChatColorHex)
        let vc = R.storyboard.chat.chatScreenVC()
        vc?.recipientID = recipientID
        vc!.searchUserObject = searchObject
        vc?.chatColorHex = chatColor
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
}
