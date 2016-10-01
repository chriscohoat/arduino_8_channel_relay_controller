//
//  SettingsFormViewController.swift
//  aquaponics-controller
//
//  Created by Chris Cohoat on 10/1/16.
//  Copyright © 2016 Chris Cohoat. All rights reserved.
//

import UIKit
import Eureka

class SettingsFormViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        form
            +++ Section("General Information")
                <<< IntRow() {
                    $0.title = "Number of outlets"
                }
                <<< URLRow() {
                    $0.title = "API Address"
                }
            +++ Section()
                <<< ButtonRow("logout") {
                    $0.title = "Logout"
                }.onCellSelection({ (cell, row) in
                    Keychain.logoutUser()
                    let storyboard = UIStoryboard(name: "Entrance", bundle: nil)
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "EntranceRootNavigationViewController") as! UINavigationController
                    self.present(initialViewController, animated: true, completion: nil)
                })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
