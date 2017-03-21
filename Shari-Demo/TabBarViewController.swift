//
//  TabBarViewController.swift
//  Shari-Demo
//
//  Created by nakajijapan on 2016/10/19.
//  Copyright © 2016年 nakajijapan. All rights reserved.
//

import UIKit
import Shari

class TabBarViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func buttonDidTap(button: UIButton) {
        
        let modalNavigationController = storyboard!.instantiateViewController(withIdentifier: "ModalNavigationController") as! ShariNavigationController
        
        // Transition Setting
        //ShouldTransformScaleDown = false
        //BackgroundColorOfOverlayView = UIColor.redColor()
        modalNavigationController.parentTabBarController = tabBarController

        tabBarController?.addChildViewController(modalNavigationController)
        tabBarController?.si.present(modalNavigationController)
        
    }
}
