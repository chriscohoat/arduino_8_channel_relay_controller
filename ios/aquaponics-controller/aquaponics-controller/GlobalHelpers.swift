//
//  GlobalHelpers.swift
//
//  Created by Chris Cohoat on 6/7/16.
//  Copyright © 2016 Chris Cohoat LLC. All rights reserved.
//

import Alamofire
import FontAwesome_swift
import Eureka

#if !DEBUG
    func println(_ object: Any) {}
    func print(_ object: Any){}
    func NSLog(_ format: String, _ args: CVarArg...){}
#endif

var globalHelpers = GlobalHelpers()

struct GlobalHelpers {
    
    let PROD_ADDRESS = "http://cohoat.hopto.org"
    let LOCAL_ADDRESS = "http://localhost:9999"
    
    var apiAddress: String
    
    var loadingMyAccount: Bool = false
    var myAccount: User?
    
    init() {
        #if DEBUG
            apiAddress = LOCAL_ADDRESS //LOCAL_ADDRESS, PROD_ADDRESS
        #else
            apiAddress = PROD_ADDRESS
        #endif
    }
    
    func buildError(_ message: String) -> NSError {
        var errorDictionary: [AnyHashable: Any] = [:]
        errorDictionary[NSLocalizedDescriptionKey] = message
        return NSError(domain: self.apiAddress, code: 123, userInfo: errorDictionary)
    }
    
    func getTimestampFromDateUnix(_ date: NSDate) -> Double {
        return date.timeIntervalSince1970.multiplied(by: 1000)
    }
    
    func getDateFromTimestamp(_ timestamp: TimeInterval) -> NSDate {
        return NSDate(timeIntervalSince1970: timestamp)
    }

    func buildBaseApiRoute() -> String {
        return "\(self.apiAddress)/api/v1"
    }
    
    func buildApiRoute(_ route: String, authToken: String?=nil) -> String {
        if authToken != nil {
            return "\(self.buildBaseApiRoute())\(route)?auth_token=\(authToken!)"
        }
        return "\(self.buildBaseApiRoute())\(route)"
    }
    
    func makeAnonPost(_ route: String, uploadDictionary: Parameters?, callback: @escaping (NSError?, Dictionary<String, Any>?) -> ()) {
        
        var uploadDictionary = uploadDictionary
        
        if uploadDictionary == nil {
            uploadDictionary = [:]
        }
        uploadDictionary!["uid"] = Keychain.getUuid() as AnyObject?
        
        Alamofire.request(buildApiRoute(route), method: .post, parameters: uploadDictionary, encoding: JSONEncoding.default)
            .responseJSON { response in
                NSLog("\(response.result)")
                if let jsonResult = response.result.value as? [String: Any] {
                    if let errors = jsonResult["errors"] as? [[String: Any]] {
                        //Server is responding, but response had errors. Handle failure
                        let errorMessage = errors.count > 0 ? errors[0]["msg"] as! String : "Something went wrong"
                        callback(self.buildError(errorMessage), nil)
                    } else {
                        callback(nil, jsonResult)
                    }
                } else {
                    //Server is not responding. Maybe should show a different error
                    callback(self.buildError("Server is not responding"), nil)
                }
        }
        
    }
    
    func makeAnonGet(_ route: String, parameterDictionary: Parameters?, callback: @escaping (NSError?, Dictionary<String, Any>?) -> ()) {
        
        var parameterDictionary = parameterDictionary
        
        if parameterDictionary == nil {
            parameterDictionary = [:]
        }
        parameterDictionary!["uid"] = Keychain.getUuid() as AnyObject?
        
        Alamofire.request(buildApiRoute(route), method: .get, parameters: parameterDictionary)
            .responseJSON { response in
                NSLog("\(response.result)")
                if let jsonResult = response.result.value as? Dictionary<String, AnyObject> {
                    if let error = jsonResult["error"] as? String {
                        callback(self.buildError(error), nil)
                    } else if jsonResult["error"] != nil {
                        callback(self.buildError("Something went wrong"), nil)
                    } else {
                        callback(nil, jsonResult)
                    }
                } else {
                    //Server is not responding. Maybe should show a different error
                    callback(self.buildError("Server is not responding"), nil)
                }
        }
        
    }
    
