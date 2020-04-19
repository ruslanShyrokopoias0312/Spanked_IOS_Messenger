//
//  BlockedUsers-TableCell.swift
//  WoWonder
//
//  Created by Macbook Pro on 26/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class BlockedUsers_TableCell: UITableViewCell {
      @IBOutlet weak var usernameLabel: UILabel!
 
    @IBOutlet weak var lastSeenLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
