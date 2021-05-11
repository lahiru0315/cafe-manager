//
//  OrderStatusCell.swift
//  Cafe-Manager
//
//  Created by Lahiru on 4/4/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit

class OrderStatusCell: UITableViewCell {

    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var statusContainer: UIButton!
    @IBOutlet weak var buttonContainer: UIStackView!
    @IBOutlet weak var secondaryButton: UIButton!
    @IBOutlet weak var orderID: UILabel!
    var onOrderSelected:(()->Void)!
    override func awakeFromNib() {
        //id orderStatusCell
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected{
            onOrderSelected()
        }
        // Configure the view for the selected state
    }

}
