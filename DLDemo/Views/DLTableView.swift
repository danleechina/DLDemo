//
//  DLTableView.swift
//  DLDemo
//
//  Created by Dan.Lee on 2016/10/22.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

import UIKit

enum DLTableViewScrollDirection {
    case Vertical
    case Horizontal
}

@objc protocol DLTableViewDelegate : NSObjectProtocol, UIScrollViewDelegate{
    @objc func tableView(_ tableView: DLTableView,  heightForRowAt indexPath: IndexPath) -> CGFloat
}

protocol DLTableViewDataSource: class {
    func tableView(_ tableView: DLTableView, cellForRowAt indexPath: IndexPath) -> DLTableViewCell
    func tableView(_ tableView: DLTableView, numberOfRowsInSection section: Int) -> Int
}

class DLTableViewCell: UIView {
    var reuseID: String?
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.blue
        return label
    }()
    
    override var frame: CGRect {
        didSet {
            titleLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class DLTableView: UIScrollView {

    fileprivate var visibileCellsInVertical = Array<DLTableViewCell>()
    fileprivate var visibileCellsIndexPath = Array<IndexPath>()
    fileprivate var reuseCellsInVerticalSet = Set<DLTableViewCell>()
    fileprivate var containerView = UIView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        recenterInVerticalIfNecessary()
        let visibleBounds = convert(bounds, to: containerView)
        tileCellsInVertical(fromMinY: visibleBounds.minY, toMaxY: visibleBounds.maxY)
    }
    
    fileprivate func recenterInVerticalIfNecessary() {
        if !enableCycleScroll {
            return
        }
        let currentOffset = contentOffset
        let contentHeight = contentSize.height
        let centerOffsetY = (contentHeight - bounds.height) / 2
        let distanceFromCenterY = fabs(currentOffset.y - centerOffsetY)
        
        if distanceFromCenterY > (contentHeight / 4) {
            contentOffset = CGPoint(x: currentOffset.x, y: centerOffsetY)
            for cell in visibileCellsInVertical {
                var center = containerView.convert(cell.center, to: self)
                center.y += (centerOffsetY - currentOffset.y)
                cell.center = convert(center, to: containerView)
            }
        }
    }
    
    fileprivate func tileCellsInVertical(fromMinY minY: CGFloat, toMaxY maxY: CGFloat) {
        if visibileCellsInVertical.isEmpty {
            _ = placeNewCellOnBottom(bottomEdge: minY)
        }
        
        var lastCell = visibileCellsInVertical.last!
        var bottomEdge = lastCell.frame.maxY
        while bottomEdge < maxY {
            bottomEdge = placeNewCellOnBottom(bottomEdge: bottomEdge)
        }
        
        if bottomEdge == CGFloat.greatestFiniteMagnitude {
            contentSize = CGSize(width: contentSize.width, height: visibileCellsInVertical.last!.frame.maxY)
        }
        
        var headCell = visibileCellsInVertical.first!
        var topEdge = headCell.frame.minY
        while topEdge > minY {
            topEdge = placeNewCellOnTop(topEdge: topEdge)
        }
        
        lastCell = visibileCellsInVertical.last!
        while lastCell.frame.origin.y > maxY {
            lastCell.removeFromSuperview()
            visibileCellsIndexPath.removeLast()
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
            visibileCellsIndexPath.removeFirst()
            reuseCellsInVerticalSet.insert(visibileCellsInVertical.removeFirst())
            if visibileCellsInVertical.isEmpty {
                break
            }
            headCell = visibileCellsInVertical.first!
        }
    }
    
    fileprivate func placeNewCellOnBottom(bottomEdge: CGFloat) -> CGFloat {
        
        var indexPath = IndexPath.init(row: 0, section: 0)
        if visibileCellsIndexPath.isEmpty {
            visibileCellsIndexPath.append(indexPath)
        } else {
            var row = visibileCellsIndexPath.last!.row + 1
            if row >= self.dataSource!.tableView(self, numberOfRowsInSection: 0) {
                if enableCycleScroll {
                    row = 0
                } else {
                    return CGFloat.greatestFiniteMagnitude
                }
            }
            indexPath = IndexPath.init(row: row, section: 0)
            visibileCellsIndexPath.append(indexPath)
        }
        
        let view = insertCellInVertical(withIndexPath: indexPath)
        visibileCellsInVertical.append(view)
        
        var frame = view.frame
        frame.origin.y = bottomEdge
        frame.origin.x = 0
        frame.size.width = self.frame.width
        frame.size.height = 40
        if let delegate = self.tableViewDelegate {
            frame.size.height = delegate.tableView(self, heightForRowAt: indexPath)
        }
        view.frame = frame
        
        return frame.maxY
    }
    
    fileprivate func placeNewCellOnTop(topEdge: CGFloat) -> CGFloat {
        
        var indexPath = IndexPath.init(row: 0, section: 0)
        if visibileCellsIndexPath.isEmpty {
            visibileCellsIndexPath.append(indexPath)
        } else {
            var row = visibileCellsIndexPath.first!.row - 1
            if row < 0 {
                if enableCycleScroll {
                    row = self.dataSource!.tableView(self, numberOfRowsInSection: 0) - 1
                } else {
                    return -CGFloat.greatestFiniteMagnitude
                }
            }
            indexPath = IndexPath.init(row: row, section: 0)
            visibileCellsIndexPath.insert(indexPath, at: 0)
        }
        
        let view = insertCellInVertical(withIndexPath: indexPath)
        visibileCellsInVertical.insert(view, at: 0)
        
        var frame = view.frame
        frame.origin.x = 0
        frame.size.width = self.frame.width
        frame.size.height = 40
        if let delegate = self.tableViewDelegate {
            frame.size.height = delegate.tableView(self, heightForRowAt: indexPath)
        }
        frame.origin.y = topEdge - frame.height
        view.frame = frame
        
        return frame.minY
    }
    
    
    func insertCellInVertical(withIndexPath indexPath: IndexPath) -> DLTableViewCell {
        if let ds = self.dataSource {
            let cell = ds.tableView(self, cellForRowAt: indexPath)
            cell.frame = CGRect(x: 0, y: 0, width: 60, height: 100)
            containerView.addSubview(cell)
            return cell
        } else {
            // ds should not be nil
            assert(false)
            return DLTableViewCell()
        }
    }
    
    fileprivate func setAppearance() {
        switch scrollDirection {
        case .Vertical:
            contentSize = CGSize(width: self.frame.width, height: self.frame.height * 5000)
            break
        case .Horizontal:
            contentSize = CGSize(width: self.frame.width * 5000, height: self.frame.height)
            break
        }
        contentOffset = CGPoint(x: 0, y: 0)
        containerView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
        reuseCellsInVerticalSet.removeAll()
        visibileCellsIndexPath.removeAll()
        visibileCellsInVertical.removeAll()
        containerView.removeAllSubviews()
        setNeedsLayout()
    }
    
    override var frame: CGRect {
        didSet {
            setAppearance()
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
    
    override weak var delegate: UIScrollViewDelegate? {
        get {
            return tableViewDelegate
        }
        set {
            self.tableViewDelegate = newValue as? DLTableViewDelegate
        }
    }
    fileprivate weak var tableViewDelegate: DLTableViewDelegate?
    // dataSource can not be nil or crash
    weak var dataSource: DLTableViewDataSource?
    var enableCycleScroll = false {
        didSet {
            setAppearance()
        }
    }
    var scrollDirection = DLTableViewScrollDirection.Vertical {
        didSet {
            setAppearance()
        }
    }
    
    
    func dequeueReusableCell(withIdentifier identifier: String) -> DLTableViewCell {
        for cell in reuseCellsInVerticalSet {
            if cell.reuseID == identifier {
                reuseCellsInVerticalSet.remove(cell)
                return cell
            }
        }
        let cell = DLTableViewCell()
        cell.reuseID = identifier
        return cell
    }

}
