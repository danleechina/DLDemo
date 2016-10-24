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
        tableView.tableViewDelegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.brown
        tableView.frame = CGRect(x: 10, y: 100, width: self.view.frame.width - 20, height: self.view.frame.height - 150)
        return tableView
    }()
    
    var positionScroll = DLTableViewScrollPosition.bottom
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(tableView)
        self.view.backgroundColor = UIColor.lightGray
        
        let button = UIButton()
        button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        button.setTitle("循环滚动", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.frame = CGRect(x: 10, y: self.view.frame.height - 50, width: 100, height: 55)
        self.view.addSubview(button)
        
        let button1 = UIButton()
        button1.addTarget(self, action: #selector(button1Tapped(sender:)), for: .touchUpInside)
        button1.setTitle("水平滚动", for: .normal)
        button1.setTitleColor(UIColor.blue, for: .normal)
        button1.frame = CGRect(x: button.frame.maxX + 5, y: self.view.frame.height - 50, width: 100, height: 55)
        self.view.addSubview(button1)
        
        let button2 = UIButton()
        button2.addTarget(self, action: #selector(button2Tapped(sender:)), for: .touchUpInside)
        button2.setTitle("滚动效果", for: .normal)
        button2.setTitleColor(UIColor.blue, for: .normal)
        button2.frame = CGRect(x: button1.frame.maxX + 5, y: self.view.frame.height - 50, width: 100, height: 55)
        self.view.addSubview(button2)
        
        /*
         Attention: I still don't know why I should set this so the DLTableView can work perfectly
         */
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func buttonTapped(sender: UIButton) {
        tableView.enableCycleScroll = !tableView.enableCycleScroll
        if tableView.enableCycleScroll {
            sender.setTitle("非循环滚动", for: .normal)
        } else {
            sender.setTitle("循环滚动", for: .normal)
        }
    }
    
    func button1Tapped(sender: UIButton) {
        if tableView.scrollDirection == .Vertical {
            tableView.scrollDirection = .Horizontal
            sender.setTitle("垂直滚动", for: .normal)
        } else {
            tableView.scrollDirection = .Vertical
            sender.setTitle("水平滚动", for: .normal)
        }
    }
    
    func button2Tapped(sender: UIButton) {
        if positionScroll == .bottom {
            sender.setTitle("滚动到中", for: .normal)
            positionScroll = .middle
        } else if positionScroll == .middle {
            sender.setTitle("滚动到顶", for: .normal)
            positionScroll = .top
        } else if positionScroll == .top {
            sender.setTitle("滚动到底", for: .normal)
            positionScroll = .bottom
        }
    }
}

extension CycleTableViewController: DLTableViewDelegate, DLTableViewDataSource {
    // dataSource
    func tableView(_ tableView: DLTableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: DLTableView, cellForRowAt indexPath: IndexPath) -> DLTableViewCell? {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HelloCell") {
            cell.titleLabel.text = "This is the \(indexPath.row)th"
            return cell
        } else {
            let cell = DLTableViewCell.init(style: .Default, reuseIdentifier: "HelloCell")
            cell.titleLabel.text = "This is the \(indexPath.row)th"
            return cell
        }
    }
    
    // delegate
    // if scroll direction is vertical, heightForRowAt gets called
    // otherwise widthForRowAt gets called.
    // but both of these two functions are not required
    
    func tableView(_ tableView: DLTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: DLTableView, widthForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: DLTableView, didSelectRowAt indexPath: IndexPath) {
        print("tableView tap at = \(indexPath)")
        tableView.scrollToRow(at: indexPath, at: positionScroll, animated: true)
    }
}
