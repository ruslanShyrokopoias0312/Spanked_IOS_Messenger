 //
//  ProgressDialog.swift
//  WoWonder
//
//  Created by Olivin Esguerra on 18/03/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit

class ProgressDialog {
    init() {
        SKActivityIndicator.spinnerStyle(.spinningCircle)
    }
    
    func show(){
        SKActivityIndicator.show()
    }
    
    func dismiss(){
        SKActivityIndicator.dismiss()
    }
}
