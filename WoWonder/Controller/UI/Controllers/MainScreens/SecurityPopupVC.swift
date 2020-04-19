//
//  SecurityPopupVC.swift
//  WoWonder
//
//  Created by Macbook Pro on 29/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import WowonderMessengerSDK

class SecurityPopupVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var errorTextLabel: UILabel!
    
    var errorText:String? = ""
    var titleText:String? = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = titleText ?? "Security"
        self.errorTextLabel.text = errorText ?? "N/A"
       
    }
    

    @IBAction func okPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
