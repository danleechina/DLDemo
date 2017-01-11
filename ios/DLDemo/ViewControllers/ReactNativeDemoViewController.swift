//
//  ReactNativeDemoViewController.swift
//  DLDemo
//
//  Created by Dan.Lee on 2016/10/31.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

import UIKit
//import React

class ReactNativeDemoViewController: UIViewController {
    
    fileprivate var backToNativeButton: UIButton!
    fileprivate var goToRNButton: UIButton!
    fileprivate var rnView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button1 = UIButton()
        button1.frame = CGRect(x: self.view.frame.width/2 - 100, y: self.view.frame.height/2 - 50, width: 200, height: 100)
        button1.setTitle("Start React Native!", for: .normal)
        button1.setTitleColor(UIColor.blue, for: .normal)
        button1.addTarget(self, action: #selector(gotoReactNativePage), for: .touchUpInside)
        self.view.backgroundColor = UIColor.white
        goToRNButton = button1
        self.view.addSubview(button1)
        
        
        let button = UIButton()
        button.frame = CGRect(x: 5, y: self.view.frame.height/2 - 22, width: 44, height: 44)
        button.backgroundColor = UIColor.purple.withAlphaComponent(0.9)
        button.setTitle("⏎", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(returnBackToNative), for: .touchUpInside)
        backToNativeButton = button
        
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    func gotoReactNativePage(sender: UIButton) {
//        if rnView == nil {
//            let rootView = RCTRootView.init(bridge: (UIApplication.shared.delegate as! AppDelegate).bridge, moduleName: "Clock", initialProperties: [:])
//            rootView?.frame = self.view.bounds
//            rnView = rootView
//        }
//        
//        UIApplication.shared.statusBarStyle = .lightContent
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
//        self.view.addSubview(rnView!)
//        self.view.addSubview(backToNativeButton)
    }
    
    func returnBackToNative() {
//        UIApplication.shared.statusBarStyle = .default
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        rnView!.removeFromSuperview()
//        backToNativeButton.removeFromSuperview()
    }

}
