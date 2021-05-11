//
//  wqdqw.swift
//  Cafe-Manager
//
//  Created by Lahiru on 4/5/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import Foundation
struct OrderItemInfo:Codable {
    var foodName:String
    var quantity:Int = 1
    var originalPrice:Int

    func asDictionary()->[String:Any]{
        let data = try? JSONEncoder().encode(self)
        return try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : Any]
    }
}
