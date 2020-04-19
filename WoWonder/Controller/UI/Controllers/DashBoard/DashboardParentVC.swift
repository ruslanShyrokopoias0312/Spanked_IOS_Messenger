//
//  DashboardParentVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 24/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import DropDown
import WowonderMessengerSDK
class DashboardParentVC: ButtonBarPagerTabStripViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    
    private let moreDropdown = DropDown()
    override func viewDidLoad() {
        self.setupUI()
        super.viewDidLoad()
        self.customizeDropdown()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
         self.navigationController?.isNavigationBarHidden = false
    }
    @IBAction func nearByPressed(_ sender: Any) {
        AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1

        let vc = R.storyboard.findFriends.findFriendsVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func morePressed(_ sender: Any) {
        AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1

        self.moreDropdown.show()
    }
    @IBAction func searchPressed(_ sender: Any) {
        AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1

        let vc = R.storyboard.dashboard.searchRandomVC()
        vc?.statusIndex = 0
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    func customizeDropdown(){
        moreDropdown.dataSource = ["Block User List","Settings"]
        moreDropdown.backgroundColor = UIColor.hexStringToUIColor(hex: "454345")
        moreDropdown.textColor = UIColor.white
        moreDropdown.anchorView = self.moreBtn
//        moreDropdown.bottomOffset = CGPoint(x: 312, y:-270)
        moreDropdown.width = 200
        moreDropdown.direction = .any
        moreDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0{
                let vc = R.storyboard.dashboard.blockedUsersVC()
                self.navigationController?.pushViewController(vc!, animated: true)
            }else{
              let vc = R.storyboard.settings.settingsVC()
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            print("Index = \(index)")
        }
        
    }

    private func setupUI() {
        
       self.nameLabel.text = NSLocalizedString("WoWonder Messenger", comment: "")
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = .clear
        settings.style.buttonBarItemFont =  UIFont(name: "Poppins", size: 15)!
        settings.style.selectedBarHeight = 1
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        let color = UIColor(red:26/255, green: 34/255, blue: 78/255, alpha: 0.4)
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = color
            newCell?.label.textColor = .white
            print("OldCell",oldCell)
            print("NewCell",newCell)
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let chatVC = R.storyboard.dashboard.chatVC()
        let groupVC = R.storyboard.dashboard.groupVC()
        let storiesVC = R.storyboard.dashboard.storiesVC()
        let callVC = R.storyboard.dashboard.callVC()
        
        
        return [chatVC!,groupVC!,storiesVC!,callVC!]
        
    }
    


}
