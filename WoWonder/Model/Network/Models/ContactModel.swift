//
//  ContactModel.swift
//  WoWonder
//
//  Created by Macbook Pro on 09/05/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation

struct ContactModel: Codable {
    let key, value: String?
    
    enum CodingKeys: String, CodingKey {
        case key = "Key"
        case value = "Value"
    }
}

