//
//  InfiniteScrollViewController.swift
//  DLDemo
//
//  Created by Dan.Lee on 2016/10/20.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

import UIKit

class InfiniteScrollViewController: UIViewController {

    private let infiniteScrollView:InfiniteScrollView = {
        let infiniteScrollView = InfiniteScrollView()
        infiniteScrollView.backgroundColor = UIColor.brown
        return infiniteScrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infiniteScrollView.frame = CGRect(x: 10, y: 100, width: self.view.frame.width - 20, height: self.view.frame.height - 150)
        self.view.addSubview(infiniteScrollView)
        self.view.backgroundColor = UIColor.lightGray
        self.automaticallyAdjustsScrollViewInsets = false
        
        let button = UIButton()
        button.setTitle("改变滚动方向", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        button.frame = CGRect(x: view.frame.width/2 - 100, y: view.frame.height - 44, width: 200, height: 50)
        self.view.addSubview(button)
    }
    
    func buttonTapped(sender: UIButton) {
        switch infiniteScrollView.infiniteDirection {
        case .Horizontal:
            infiniteScrollView.infiniteDirection = .Vertical
            sender.setTitle("改成水平无限滚动", for: .normal)
            break
        case .Vertical:
            infiniteScrollView.infiniteDirection = .Horizontal
            sender.setTitle("改成垂直无限滚动", for: .normal)
            break
        }
    }

}
