//
//  UIPaddingLabel.swift
//  FoodCafe
//
//  Created by Lahiru on 2/25/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit

@IBDesignable
class UIPaddingLabel: UILabel {
    @IBInspectable var padding:CGFloat = 0.0
    override func drawText(in rect: CGRect) {
        let paddingInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        super.drawText(in: rect.inset(by: paddingInset))
    }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + 2 * padding,
                      height: size.height + 2 * padding)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
