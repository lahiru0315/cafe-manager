//
//  cardView.swift
//  FoodCafe
//
//  Created by Lahiru on 2/28/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit

class cardView: UIView {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.7
        // Drawing code
    }
    

}
