//
//  StaticInfoManager.swift
//  Cafe-Manager
//
//  Created by Lahiru on 4/5/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import Foundation
class StaticInfoManager {
    static let statusMeaning:[Int:String] = [
        1:"New",
        2:"Preparing",
        3:"Ready",
        4:"Arriving",
        5:"Done",
        6:"Cancel"
    ]
    static var didWarnUserAboutNoInternet = false
    static let dateTimeFormat = "yy/MM/dd HH:mm"
    static let dateOnly = "yy/MM/dd"
    static let unknownCategory = "unknown category"
    static var didUITestingFirebaseConfigured = false
    static var didTestingFirebaseConfigured = false
    static func getDateString()->String{
        let currentTimestamp = DateFormatter()
        currentTimestamp.dateFormat = StaticInfoManager.dateTimeFormat
        return currentTimestamp.string(from: Date())
    }
}
