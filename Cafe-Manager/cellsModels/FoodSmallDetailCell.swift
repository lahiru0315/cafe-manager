//
//  FoodSmallDetailCell.swift
//  Cafe-Manager
//
//  Created by Lahiru on 4/4/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit

class FoodSmallDetailCell: UITableViewCell {

    @IBOutlet weak var promotion: UIPaddingLabel!
    @IBOutlet weak var foodDescription: UILabel!
    @IBOutlet weak var cost: UILabel!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodTitle: UILabel!
    @IBOutlet weak var foodAvailabiltySwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        foodAvailabiltySwitch.addTarget(self, action: #selector(availabilitySwap(sender:)), for: .valueChanged)
        // Initialization code
    }
    var onAvailabilityChanged:((Bool)->Void)!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @objc func availabilitySwap(sender:UISwitch){
        if sender.isOn{
            contentView.alpha = 1.0
        }else{
            contentView.alpha = 0.5
        }
        onAvailabilityChanged(sender.isOn)
    }
}
