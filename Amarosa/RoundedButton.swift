//
//  RoundedButton.swift
//  Amarosa
//
//  Created by Sean Perez on 6/10/17.
//  Copyright © 2017 SeanPerez. All rights reserved.
//

import UIKit

@IBDesignable

class RoundedButton: UIButton{
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            if cornerRadius > 0 {
                layer.cornerRadius = cornerRadius
                layer.masksToBounds = cornerRadius > 0
            } else {
                layer.cornerRadius = frame.width / 2
                layer.masksToBounds = cornerRadius >= 0
            }
        }
    }
}

