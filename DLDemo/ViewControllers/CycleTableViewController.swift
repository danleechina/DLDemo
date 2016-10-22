//
//  CycleTableViewController.swift
//  DLDemo
//
//  Created by Dan.Lee on 2016/10/22.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

import UIKit

class CycleTableViewController: UIViewController {

    
//    private let cycleTableView:CycleTableView = {
//        return cycleTableView
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cycleTableView = CycleTableView()
        cycleTableView.delegate = self
        cycleTableView.dataSource = self
        cycleTableView.backgroundColor = UIColor.brown
        cycleTableView.frame = CGRect(x: 10, y: 100, width: self.view.frame.width - 20, height: self.view.frame.height - 150)
        
        
        self.view.addSubview(cycleTableView)
        self.view.backgroundColor = UIColor.lightGray
        //        let button = UIButton()
    }
}

extension CycleTableViewController: CycleTableViewDelegate, CycleTableViewDataSource {
    // dataSource
    func tableView(_ tableView: CycleTableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: CycleTableView, cellForRowAt indexPath: IndexPath) -> CycleTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelloCell")
        cell.titleLabel.text = "This is the \(indexPath.row)th"
        return cell
    }
    
    // delegate
    
    func tableView(_ tableView: CycleTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}
