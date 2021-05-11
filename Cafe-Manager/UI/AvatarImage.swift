//
//  AvatarImage.swift
//  FoodCafe
//
//  Created by Lahiru on 2/23/21.
//  Copyright © 2021 Lahiru. All rights reserved.
//

import UIKit
@IBDesignable
class AvatarImage: UIView {
    @IBInspectable var roundBorder:Bool = true{
        didSet{
            if(roundBorder){
                layer.cornerRadius = frame.height / 2
            }
            
        }
    }
}
