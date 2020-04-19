//
//  BaseModel.swift
//  WoWonder
//
//  Created by Macbook Pro on 29/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class BaseModel{
    struct ServerKeyErrorModel: Codable {
        let apiStatus: String?
        let errors: ServerKeyErrors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case errors
        }
    }
    
    struct ServerKeyErrors: Codable {
        let  errorText: String?
        
        enum CodingKeys: String, CodingKey {
            case errorText = "error_text"
        }
    }

    
}
