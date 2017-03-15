//
//  HomeTableViewController.swift
//  DLDemo
//
//  Created by Dan.Lee on 2016/10/16.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {

    private let titles: Array<String> = ["可配置滚动图片",
                                         "可配置方向的无限循环滚动 ScrollView",
                                         "配置方向、无限循环滚动 TableView",
                                         "配置方向、无限循环滚动 PickerView",
                                         "React Native Demo",
                                         "使用自定义cell PickerView",
                                         "Generator，可控制函数执行，优化异步回调",
                                         "Grid CollectionView layout,",
                                         "SliderViewController,",
                                         "可配置滚动 view(区别于图片)", ]
    private let detailTexts: Array<String> = ["无",
                                              "无",
                                              "无",
                                              "无",
                                              "无",
                                              "无",
                                              "无",
                                              "无",
                                              "无",
                                              "无",]
    private let viewControllers: Array<String> = [ "FirstViewController",
                                                   "InfiniteScrollViewController",
                                                   "CycleTableViewController",
                                                   "CyclePickerViewController",
                                                   "ReactNativeDemoViewController",
                                                   "CyclePicker1ViewController",
                                                   "ThunkAndGeneratorViewController",
                                                   "FilterSongSheetViewController",
                                                   "SliderViewController",
                                                   "SecondViewController",]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        //func Thunk(_ method: ((String, String) -> String)) -> ((String) -> String) {
        //    func function() -> (Any -> Any) {
        //    }
        //    return function
        //}
        //let thunk = Thunk(printHelloFunc)
        //thunk("Lizhengda")("ChenWeiFang")
        
        //func Thunk(_ met: @escaping (String) -> String) -> (String) -> String {
        //    func internalFunc(_ name: String) -> String{
        //        return met(name)
        //    }
        //    return internalFunc
        //}
        //let thunk = Thunk(printHello)
        //let result = thunk("Li Zhengda")
        //print("This is result =[\(result)]")
        
        
        //func Thunk(_ met: @escaping (String, String) -> String) -> (String) -> ((String) -> String) {
        //    func internalFunc(_ name1: String) -> (String) -> String {
        //        func iiFunc(_ name2: String) -> String {
        //            return met(name1, name2)
        //        }
        //        return iiFunc
        //    }
        //    return internalFunc
        //}
        //let thunk = Thunk(printHelloFunc)
        //let result = thunk("Li Zhengda")("ChenWeiFang")
        //print("This is result =[\(result)]")
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        cell.textLabel?.text = "\(indexPath.row + 1). \(titles[indexPath.row])"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.detailTextLabel?.text = detailTexts[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var vc = UIViewController()
        if indexPath.row == 0 {
            vc = FirstViewController()
        } else if indexPath.row == 1 {
            vc = InfiniteScrollViewController()
        } else if indexPath.row == 2 {
            vc = CycleTableViewController()
        } else if indexPath.row == 3 {
            vc = CyclePickerViewController()
        } else if indexPath.row == 4 {
            vc = ReactNativeDemoViewController()
        } else if indexPath.row == 5 {
            vc = CyclePicker1ViewController()
        } else if indexPath.row == 6 {
            
            // TODO: many things not right.
            vc = ThunkAndGeneratorViewController()
        } else if indexPath.row == 7 {
            vc = FilterSongSheetViewController()
        } else if indexPath.row == 8 {
            let sliderVC = SliderViewController()
            let subVC1 = EmptyViewController()
            let subVC2 = EmptyViewController()
            let subVC3 = EmptyViewController()
            let subVC4 = EmptyViewController()
            subVC1.view.backgroundColor = UIColor.red
            subVC2.view.backgroundColor = UIColor.blue
            subVC3.view.backgroundColor = UIColor.purple
            subVC4.view.backgroundColor = UIColor.brown
            sliderVC.contentViewControllers = [subVC1, subVC2, subVC3, subVC4]
            sliderVC.titleTexts = ["1111", "2222", "3333", "4444"]
            sliderVC.currentIndex = 3
            
            vc = sliderVC
        } else if indexPath.row == 9 {
            vc = SecondViewController()
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
