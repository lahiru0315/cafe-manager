//
//  LocationPermissionScreen.swift
//  Cafe-Manager
//
//  Created by Lahiru on 4/6/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit
import FirebaseAuth
class PermissionRequestScreen: UIViewController {
    let locationService = LocationService()
    let auth = Auth.auth()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*Upon first loading this viewController the app will check if location permission is deined and
        if so the user is prompt to open location and maually provide permission*/
        let status = locationService.status()
        if status == .denied || status == .restricted{
            openSettings(status == .denied)
        }
        
        //setting the callabck when permission is provided realtime by the user
        locationService.onPermissionAllowed = { didAllowed in
            if didAllowed{
                self.navigateToMainScreen()
            }else{
                self.openSettings(self.locationService.status() == .denied)
            }
        }
        
        //if in some case if the permission is undertermined the app will once again request for permission
        //eg: user can set 'ask next time' in privacy settings
        locationService.onPermissionUndetermined = {
            self.locationService.requestWhenInUseAuthorization()
        }
    }
    
    
    func openSettings(_ isLocationServiceTurnOff:Bool){
        //first the user is promt with a message explaining the permission is denied and then navigate the user to settings...
        let alertController:UIAlertController!
        var message:String!
        if isLocationServiceTurnOff{
            message = "You have turned off the location service please turn on the location service manually in settings"
            
        }else{
            message = "It seems you have not provided the location permission you have to open settings manually and provide us the location permission"
        }
        alertController = UIAlertController(title :"Location service is disabled",message:message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { action in
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        }))
        alertController.addAction(UIAlertAction(title: "No need", style: .cancel, handler: { action in
            alertController.dismiss(animated: true, completion: nil)
        }))
        present(alertController,animated: true)
    }
    func navigateToMainScreen(){
        let nextScreen = storyboard!.instantiateViewController(identifier: auth.currentUser==nil ? "authScreen":"homeScreen")
        navigationController?.setViewControllers([nextScreen], animated: true)
    }

    
    @IBAction func requestPermissionBtnTapped(_ sender: Any) {
        let status = locationService.status()
        /*
         In case if the permission is already denied eg: when user first denied the permission when asked first time and once again press this button again 'requestWhenInUseAuthorization' will not operate.Thus user is asked to open settings... */
        if status == .denied || status == .restricted{
            openSettings(status == .denied)
        }else{
            locationService.requestWhenInUseAuthorization()
        }
    }

}
