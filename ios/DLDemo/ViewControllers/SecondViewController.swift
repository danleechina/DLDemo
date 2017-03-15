//
//  SecondViewController.swift
//  DLDemo
//
//  Created by Dan.Lee on 2017/8/19.
//  Copyright © 2017年 Dan Lee. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    @IBOutlet weak var sliderView: SliderView!
    @IBOutlet weak var loopLabel: UILabel!
    @IBOutlet weak var loopSwitch: UISwitch!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var directionSwitch: UISwitch!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var numberStepper: UIStepper!

    override func viewDidLoad() {
        super.viewDidLoad()
        initSliderView(numberOfViews: Int(numberStepper.value))
    }
    
    func initSliderView(numberOfViews: Int) {
        var views = [UIView]()
        if numberOfViews < 1 {
            sliderView.viewsToShow = []
            return
        }
        for index in 1...numberOfViews {
            let tview = SecondDemoView()
            tview.label.text = "index=\(index * 2 - 1)"
            tview.llabel.text = "\(index * 2 - 1)"
            tview.rlabel.text = "\(index * 2 - 1)"
            tview.ltView.backgroundColor = UIColor.randomColor()
            tview.lbView.backgroundColor = UIColor.randomColor()
            tview.rtView.backgroundColor = UIColor.randomColor()
            tview.rbView.backgroundColor = UIColor.randomColor()
            tview.backgroundColor = UIColor.randomColor()
            
            let sView =  SecondDemoTwoView()
            sView.ltView.backgroundColor = UIColor.randomColor()
            sView.lbView.backgroundColor = UIColor.randomColor()
            sView.rtView.backgroundColor = UIColor.randomColor()
            sView.rbView.backgroundColor = UIColor.randomColor()
            sView.lLabel.text = "\(index * 2)"
            sView.tLabel.text = "\(index * 2)"
            sView.rLabel.text = "\(index * 2)"
            sView.bLabel.text = "\(index * 2)"
            
            views.append(tview)
            views.append(sView)
        }
        sliderView.viewsToShow = views
    }
    
    @IBAction func loopSwitchAction(_ sender: Any) {
        sliderView.circleSlide = loopSwitch.isOn
    }
    
    @IBAction func directionSwitchAction(_ sender: Any) {
        sliderView.slideDirection = directionSwitch.isOn ? .Horizontal : .Vertical
    }
    
    @IBAction func stepperAction(_ sender: Any) {
        let value = Int(numberStepper.value)
        initSliderView(numberOfViews: value)
        numberLabel.text = "滚动视图数目：\(value * 2)"
    }
}
