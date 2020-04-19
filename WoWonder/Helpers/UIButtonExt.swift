//
//  UIButtonExt.swift
//  WoWonder
//
//  Created by Olivin Esguerra on 18/03/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit

extension UIButton {
    func underline() {
        guard let text = self.titleLabel?.text else { return }
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        
        self.setAttributedTitle(attributedString, for: .normal)
    }
}
