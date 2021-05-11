//
//  Toast.swift
//  FoodCafe
//
//  Created by Lahiru on 3/4/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit

class Toast: UILabel {

    
//     Only override draw() if you perform custom drawing.
//     An empty implementation adversely affects performance during animation.
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)))
        
    }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + 2 * 7,
                      height: size.height + 2 * 7)
    }

}
