//
//  User.swift
//
//  Created by Chris Cohoat on 9/9/16.
//  Copyright © 2016 Chris Cohoat. All rights reserved.
//

import Foundation

open class User {
    
    var emailAddress: String
    var outlets: [Outlet] = []
    
    init(apiResponseJson: NSDictionary, persistToKeychain: Bool=false) {
        //persistToKeychain should only be used for the logged in (or registered) account.
        self.emailAddress = apiResponseJson["email"] as! String
        if let outlets = apiResponseJson["outlets"] as? [[String: String?]] {
            self.outlets = outlets.enumerated().map({ (offset: Int, element: [String: String?]) -> Outlet in
                return Outlet()
            })
        }
        if persistToKeychain {
            Keychain.saveEmailAddress(self.emailAddress)
        }
    }
    
}
