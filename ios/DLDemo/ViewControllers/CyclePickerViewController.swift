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
        //cyclePickerView.backgroundColor = UIColor.brown
        cyclePickerView.delegate = self
        cyclePickerView.dataSource = self
        return cyclePickerView
    }()
    
    fileprivate var enableCyclically = false
    fileprivate var minValueToChoose = 0
    fileprivate var maxValueToChoose = 0
    fileprivate var minLabel: UILabel?
    fileprivate var maxLabel: UILabel?
    fileprivate var magnizeLabel: UILabel?
    fileprivate var magnizeScale = 1.04
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cyclePickerView.frame = CGRect(x: 10, y: 70, width: self.view.frame.width - 20, height: self.view.frame.width - 20)
        //cyclePickerView.enableNightMode = true
        cyclePickerView.reloadAllComponents()
        self.view.addSubview(cyclePickerView)
        self.view.backgroundColor = UIColor.lightGray
        
        let button = UIButton()
        button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        button.setTitle("改变水平布局方式", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.frame = CGRect(x: 0, y: self.view.frame.height - 50, width: 150, height: 55)
        self.view.addSubview(button)
        
        let button1 = UIButton()
        button1.addTarget(self, action: #selector(buttonTapped1(sender:)), for: .touchUpInside)
        button1.setTitle("夜晚模式", for: .normal)
        button1.setTitleColor(UIColor.blue, for: .normal)
        button1.frame = CGRect(x: button.frame.maxX + 3, y: self.view.frame.height - 50, width: 80, height: 55)
        self.view.addSubview(button1)
        
        let button2 = UIButton()
        button2.addTarget(self, action: #selector(buttonTapped2(sender:)), for: .touchUpInside)
        button2.setTitle("循环滚动", for: .normal)
        button2.setTitleColor(UIColor.blue, for: .normal)
        button2.frame = CGRect(x: button1.frame.maxX + 1, y: self.view.frame.height - 50, width: 95, height: 55)
        self.view.addSubview(button2)
        
        let label = UILabel()
        label.frame = CGRect(x: 5, y: button2.frame.minY - 55, width: 170, height: 25)
        label.text = "设置可选最小值: 0"
        self.view.addSubview(label)
        minLabel = label
        
        let stepper = UIStepper()
        stepper.stepValue = 1
        stepper.minimumValue = 0
        stepper.addTarget(self, action: #selector(stepperValueChanged(sender:)), for: .valueChanged)
        stepper.frame = CGRect(x: 215, y: button2.frame.minY - 55, width: 100, height: 25)
        self.view.addSubview(stepper)
        
        let label1 = UILabel()
        label1.frame = CGRect(x: 5, y: button2.frame.minY - 25, width: 170, height: 25)
        label1.text = "设置可选最大值: 0"
        self.view.addSubview(label1)
        maxLabel = label1
        
        let stepper1 = UIStepper()
        stepper1.stepValue = 1
        stepper1.minimumValue = 0
        stepper1.addTarget(self, action: #selector(stepperValueChanged1(sender:)), for: .valueChanged)
        stepper1.frame = CGRect(x: 215, y: button2.frame.minY - 25, width: 100, height: 25)
        self.view.addSubview(stepper1)
        
        let label2 = UILabel()
        label2.frame = CGRect(x: 5, y: label.frame.minY - 30, width: 200, height: 25)
        label2.text = "设置指示器放大比: 1.04"
        self.view.addSubview(label2)
        magnizeLabel = label2
        
        let stepper2 = UIStepper()
        stepper2.stepValue = 0.01
        stepper2.value = magnizeScale
        stepper2.minimumValue = 1
        stepper2.addTarget(self, action: #selector(stepperValueChanged2(sender:)), for: .valueChanged)
        stepper2.frame = CGRect(x: label2.frame.maxX + 10, y: label2.frame.minY, width: 100, height: 25)
        self.view.addSubview(stepper2)
        
        
        /*
         Attention: I still don't know why I should set this so the DLTableView/DLPickerView can work perfectly
         */
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func buttonTapped(sender: UIButton) {
        switch cyclePickerView.layoutStyle {
        case .Vertical:
            cyclePickerView.layoutStyle = .Horizontal
            cyclePickerView.reloadAllComponents()
            sender.setTitle("改成垂直布局方式", for: .normal)
            break
        case .Horizontal:
            cyclePickerView.layoutStyle = .Vertical
            cyclePickerView.reloadAllComponents()
            sender.setTitle("改成水平布局方式", for: .normal)
            break
        }
    }
    
    func buttonTapped1(sender: UIButton) {
        if cyclePickerView.enableNightMode {
            cyclePickerView.enableNightMode = false
            cyclePickerView.reloadAllComponents()
            sender.setTitle("夜晚模式", for: .normal)
        } else {
            cyclePickerView.enableNightMode = true
            cyclePickerView.reloadAllComponents()
            sender.setTitle("白天模式", for: .normal)
        }
    }
    
    func buttonTapped2(sender: UIButton) {
        enableCyclically = !enableCyclically
        if enableCyclically {
            sender.setTitle("非循环滚动", for: .normal)
        } else {
            sender.setTitle("循环滚动", for: .normal)
        }
        
        cyclePickerView.reloadAllComponents()
    }
    
    func stepperValueChanged(sender: UIStepper) {
        minValueToChoose = Int(sender.value)
        if minValueToChoose >= maxValueToChoose {
            minValueToChoose = maxValueToChoose
            sender.value = Double(minValueToChoose)
        }
        minLabel?.text = "设置可选最小值: \(minValueToChoose)"
        cyclePickerView.reloadAllComponents()
    }
    
    func stepperValueChanged1(sender: UIStepper) {
        if maxValueToChoose < minValueToChoose {
            maxValueToChoose = minValueToChoose
            sender.value = Double(maxValueToChoose)
        }
        maxValueToChoose = Int(sender.value)
        maxLabel?.text = "设置可选最大值: \(maxValueToChoose)"
        cyclePickerView.reloadAllComponents()
        
    }
    
    func stepperValueChanged2(sender: UIStepper) {
        magnizeScale = sender.value
        magnizeLabel?.text = "设置指示器放大比: \(magnizeScale)"
        cyclePickerView.magnifyingViewScale = magnizeScale
    }
}

extension CyclePickerViewController: DLPickerViewDataSource, DLPickerViewDelegate {
    // dataSource
    func numberOfComponents(in pickerView: DLPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: DLPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 19
        } else if component == 1 {
            return 10
        }
        return Int.max
    }
    
    // delegate
    func enableCycleScroll(in pickerView: DLPickerView, forComponent component: Int) -> Bool {
        return enableCyclically
    }
    
    func pickerView(_ pickerView: DLPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
    
    
//        func pickerView(_ pickerView: DLPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//    
//        }
//    
//        func pickerView(_ pickerView: DLPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//    
//        }
    
    
    func pickerView(_ pickerView: DLPickerView, widthForComponent component: Int) -> CGFloat {
        return 70
    }
    
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
        print("tap row=\(row) in component=\(component)")
    }
    
    func pickerView(_ pickerView: DLPickerView, enableScrollWithinRangeForComponent component: Int) -> Bool {
        if component == 2 {
            return false
        }
        return true
    }
    
    func pickerView(_ pickerView: DLPickerView, getRangeForScrollInComponent component: Int) -> NSRange {
        
        return NSRange.init(location: minValueToChoose, length: maxValueToChoose - minValueToChoose + 1)
    }
    
   // func pickerView(_ pickerView: DLPickerView, initiallySelectedRowForComponent component: Int) -> Int {
   //     if component == 2 {
   //         return 11
   //     }
   //     return component + 2
   // }
    
    func pickerView(_ pickerView: DLPickerView, scaleValueForCenterIndicatorInComponent component: Int) -> Double {
        return 1.1
    }
    
}

