//
//  LoginViewController.swift
//
//
//  Created by Chris Cohoat on 9/12/16.
//  Copyright © 2016 Chris Cohoat. All rights reserved.
//

import UIKit
import SCLAlertView
import JGProgressHUD
import Alamofire

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textfieldUsernameEmail: UITextField!
    @IBOutlet weak var textfieldPassword: UITextField!
    
    override func viewDidLoad() {
        if let emailAddress = Keychain.getEmailAddress() {
            self.textfieldUsernameEmail.text = emailAddress
            textfieldPassword.becomeFirstResponder()
        } else {
            textfieldUsernameEmail.becomeFirstResponder()
        }
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Aquaponics"
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        NSLog("Returning...")
        if textField == textfieldPassword {
            NSLog("Password")
            self.buttonLoginTapped(nil)
        } else if (textField == textfieldUsernameEmail) {
            self.textfieldPassword.becomeFirstResponder()
        }
        return true
    }
    
    @IBAction func buttonLoginTapped(_ sender: AnyObject?) {
        let hud = JGProgressHUD(style: .dark)
        hud?.textLabel.text = "Logging In..."
        if textfieldUsernameEmail.text == nil {
            SCLAlertView().showError("Error", subTitle: "Email or username is required")
        } else if textfieldPassword.text == nil {
            SCLAlertView().showError("Error", subTitle: "Password is required")
        } else {
            Keychain.saveEmailAddress(textfieldUsernameEmail.text!)
            hud?.show(in: self.view)
            let loginDictionary:Parameters = [
                "username": textfieldUsernameEmail.text!,
                "password": textfieldPassword.text!
            ]
            globalHelpers.makeAnonPost("/auth/login", uploadDictionary: loginDictionary) { (error: NSError?, response:
                Dictionary<String, Any>?) in
                NSLog("error : \(error)")
                NSLog("response : \(response)")
                hud?.dismiss()
                if error != nil {
                    SCLAlertView().showError("Error", subTitle: "An error has occurred")
                } else if let token = response!["token"] as? String, let user = response!["user"] as? NSDictionary {
                    Keychain.saveToken(token)
                    globalHelpers.myAccount = User(apiResponseJson: user, persistToKeychain: true)
                    self.showMain()
                } else {
                    SCLAlertView().showError("Error", subTitle: "Login was invalid")
                }
            }
        }
    }
    
    func showMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainRootTabBarController") as! UITabBarController
        self.present(initialViewController, animated: true, completion: nil)
    }
    
}
