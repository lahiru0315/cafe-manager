//
//  jknk.swift
//  Cafe-Manager
//
//  Created by Lahiru on 4/5/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import Foundation
import UIKit
class DailyRecieptCell: UITableViewCell {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var itemList: UILabel!
    @IBOutlet weak var priceFrequencyList: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var canceledLabel: UILabel!
    var onPrintRequested:(()->Void)!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func printBtnTapped(_ sender: Any) {
        onPrintRequested()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
