//
//  DelayFunction.swift
//  Amarosa
//
//  Created by Sean Perez on 4/2/17.
//  Copyright © 2017 SeanPerez. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func delay(_ seconds: Double, completion: @escaping ()->Void) {
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime, execute: completion)
    }
}
