//
//  ThunkAndGeneratorViewController.swift
//  DLDemo
//
//  Created by Dan.Lee on 2016/11/16.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

import UIKit

class ThunkAndGeneratorViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
        
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
        let a = LazyYieldGenerator<Int> { (yield) in
            var a = 0, b = 1
            for _ in 0 ..< 20 {
                yield(b)
                let sum = a + b
                a = b
                b = sum
            }
            return true
        }
        
        DispatchQueue.global(qos: .default).async {
            LazyYieldGenerator.run(a)
        }
    }
    
    func printCommoFunc(_ name1: Any, _ name2: Any) -> Any {
        return "Hi " + (name1 as! String) + ", " + (name2 as! String)
    }
    
    func printHelloFunc(_ name1: String, _ name2: String) -> String {
        return "Hi " + name1 + ", " + name2
    }
    
    func printHello(_ name: String) -> String {
        return "Hi " + name
    }
}
