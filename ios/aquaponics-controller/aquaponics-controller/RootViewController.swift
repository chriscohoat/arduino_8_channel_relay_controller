//
//  RootViewController.swift
//  aquaponics-controller
//
//  Created by Chris Cohoat on 10/1/16.
//  Copyright © 2016 Chris Cohoat. All rights reserved.
//

import UIKit
import FontAwesome_swift

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(25)] as Dictionary!
        //self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
        //self.navigationItem.rightBarButtonItem?.title = String.fontAwesomeIconWithName(.Gear)
        self.navigationItem.rightBarButtonItem?.image = UIImage.fontAwesomeIconWithName(.Gear, textColor: UIColor.black, size: CGSize(width: 25, height: 25))
        //self.navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsetsMake(-4, 0, 4, 0)
        //self.navigationItem.rightBarButtonItem?.titlePositionAdjustment = UIOffsetMake(0, -8)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
