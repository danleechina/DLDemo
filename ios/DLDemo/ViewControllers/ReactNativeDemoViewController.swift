//
//  ReactNativeDemoViewController.swift
//  DLDemo
//
//  Created by Dan.Lee on 2016/10/31.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

import UIKit
import React

class ReactNativeDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button1 = UIButton()
        button1.frame = CGRect(x: self.view.frame.width/2 - 100, y: self.view.frame.height/2 - 50, width: 200, height: 100)
        button1.setTitle("Start React Native!", for: .normal)
        button1.setTitleColor(UIColor.blue, for: .normal)
        button1.addTarget(self, action: #selector(gotoReactNativePage), for: .touchUpInside)
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(button1)
    }
    
    func gotoReactNativePage(sender: UIButton) {
        let jsCodeLocation = URL.init(string: "http://localhost:8081/index.ios.bundle?platform=ios")
        let rootView = RCTRootView(
            bundleURL: jsCodeLocation,
            moduleName: "Clock",
            initialProperties: nil,
            launchOptions: nil
        )
        let vc = UIViewController()
        vc.view = rootView
        self.present(vc, animated: true, completion: nil)
    }

}
