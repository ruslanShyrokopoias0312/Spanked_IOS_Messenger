//
//  TextFieldExt.swift
//  WoWonder
//
//  Created by Olivin Esguerra on 18/03/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit

extension UITextField {
    
    func whitePlaceHolder(text:String){
        self.attributedPlaceholder = NSAttributedString(string: text,
                           attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
}
