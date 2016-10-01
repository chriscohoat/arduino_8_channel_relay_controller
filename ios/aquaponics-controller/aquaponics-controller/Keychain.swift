//
//  Keychain.swift
//
//  Created by Chris Cohoat on 9/9/16.
//  Copyright © 2016 Chris Cohoat. All rights reserved.
//

import Foundation
import Locksmith
import Alamofire
import UIKit

public final class Keychain {
    
    static let serviceName = "AquaponicsController"
    static let emailAddressKey = "emailAddress"
    static let tokenKey = "token"
    static let hasSkippedRegistrationKey = "hasSkippedRegistration"
    
    fileprivate static func appleIVA () -> NSString? {
        //This is nullable due to iOS < 6
        let identifierForVendor = UIDevice.current.identifierForVendor
        return identifierForVendor?.uuidString as NSString?
    }
    
    public static func getUuid () -> String {
        let userAccount:String = "UID"
        let dictionaryKey:String = "UID"
        let dictionary = Locksmith.loadDataForUserAccount(userAccount: userAccount, inService: serviceName)
        if dictionary == nil || dictionary?[dictionaryKey] == nil {
            var returnUuid:NSString? = appleIVA()
            if (returnUuid == nil) {
                returnUuid = UUID().uuidString as NSString?
            }
            var keychainDictionary:Dictionary<String, String> = Dictionary<String, String>()
            keychainDictionary[dictionaryKey] = returnUuid as? String
            do {
                try Locksmith.updateData(data: keychainDictionary, forUserAccount: userAccount, inService: serviceName)
            } catch {
                print("Could not save UUID to keychain dictionary")
            }
            return returnUuid! as String
        } else {
            return dictionary![dictionaryKey] as! String
        }
    }
    
    public static func checkUserIsAuthenticated () {
        
        func postTokenIsInvalidNotification() {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "TokenIsInvalid"), object: nil)
        }
        
        globalHelpers.makeAuthenticatedGet("/auth/verify", parameterDictionary: nil) { (error: NSError?, response:
            Dictionary<String, Any>?) in
            NSLog("error : \(error)")
            NSLog("response : \(response)")
            if error != nil || response == nil {
                postTokenIsInvalidNotification()
            } else if response!["error"] != nil {
                postTokenIsInvalidNotification()
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TokenIsValid"), object: nil)
            }
        }
        
    }
    
    public static func getEmailAddress () -> String? {
        return UserDefaults.standard.value(forKey: emailAddressKey) as? String
    }
    
    public static func saveEmailAddress (_ emailAddress: String) {
        UserDefaults.standard.set(emailAddress, forKey: emailAddressKey)
    }
    
    public static func getToken() -> String? {
        return UserDefaults.standard.value(forKey: tokenKey) as? String
    }
    
    public static func saveToken(_ token: String) {
        //Global notification for all interested views
        NotificationCenter.default.post(name: Notification.Name(rawValue: "LoginOrRegisterSucceeded"), object: nil)
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    public static func logoutUser () {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: tokenKey)
        userDefaults.removeObject(forKey: hasSkippedRegistrationKey)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "LogoutSucceeded"), object: nil)
        
    }
    
}
