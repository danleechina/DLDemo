//
//  UIColor+Extension.swift
//  DLDemo
//
//  Created by Dan.Lee on 2016/10/24.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

import UIKit

extension UIColor {
    class func randomColor() -> UIColor {
        return UIColor.init(red: randomBetweenNumbers(firstNum: 0, secondNum: 1),
                            green: randomBetweenNumbers(firstNum: 0, secondNum: 1),
                            blue: randomBetweenNumbers(firstNum: 0, secondNum: 1),
                            alpha: 1)
    }
    
    class func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
}
