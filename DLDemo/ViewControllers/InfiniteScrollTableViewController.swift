//
//  InfiniteScrollTableViewController.swift
//  DLDemo
//
//  Created by Dan.Lee on 2016/10/20.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

import UIKit

class InfiniteScrollTableViewController: UIViewController {

//    private 
    override func viewDidLoad() {
        super.viewDidLoad()
        let infiniteScrollView = InfiniteScrollView()
        infiniteScrollView.frame = CGRect(x: 10, y: 100, width: 200, height: 400)
        infiniteScrollView.backgroundColor = UIColor.brown
        
        self.view.addSubview(infiniteScrollView)
        self.view.backgroundColor = UIColor.lightGray
        self.automaticallyAdjustsScrollViewInsets = false
    }

}
