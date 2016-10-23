//
//  CyclePickerViewController.swift
//  DLDemo
//
//  Created by Dan.Lee on 2016/10/22.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

import UIKit

class CyclePickerViewController: UIViewController {
    private lazy var cyclePickerView:DLPickerView = {
        let cyclePickerView = DLPickerView()
        cyclePickerView.backgroundColor = UIColor.brown
        cyclePickerView.delegate = self
        cyclePickerView.dataSource = self
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

extension CyclePickerViewController: DLPickerViewDataSource, DLPickerViewDelegate {
    // dataSource
    func numberOfComponents(in pickerView: DLPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: DLPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 30
    }
    
    // delegate
    func enableCycleScroll(in pickerView: DLPickerView, forComponent component: Int) -> Bool {
        return true
    }
}
