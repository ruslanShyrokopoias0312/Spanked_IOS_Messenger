//
//  NoInternetDialogVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 29/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import WowonderMessengerSDK
class NoInternetDialogVC: UIViewController {
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func retryPressed(_ sender: Any) {
        if(Connectivity.isConnectedToNetwork()) {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.view.makeToast("Internet not connected, please check your internet connection.", duration: 2.0, position: .bottom)
        }
    }
}

