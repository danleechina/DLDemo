//
//  CyclePickerViewController.swift
//  DLDemo
//
//  Created by Dan.Lee on 2016/10/22.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

import UIKit

class CyclePickerViewController: UIViewController {
    private let cyclePickerView:CyclePickerView = {
        let cyclePickerView = CyclePickerView()
        cyclePickerView.backgroundColor = UIColor.brown
        return cyclePickerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cyclePickerView.frame = CGRect(x: 10, y: 100, width: self.view.frame.width - 20, height: self.view.frame.height - 150)
        self.view.addSubview(cyclePickerView)
        self.view.backgroundColor = UIColor.lightGray        
//        let button = UIButton()
    }
}
