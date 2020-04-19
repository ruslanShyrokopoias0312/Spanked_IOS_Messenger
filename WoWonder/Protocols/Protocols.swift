//
//  Protocols.swift
//  WoWonder
//
//  Created by Macbook Pro on 05/05/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import UIKit
protocol GenderDelegate {
    func selectGender(text:String,Index:Int)
}

protocol FollowUnFollowDelegate {
    func followUnfollow(user_id:String,index:Int,cellBtn:UIButton)
}
protocol ImagePickerDelegate{
    func pickImage(image:UIImage? , videoData:Data?,videoURL:URL? ,Status:Bool?)
}
protocol PlayVideoDelegate {
    func playVideo(index:Int,status:Bool)
}
protocol PlayAudioDelegate {
    func playAudio(index:Int,status:Bool,url:URL,button:UIButton)
}

protocol SelectFileDelegate {
    func selectImage(status:Bool)
    func selecVideo(status:Bool)
}
protocol SelectContactDetailDelegate {
    func selectContact(key:String,value:String)
}

protocol SelectContactCallsDelegate {
    func selectCalls(index:Int,type:String)
}

protocol SelectRandomDelegate {
    func selectRandom(recipientID:String, searchObject:SearchModel.User)
}
protocol CallReceiveDelegate {
    func receiveCall(callId:Int,RoomId:String,callingType:String,username:String,profileImage:String,accessToken:String?)
}
protocol SelectLanguageDelegate {
    func selectLanguage(index:Int,Button:UIButton)
}