    func makeAuthenticatedPost(_ route: String, uploadDictionary: Parameters?, callback: @escaping (NSError?, Dictionary<String, Any>?) -> ()) {
        
        if let existingToken = Keychain.getToken() {
            
            let finalRoute = "\(route)?auth_token=\(existingToken)"
            var uploadDictionary = uploadDictionary
            
            if uploadDictionary == nil {
                uploadDictionary = [:]
            }
            uploadDictionary!["uid"] = Keychain.getUuid() as AnyObject?
            
            Alamofire.request(buildApiRoute(finalRoute), method: .post, parameters: uploadDictionary, encoding: JSONEncoding.default)
                .responseJSON { response in
                    NSLog("\(response.result)")
                    if let jsonResult = response.result.value as? [String: Any] {
                        if let error = jsonResult["error"] as? String {
                            callback(self.buildError(error), nil)
                        } else if jsonResult["error"] != nil {
                            NSLog("\(jsonResult["error"])")
                            callback(self.buildError("Something went wrong"), nil)
                        } else {
                            callback(nil, jsonResult)
                        }
                    } else {
                        NSLog("\(response.result.value)")
                        //Server is not responding. Maybe should show a different error
                        callback(self.buildError("Server is not responding"), nil)
                    }
            }
            
        } else {
            callback(self.buildError("Need to login"), nil)
        }
        
    }
    
    func makeAuthenticatedGet(_ route: String, parameterDictionary: Parameters?, callback: @escaping (NSError?, Dictionary<String, Any>?) -> ()) {
        
        if let existingToken = Keychain.getToken() {
            
            var parameterDictionary = parameterDictionary
            
            if parameterDictionary == nil {
                parameterDictionary = [:]
            }
            parameterDictionary!["uid"] = Keychain.getUuid() as AnyObject?
            parameterDictionary!["auth_token"] = existingToken as AnyObject?
            
            NSLog("\(buildApiRoute(route))")
            
            Alamofire.request(buildApiRoute(route), method: .get, parameters: parameterDictionary)
                .responseJSON { response in
                    if let jsonResult = response.result.value as? Dictionary<String, AnyObject> {
                        if let error = jsonResult["error"] {
                            if let errorString = error as? String {
                                callback(self.buildError(errorString), nil)
                            } else {
                                callback(self.buildError("Something went wrong"), nil)
                            }
                        } else {
                            callback(nil, jsonResult)
                        }
                    } else {
                        //Server is not responding. Maybe should show a different error
                        callback(self.buildError("Server is not responding"), nil)
                    }
            }
            
        } else {
            callback(self.buildError("Need to login"), nil)
        }
        
    }
    
    
    func makePhotoUpload(_ route: String, image: UIImage, uploadProgressCallback: @escaping (Progress) -> Void, callback: @escaping (NSError?, Dictionary<String, Any>?) -> ()) {
        
        if let existingToken = Keychain.getToken() {
            
            let randomPhotoName: String = UUID().uuidString
            
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    if let imageData = UIImageJPEGRepresentation(image, 1) {
                        multipartFormData.append(InputStream(data: imageData), withLength: UInt64(imageData.count), name: "image", fileName: "\(randomPhotoName).png", mimeType: "image/png")
                    }
                    multipartFormData.append(Keychain.getUuid().data(using: .utf8)!, withName: "uuid")
                },
                to: buildApiRoute(route, authToken: existingToken),
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.uploadProgress(closure: uploadProgressCallback)
                        upload.responseJSON { response in
                            if let jsonResult = response.result.value as? Dictionary<String, AnyObject> {
                                callback(nil, jsonResult)
                            } else {
                                callback(self.buildError("Something went wrong"), nil)
                            }
                        }
                    case .failure( _):
                        callback(self.buildError("Server is not responding"), nil)
                    }
                }
            )
            
        } else {
            callback(self.buildError("Need to login"), nil)
        }
        
     }
    
    mutating func getMyAccount() {
        globalHelpers.loadingMyAccount = true
        self.makeAuthenticatedGet("/me", parameterDictionary: nil) { (error: NSError?, response: Dictionary<String, Any>?) in
            globalHelpers.loadingMyAccount = false
            if error == nil && response != nil {
                globalHelpers.myAccount = User(apiResponseJson: response! as NSDictionary, persistToKeychain: true)
                globalHelpers.userAccountHasChangedNotification()
            } else {
                globalHelpers.userAccountCouldNotBeLoadedNotification()
            }
        }
    }
    
    func setupTabBarItem(_ tabBarItem: UITabBarItem, name: FontAwesome) {
        tabBarItem.image = UIImage.fontAwesomeIconWithName(name, textColor: UIColor.black, size: CGSize(width: 25, height: 25))
        tabBarItem.imageInsets = UIEdgeInsetsMake(-2, 0, 2, 0)
        tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -8)
    }
    
    
    func getRandomColor() -> UIColor{
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
        
    func userTypeHasChanged() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserTypeChanged"), object: nil)
    }
    
    func userAccountHasChangedNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserAccountHasChanged"), object: nil)
    }
    
    func userAccountCouldNotBeLoadedNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserAccountCouldNotBeLoaded"), object: nil)
    }
    
}
