//
//  Group-TableCell.swift
//  WoWonder
//
//  Created by Macbook Pro on 26/09/2019.
//  Copyright © 2019 ScriptSun. All rights reserved.
//

import UIKit

class Group_TableCell: UITableViewCell {
    @IBOutlet weak var groupNameLabel: UILabel!
    
    @IBOutlet weak var lastSeenLabel: UILabel!
    @IBOutlet weak var groupImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
