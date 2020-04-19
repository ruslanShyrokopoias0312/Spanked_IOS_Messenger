//
//  AppSetting.swift
//  WoWonder
//
//  Created by Olivin Esguerra on 17/03/2019.
//  Copyright © 2019 Olivin Esguerra. All rights reserved.
//

import UIKit

struct AppConstant {
    //cert key for demo wowonder
    //Demo Key
    /*
   VjFaV2IxVXdNVWhVYTJ4VlZrWndUbHBXVW5OamJHUnpXVE5vYTJFemFERlhhMmhoWVRBeGNXSkVSbGhoTWxKWVdsWldOR1JHVW5WWGJXeFdaVzFqTlNOV1JtUjNVV3N4Vms1SWJGTmlXR2hRVldwR1IwMUdVbFZUYkhCc1ZtNUNSVlJWVWtOWGJWWnlZVE5rVlZKdFVrZFVhMVY0VWxaV1dWVnRSbGRTVlhCNFZrZDRVMVpyTVZkalNFWlRZbGhDYUZaclZYZGtkejA5UURFek1XTTBOekZqT0dJMFpXUm1Oall5WkdRd1pXSm1OMkZrWmpOak0yUTNNelkxT0RNNFlqa2tNVGswTWpVeU16az0=
    
     */
   
    static let key = "VjFaV2IxVXdNVWhVYTJ4VlZrWndUbHBXVW5OT2JHdDNXa1ZrYTFZd1ZqVldWbWhYVjJzeGNXRkVTVDBqVmpGb2QxUnRVWGROVmxaU1YwZFNZVmxzVmxkTlJsSnpXa1YwYUZKVVZrVlVWVkpEVkd4YVNHRklSbFZTYlZKTFZGUkdkMWRHVGxsVmJFSlRVbGQzTWxaR1pIZGhhekZHVGxaV1ZHSlVSbEJhVjNSelRrRTlQVUJtTUdObU9HRTJNVGs0TnpKa1pURTVOVEF4T1RVNE56VXdNMlpsTlRJMlpXWXpOV1kyTVRKakxXVTVNV1ZtTmprd00yTTJNMk5oTnprNE5qY3lOamhoT0dRMU16WXpZMlptTFRVMU1UUTBOREkwSkRFNU5ESTFNak01"
}

struct ControlSettings {
    static let showSocicalLogin = true
    static let googleClientKey = "497109148599-u0g40f3e5uh53286hdrpsj10v505tral.apps.googleusercontent.com"
    static let oneSignalAppId = "ec5c74c1-c532-48ab-a19c-9f1b517a8942"
     static let agoraCallingToken = "cea80c3b9a744f69ba90a68d07ca9167"
    static let addUnitId = "ca-app-pub-3940256099942544/2934735716"
    static let  interestialAddUnitId = "ca-app-pub-3940256099942544/4411468910"
    
    
    static let twilloCall = true
    static let agoraCall = false;
    
  
    
    
    static let ShowSettingsGeneralAccount = true
    static let ShowSettingsAccountPrivacy = true
    static let ShowSettingsPassword = true
    static let ShowSettingsBlockedUsers = true
    static let ShowSettingsNotifications = false
    static let ShowSettingsDeleteAccount = true
    static var shouldShowAddMobBanner:Bool = true
    static var interestialCount:Int? = 3

}

extension UIColor {
    
    @nonobjc class var mainColor: UIColor {
        return UIColor.hexStringToUIColor(hex: "#444444")
    }
    
    @nonobjc class var startColor: UIColor {
        return UIColor.hexStringToUIColor(hex: "#444444")
    }
    
    @nonobjc class var endColor: UIColor {
        return UIColor.hexStringToUIColor(hex: "#FFFFFF")
    }
    
    @nonobjc class var pinkColor: UIColor {
        return UIColor.hexStringToUIColor(hex: "#D14660")
    }
}
