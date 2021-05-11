//
//  Reciept.swift
//  Cafe-Manager
//
//  Created by Lahiru on 4/5/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import Foundation
struct Reciept:Codable {
    var date:String
    var products:[OrderItemInfo]
    var totalCost:Int = 0
    var isRejected:Bool = false
    func asDictionary()->[String:Any]{
        let data = try? JSONEncoder().encode(self)
        return try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : Any]
    }
    static func decodeAsStruct(data:[String:Any])->Reciept{
        let serializedData = try! JSONSerialization.data(withJSONObject: data, options: [])
        return try! JSONDecoder().decode(Reciept.self, from: serializedData)
    }
}
