//
//  LocationService.swift
//  Cafe-Manager
//
//  Created by Lahiru on 4/6/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class LocationService: CLLocationManager {
    override init() {
        super.init()
        delegate = self
    }
    func status()->CLAuthorizationStatus{
        return CLLocationManager.authorizationStatus()
    }
    var latestLocation:CLLocation?
    //check if location permission is given
    func canConinue()->Bool{
        let state = status()
        if(state == .authorizedWhenInUse){
            return true
        }
        return false
    }
    var onLocationRecived : ((CLLocation?) -> Void)?
    var onPermissionAllowed : ((Bool) -> Void)?
    var onPermissionUndetermined: (() -> Void)?
    
}
extension LocationService:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == .authorizedWhenInUse){
            onPermissionAllowed?(true)
        }else if status == .notDetermined{
            onPermissionUndetermined?()
        }else{
            onPermissionAllowed?(false)
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latestLocation = locations.first
        onLocationRecived?(locations.first)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

