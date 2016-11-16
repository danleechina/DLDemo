//
//  Generator.swift
//  DLDemo
//
//  Created by Dan.Lee on 2016/11/16.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

import Foundation

// Generates values from a closure that invokes a "yield" function
class YieldGenerator<T>: IteratorProtocol {
    fileprivate var yieldedValues = Array<T>()
    fileprivate var index = 0
    
    fileprivate func yield(value: T) {
        yieldedValues.append(value)
    }
    
    init(_ yielder: ((T) -> ()) -> ()) {
        yielder(yield)
    }
    
    func next() -> T? {
        defer { index += 1}
        return index < yieldedValues.count ? yieldedValues[index] : nil
    }
    
    func sequence() -> AnySequence<T> {
        return AnySequence({self})
    }
    
    
    class func run(_ gen: YieldGenerator<T>) {
        func next(err: Error?, data: T?) {
            if let result = gen.next() {
                next(err: nil, data: result)
            } else {
                return
            }
        }
        
        next(err: nil, data: nil)
    }
}

// Background task used by LazyYieldGenerator
class LazyYieldTask<T> {
    fileprivate let yielder: ((T) -> ()) -> (Bool)
    fileprivate let valueDesired: DispatchSemaphore
    fileprivate let valueAvailable: DispatchSemaphore
    fileprivate var finished: Bool?
    
    fileprivate var lastYieldedValue:T?
    fileprivate var isBackgroundTaskRunning = false
    fileprivate var isComplete = false
    
    typealias VD = (value: T?, done: Bool)
    init(_ yielder: @escaping ((T) -> ()) -> (Bool)) {
        self.yielder = yielder
        valueDesired = DispatchSemaphore.init(value: 0)
        valueAvailable = DispatchSemaphore.init(value: 0)
    }
    
    // Called from background thread to yield a value to be returned by next()
    fileprivate func yield(value: T) {
        _ = valueDesired.wait(timeout: .distantFuture)
        lastYieldedValue = value
        valueAvailable.signal()
    }
    
    // Called from generator thread to get next yielded value
    fileprivate func next() -> T? {
        if !isBackgroundTaskRunning {
            DispatchQueue.global(qos: .default).async {
                self.finished = self.yielder(self.yield)
            }
            isBackgroundTaskRunning = true
        }
        
        valueDesired.signal()
        _ = valueAvailable.wait(timeout: .distantFuture)
        
        let value: T? = lastYieldedValue
        lastYieldedValue = nil
        return value
    }
    
}

// Generates values from a closure that invokes a "yield" function.
//
// The yielder closure is executed on another thread, and each call to yield()
// will block until next() is called by the generator's thread.
struct LazyYieldGenerator<T>: IteratorProtocol {
    fileprivate var task: LazyYieldTask<T>?
    fileprivate let yielder: ((T) -> ()) -> (Bool)
    
    typealias VD = (value: T?, done: Bool)
    init(_ yielder: @escaping ((T) -> ()) -> (Bool)) {
        self.yielder = yielder
    }
    
    mutating func next() -> T? {
        if !(task != nil) {
            task = LazyYieldTask(yielder)
        }
        if task!.finished == true {
            return nil
        }
        return task!.next()
    }
    
    func sequence() -> AnySequence<T> {
        return AnySequence({self})
    }
    
    static func run(_ gen: LazyYieldGenerator<T>) {
        var gg = gen
        func next(err: Error?, data: T?) {
            if let result = gg.next() {
                print("\(result) aaa")
                next(err: nil, data: result)
            } else {
                return
            }
        }
        
        next(err: nil, data: nil)
    }
}


// Create a sequence from a closure that invokes a "yield" function
func sequence<T>(_ yielder: @escaping ((T) -> ()) -> ()) -> AnySequence<T> {
    return YieldGenerator(yielder).sequence()
}

// Create a sequence from a closure that invokes a "yield" function.
//
// The closure is executed on another thread, and each call to yield()
// will block until next() is called by the generator's thread.
func lazySequence<T>(_ yielder: @escaping ((T) -> ()) -> (Bool)) -> AnySequence<T> {
    return LazyYieldGenerator(yielder).sequence()
}

