//
//  InfiniteCycleTableView.swift
//  DLDemo
//
//  Created by Dan.Lee on 2016/10/20.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

import UIKit

class InfiniteScrollView: UIScrollView {
    fileprivate var visibileCells = Array<UIView>()
    fileprivate var reuseCellsSet = Set<UIView>()
    fileprivate var containerView = UIView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        recenterInVerticalIfNecessary()
        let visibleBounds = convert(bounds, to: containerView)
        tileCellsInVertical(fromMinY: visibleBounds.minY, toMaxY: visibleBounds.maxY)
    }
    
    func recenterInVerticalIfNecessary() {
        let currentOffset = contentOffset
        let contentHeight = contentSize.height
        let centerOffsetY = (contentHeight - bounds.height) / 2
        let distanceFromCenter = fabs(currentOffset.y - centerOffsetY)
        
        if distanceFromCenter > (contentHeight / 4) {
            contentOffset = CGPoint(x: currentOffset.x, y: centerOffsetY)
            for cell in visibileCells {
                var center = containerView.convert(cell.center, to: self)
                center.y += (centerOffsetY - currentOffset.y)
                cell.center = convert(center, to: containerView)
            }
        }
    }
    
    func tileCellsInVertical(fromMinY minY: CGFloat, toMaxY maxY: CGFloat) {
        if visibileCells.isEmpty {
            _ = placeNewCellOnTop(topEdge: minY)
        }
        
        var lastCell = visibileCells.last!
        var bottomEdge = lastCell.frame.maxY
        while bottomEdge < maxY {
            bottomEdge = placeNewCellOnBottom(bottomEdge: bottomEdge)
        }
        
        var headCell = visibileCells.first!
        var topEdge = headCell.frame.minY
        while topEdge > minY {
            topEdge = placeNewCellOnTop(topEdge: topEdge)
        }
        
        lastCell = visibileCells.last!
        while lastCell.frame.origin.y > maxY {
            lastCell.removeFromSuperview()
            reuseCellsSet.insert(visibileCells.removeLast())
            if visibileCells.isEmpty {
                break
            }
            lastCell = visibileCells.last!
        }
        
        if visibileCells.isEmpty {
            return
        }
        
        headCell = visibileCells.first!
        while headCell.frame.maxY < minY {
            headCell.removeFromSuperview()
            reuseCellsSet.insert(visibileCells.removeFirst())
            if visibileCells.isEmpty {
                break
            }
            headCell = visibileCells.first!
        }
    }
    
    func placeNewCellOnBottom(bottomEdge: CGFloat) -> CGFloat {
        let view = insertInVerticalCell()
        visibileCells.append(view)
        
        var frame = view.frame
        frame.origin.y = bottomEdge
        frame.origin.x = 0
        view.frame = frame
        
        return frame.maxY
    }
    
    func placeNewCellOnTop(topEdge: CGFloat) -> CGFloat {
        let view = insertInVerticalCell()
        visibileCells.insert(view, at: 0)
        
        var frame = view.frame
        frame.origin.y = topEdge - frame.height
        frame.origin.x = 0
        view.frame = frame
        
        return frame.minY
    }
    
    func insertInVerticalCell() -> UIView {
        var view = UIView()
        if reuseCellsSet.isEmpty {
            let label = UILabel()
            label.numberOfLines = 3
            label.text = "1024 Block Street\nShaffer, CA\n95014"
            label.textColor = UIColor.blue
            label.frame = CGRect(x: 0, y: 0, width: 50, height: 100)
            view.addSubview(label)
        } else {
            view = reuseCellsSet.removeFirst()
        }
        view.frame = CGRect(x: 0, y: 0, width: 150, height: 200)
        containerView.addSubview(view)
        return view
    }
    
    override var frame: CGRect {
        didSet {
            contentSize = CGSize(width: self.frame.width, height: self.frame.height * 5000)
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
