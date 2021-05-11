//
//  StartupNavigationController.swift
//  Cafe-Manager
//
//  Created by Lahiru on 4/6/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit
import FirebaseAuth
class StartupNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        var authenticateScreen:AuthScreen!
        var locationRequestScreen:PermissionRequestScreen!
        let locationManager = LocationService()
        let homeScreen:UITabBarController!
        let canContinue = locationManager.canConinue()
        
        //check if user has provided location permission then navigate to screen accordingly
        navigationBar.isHidden = true
        //with setViewControllers I replace the the stack screen with the screen to display
        if(canContinue){

            if(Auth.auth().currentUser == nil){
                authenticateScreen = storyboard!.instantiateViewController(identifier: "authScreen") as AuthScreen
                setViewControllers([authenticateScreen], animated: true)
               
            }else{
                homeScreen = storyboard!.instantiateViewController(identifier: "homeScreen") as! MainScreenContainer
                setViewControllers([homeScreen], animated: true)
            }
            
        }else{
            locationRequestScreen = storyboard!.instantiateViewController(identifier: "permissionRequestScreen") as PermissionRequestScreen
            setViewControllers([locationRequestScreen], animated: true)
        }
    }

}
