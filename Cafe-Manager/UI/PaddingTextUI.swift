//
//  PaddingTextUI.swift
//  FoodCafe
//
//  Created by Lahiru on 2/21/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit

@IBDesignable
class PaddingTextUI: UITextField {

    @IBInspectable var padding:CGFloat = 0.0
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(
            x: bounds.origin.x + padding,
            y: bounds.origin.y + padding,
            width: bounds.size.width - padding * 2,
            height: bounds.size.height - padding * 2
        )
        
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.textRect(forBounds: bounds)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
