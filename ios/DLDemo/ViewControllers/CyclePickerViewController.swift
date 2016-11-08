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
        
        cyclePickerView.frame = CGRect(x: 10, y: 100, width: self.view.frame.width - 20, height: self.view.frame.width - 20)
        cyclePickerView.reloadAllComponents()
        self.view.addSubview(cyclePickerView)
        self.view.backgroundColor = UIColor.lightGray
        
        let button = UIButton()
        button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        button.setTitle("改变布局方式", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.frame = CGRect(x: 10, y: self.view.frame.height - 50, width: 150, height: 55)
        self.view.addSubview(button)
        /*
         Attention: I still don't know why I should set this so the DLTableView can work perfectly
         */
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func buttonTapped(sender: UIButton) {
        switch cyclePickerView.layoutStyle {
        case .Vertical:
            cyclePickerView.layoutStyle = .Horizontal
            sender.setTitle("改成垂直布局方式", for: .normal)
            break
        case .Horizontal:
            cyclePickerView.layoutStyle = .Vertical
            sender.setTitle("改成水平布局方式", for: .normal)
            break
        }
    }
}

extension CyclePickerViewController: DLPickerViewDataSource, DLPickerViewDelegate {
    // dataSource
    func numberOfComponents(in pickerView: DLPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: DLPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 11
        } else if component == 1 {
            return 4
        }
        return 20
    }
    
    // delegate
    func enableCycleScroll(in pickerView: DLPickerView, forComponent component: Int) -> Bool {
        if component == 0 {
            return false
        }
        return true
    }
    
    func pickerView(_ pickerView: DLPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row+1)"
    }
    
//        func pickerView(_ pickerView: DLPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//    
//        }
//    
//        func pickerView(_ pickerView: DLPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//    
//        }
    
//    func pickerView(_ pickerView: DLPickerView, widthForComponent component: Int) -> CGFloat {
//        if component == 0 {
//            return 100
//        } else if component == 1 {
//            return 80
//        } else if component == 2 {
//            return 120
//        } else  {
//            return 0
//        }
//    }
    
//    func pickerView(_ pickerView: DLPickerView, rowHeightForRow row: Int, inComponent component: Int) -> CGFloat {
//        
//        if row == 2 && component == 0 {
//            return 150
//        }
//        if row == 2 && component == 1 {
//            return 10
//        }
//        return 64
//    }
    
    func pickerView(_ pickerView: DLPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("tap row=\(row+1) in component=\(component+1)")
    }
    
    func pickerView(_ pickerView: DLPickerView, enableScrollWithinRangeForComponent component: Int) -> Bool {
        if component == 2 {
            return true
        }
        return false
    }
    
    func pickerView(_ pickerView: DLPickerView, getRangeForScrollInComponent component: Int) -> NSRange {
        if component == 2 {
            return NSRange.init(location: 2, length: 5)
        }
        return NSRange.init()
    }
    
}
