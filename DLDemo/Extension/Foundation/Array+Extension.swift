//
//  Array+Extension.swift
//  DLDemo
//
//  Created by Dan.Lee on 2016/10/16.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

import Foundation

extension Array {
    // If count is even, then return the count/2 index value
    func getMiddleElement() -> Element? {
        if self.count == 1 {
            return self[0]
        }
        return !isEmpty ? self[self.count/2] : nil
    }
}
