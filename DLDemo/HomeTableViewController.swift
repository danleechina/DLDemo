//
//  HomeTableViewController.swift
//  DLDemo
//
//  Created by Dan.Lee on 2016/10/16.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {

    private let titles: Array<String> = ["滚动图片", "无限循环滚动 TableView"]
    private let detailTexts: Array<String> = ["无", "无"]
    private let viewControllers: Array<String> = [ "FirstViewController", "InfiniteScrollTableViewController"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        cell.textLabel?.text = titles[indexPath.row]
        cell.detailTextLabel?.text = detailTexts[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var vc = UIViewController()
        if indexPath.row == 0 {
            vc = FirstViewController()
        } else if indexPath.row == 1 {
            vc = InfiniteScrollTableViewController()
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
