//
//  OrderItemList.swift
//  Cafe-Manager
//
//  Created by Lahiru on 4/5/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit

class OrderItemList: UITableView, UITableViewDelegate, UITableViewDataSource {
    var data:[OrderItemInfo] = []
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodItemCell") as! FoodItemCell
        let foodItem = data[indexPath.row]
        cell.foodName.text = foodItem.foodName
        cell.quantity.text = "\(foodItem.quantity) x "
        cell.price.text = "Rs \(foodItem.originalPrice * foodItem.quantity)"
        return cell
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
        dataSource = self
    }

}
