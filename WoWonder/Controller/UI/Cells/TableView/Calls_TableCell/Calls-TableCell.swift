//
//  Calls-TableCell.swift
//  WoWonder
//
//  Created by Macbook Pro on 25/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class Calls_TableCell: UITableViewCell {
    
        @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var callLogImage: UIImageView!
    @IBOutlet weak var callLogLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var delegate:SelectContactCallsDelegate!
    var indexPath:Int? = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func callPressed(_ sender: Any) {
         self.delegate.selectCalls(index: self.indexPath ?? 0, type: "audio")
    }
}
