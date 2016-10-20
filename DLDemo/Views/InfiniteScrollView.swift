//
//  InfiniteCycleTableView.swift
//  DLDemo
//
//  Created by Dan.Lee on 2016/10/20.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

import UIKit

class InfiniteScrollView: UIScrollView {
    fileprivate var visibileCellsInVertical = Array<UIView>()
    fileprivate var visibileCellsInHorizontal = Array<UIView>()
    fileprivate var reuseCellsInVerticalSet = Set<UIView>()
    fileprivate var reuseCellsInHorizontalSet = Set<UIView>()
    fileprivate var containerView = UIView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        recenterInVerticalIfNecessary()
        recenterInHorizontalIfNecessary()
        let visibleBounds = convert(bounds, to: containerView)
//        tileCellsInVertical(fromMinY: visibleBounds.minY, toMaxY: visibleBounds.maxY)
        tileCellsInHorizontal(fromMinX: visibleBounds.minX, toMaxX: visibleBounds.maxX)
    }
    
    func recenterInVerticalIfNecessary() {
        let currentOffset = contentOffset
        let contentHeight = contentSize.height
        let centerOffsetY = (contentHeight - bounds.height) / 2
        let distanceFromCenter = fabs(currentOffset.y - centerOffsetY)
        
        if distanceFromCenter > (contentHeight / 4) {
            contentOffset = CGPoint(x: currentOffset.x, y: centerOffsetY)
            for cell in visibileCellsInVertical {
                var center = containerView.convert(cell.center, to: self)
                center.y += (centerOffsetY - currentOffset.y)
                cell.center = convert(center, to: containerView)
            }
        }
    }
    
    func recenterInHorizontalIfNecessary() {
        let currentOffset = contentOffset
        let contentWidth = contentSize.width
        let centerOffsetX = (contentWidth - bounds.width) / 2
        let distanceFromCenter = fabs(currentOffset.x - centerOffsetX)
        
        if distanceFromCenter > (contentWidth / 4) {
            contentOffset = CGPoint(x: centerOffsetX, y: currentOffset.y)
            for cell in visibileCellsInHorizontal {
                var center = containerView.convert(cell.center, to: self)
                center.x += (centerOffsetX - currentOffset.x)
                cell.center = convert(center, to: containerView)
            }
        }
    }
    
    func tileCellsInVertical(fromMinY minY: CGFloat, toMaxY maxY: CGFloat) {
        if visibileCellsInVertical.isEmpty {
            _ = placeNewCellOnBottom(bottomEdge: minY)
        }
        
        var lastCell = visibileCellsInVertical.last!
        var bottomEdge = lastCell.frame.maxY
        while bottomEdge < maxY {
            bottomEdge = placeNewCellOnBottom(bottomEdge: bottomEdge)
        }
        
        var headCell = visibileCellsInVertical.first!
        var topEdge = headCell.frame.minY
        while topEdge > minY {
            topEdge = placeNewCellOnTop(topEdge: topEdge)
        }
        
        lastCell = visibileCellsInVertical.last!
        while lastCell.frame.origin.y > maxY {
            lastCell.removeFromSuperview()
            reuseCellsInVerticalSet.insert(visibileCellsInVertical.removeLast())
            if visibileCellsInVertical.isEmpty {
                break
            }
            lastCell = visibileCellsInVertical.last!
        }
        
        if visibileCellsInVertical.isEmpty {
            return
        }
        
        headCell = visibileCellsInVertical.first!
        while headCell.frame.maxY < minY {
            headCell.removeFromSuperview()
            reuseCellsInVerticalSet.insert(visibileCellsInVertical.removeFirst())
            if visibileCellsInVertical.isEmpty {
                break
            }
            headCell = visibileCellsInVertical.first!
        }
    }
    
    func tileCellsInHorizontal(fromMinX minX: CGFloat, toMaxX maxX: CGFloat) {
        if visibileCellsInHorizontal.isEmpty {
            _ = placeNewCellOnRight(rightEdge: minX)
        }
        
        var lastCell = visibileCellsInHorizontal.last!
        var rightEdge = lastCell.frame.maxX
        while rightEdge < maxX {
            rightEdge = placeNewCellOnRight(rightEdge: rightEdge)
        }
        
        var headCell = visibileCellsInHorizontal.first!
        var leftEdge = headCell.frame.minX
        while leftEdge > minX {
            leftEdge = placeNewCellOnLeft(leftEdge: leftEdge)
        }
        
        lastCell = visibileCellsInHorizontal.last!
        while lastCell.frame.origin.x > maxX {
            lastCell.removeFromSuperview()
            reuseCellsInHorizontalSet.insert(visibileCellsInHorizontal.removeLast())
            if visibileCellsInHorizontal.isEmpty {
                break
            }
            lastCell = visibileCellsInHorizontal.last!
        }
        
        if visibileCellsInHorizontal.isEmpty {
            return
        }
        
        headCell = visibileCellsInHorizontal.first!
        while headCell.frame.maxX < minX {
            headCell.removeFromSuperview()
            reuseCellsInHorizontalSet.insert(visibileCellsInHorizontal.removeFirst())
            if visibileCellsInHorizontal.isEmpty {
                break
            }
            headCell = visibileCellsInHorizontal.first!
        }
    }
    
    func placeNewCellOnBottom(bottomEdge: CGFloat) -> CGFloat {
        let view = insertCellInVertical()
        visibileCellsInVertical.append(view)
        
        var frame = view.frame
        frame.origin.y = bottomEdge
        frame.origin.x = 0
        view.frame = frame
        
        return frame.maxY
    }
    
    func placeNewCellOnRight(rightEdge: CGFloat) -> CGFloat {
        let view = insertCellInHorizontal()
        visibileCellsInHorizontal.append(view)
        
        var frame = view.frame
        frame.origin.y = 0
        frame.origin.x = rightEdge
        view.frame = frame
        
        return frame.maxX
    }
    
    func placeNewCellOnTop(topEdge: CGFloat) -> CGFloat {
        let view = insertCellInVertical()
        visibileCellsInVertical.insert(view, at: 0)
        
        var frame = view.frame
        frame.origin.y = topEdge - frame.height
        frame.origin.x = 0
        view.frame = frame
        
        return frame.minY
    }
    
    func placeNewCellOnLeft(leftEdge: CGFloat) -> CGFloat {
        let view = insertCellInHorizontal()
        visibileCellsInHorizontal.insert(view, at: 0)
        
        var frame = view.frame
        frame.origin.y = 0
        frame.origin.x = leftEdge - frame.width
        view.frame = frame
        
        return frame.minX
    }
    
    func insertCellInVertical() -> UIView {
        var view = UIView()
        if reuseCellsInVerticalSet.isEmpty {
            let label = UILabel()
            label.numberOfLines = 3
            label.text = "1024 Block Street\nShaffer, CA\n95014"
            label.textColor = UIColor.blue
            label.frame = CGRect(x: 0, y: 0, width: 50, height: 100)
            view.addSubview(label)
            view.backgroundColor = UIColor.black
        } else {
            view = reuseCellsInVerticalSet.removeFirst()
        }
        view.frame = CGRect(x: 0, y: 0, width: 60, height: 100)
        containerView.addSubview(view)
        return view
    }
    
    func insertCellInHorizontal() -> UIView {
        var view = UIView()
        if reuseCellsInHorizontalSet.isEmpty {
            let label = UILabel()
            label.numberOfLines = 3
            label.text = "1024 Block Street\nShaffer, CA\n95014"
            label.textColor = UIColor.blue
            label.frame = CGRect(x: 0, y: 0, width: 50, height: 110)
            view.addSubview(label)
            view.backgroundColor = UIColor.black
        } else {
            view = reuseCellsInHorizontalSet.removeFirst()
        }
        view.frame = CGRect(x: 0, y: 0, width: 60, height: 110)
        containerView.addSubview(view)
        return view
    }
    
    override var frame: CGRect {
        didSet {
            contentSize = CGSize(width: self.frame.width * 5000, height: self.frame.height)
            containerView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
