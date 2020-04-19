//
//  RequestGroupOne-TableCell.swift
//  WoWonder
//
//  Created by Muhammad Haris Butt on 2/24/20.
//  Copyright © 2020 ScriptSun. All rights reserved.
//

import UIKit
import Async
class RequestGroupOne_TableCell: UITableViewCell {
    
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupImage: UIImageView!
    
    var groupID:Int? = 0
    var vc:GroupRequestVC?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func rejectPressed(_ sender: Any) {
        self.acceptRejectGroupRequest(type: "reject")
    }
    @IBAction func acceptPressed(_ sender: Any) {
        self.acceptRejectGroupRequest(type: "accept")

    }
    private func acceptRejectGroupRequest(type:String){
        self.vc?.showProgressDialog(text: "Loading...")
        let sessionToken = AppInstance.instance.sessionId ?? ""
        let groupID = self.groupID ?? 0
        Async.background({
            GroupRequestManager.instance.accceptGroupRequest(session_Token: sessionToken, type: type, groupID: groupID) { (success, sessionError, serverError, error) in
                if success != nil{
                    Async.main({
                        self.vc!.dismissProgressDialog {
                            
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.vc!.dismissProgressDialog {
                            self.vc!.view.makeToast(sessionError?.errors?.errorText)
                            log.error("sessionError = \(sessionError?.errors?.errorText)")
                            
                        }
                    })
                }else if serverError != nil{
                    Async.main({
                        self.vc!.dismissProgressDialog {
                            self.vc!.view.makeToast(serverError?.errors?.errorText)
                            log.error("serverError = \(serverError?.errors?.errorText)")
                        }
                        
                    })
                    
                }else {
                    Async.main({
                        self.vc!.dismissProgressDialog {
                            self.vc!.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription)")
                        }
                    })
                }
            }
        })
    }
}
