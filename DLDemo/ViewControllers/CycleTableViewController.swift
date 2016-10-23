//
//  DLTableViewController.swift
//  DLDemo
//
//  Created by Dan.Lee on 2016/10/22.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

import UIKit

class CycleTableViewController: UIViewController {

    
    private lazy var tableView:DLTableView = {
        let tableView = DLTableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.brown
        tableView.frame = CGRect(x: 10, y: 100, width: self.view.frame.width - 20, height: self.view.frame.height - 150)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(tableView)
        self.view.backgroundColor = UIColor.lightGray
        
        let button = UIButton()
        button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        button.setTitle("改成循环滚动", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.frame = CGRect(x: self.view.frame.width/2 - 100, y: self.view.frame.height - 50, width: 200, height: 55)
        self.view.addSubview(button)
        /*
         Attention: I still don't know why I should set this so the DLTableView can work perfectly
         */
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func buttonTapped(sender: UIButton) {
        tableView.enableCycleScroll = !tableView.enableCycleScroll
        if tableView.enableCycleScroll {
            sender.setTitle("改成非循环滚动", for: .normal)
        } else {
            sender.setTitle("改成循环滚动", for: .normal)
        }
    }
}

extension CycleTableViewController: DLTableViewDelegate, DLTableViewDataSource {
    // dataSource
    func tableView(_ tableView: DLTableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: DLTableView, cellForRowAt indexPath: IndexPath) -> DLTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelloCell")
        cell.titleLabel.text = "This is the \(indexPath.row)th"
        return cell
    }
    
    // delegate
    
    func tableView(_ tableView: DLTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}
