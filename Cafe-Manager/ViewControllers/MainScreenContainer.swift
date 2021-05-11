//
//  MainScreenContainer.swift
//  Cafe-Manager
//
//  Created by Lahiru on 4/6/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit
import FirebaseAuth
import Reachability
import Firebase
class MainScreenContainer: UITabBarController {
    var reachability:Reachability!
    @IBAction func onSignOut(_ sender: Any) {
        try? Auth.auth().signOut()
        let authenticateScreen = storyboard!.instantiateViewController(identifier: "authScreen") as AuthScreen
        navigationController!.navigationBar.isHidden = true
        navigationController!.setViewControllers([authenticateScreen], animated: true)
    }
    
    override func viewDidLoad() {
        reachability = try! Reachability()
        reachability.whenUnreachable = {para in
            print("no internet")
            AlertPopup(self).connectionChangeAlert()
        }
        do{
          try reachability.startNotifier()
        }catch{
          print("could not start reachability notifier")
        }
        navigationController!.navigationBar.isHidden = false
    }
 
}
