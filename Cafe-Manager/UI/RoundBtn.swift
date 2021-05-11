//
//  RoundBtn.swift
//  FoodCafe
//
//  Created by Lahiru on 2/21/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit

@IBDesignable
class RoundBtn: UIButton {
    @IBInspectable var padding: CGFloat=0.0{
        didSet{
            contentEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        }
    }
    override func contentRect(forBounds bounds: CGRect) -> CGRect {
        self.layer.cornerRadius = bounds.size.height / 2
        return bounds
    }

}
