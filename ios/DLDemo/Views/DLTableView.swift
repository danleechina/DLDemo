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

enum DLTableViewScrollPosition : Int {
    case top
    case middle
    case bottom
}

enum DLTableViewCellStyle {
    case Custom
    case Default
}

@objc protocol DLTableViewDelegate : NSObjectProtocol, UIScrollViewDelegate{
    @objc
    optional func tableView(_ tableView: DLTableView, didEndDisplaying cell: DLTableViewCell, forRowAt indexPath: IndexPath)
    
    @objc
    optional func tableView(_ tableView: DLTableView,  heightForRowAt indexPath: IndexPath) -> CGFloat
    
    @objc
    optional func tableView(_ tableView: DLTableView,  widthForRowAt indexPath: IndexPath) -> CGFloat
    
    @objc
    optional func tableView(_ tableView: DLTableView, didSelectRowAt indexPath: IndexPath)
    
    // specific for cycle enable table view to get the exact indexPath in case of many same indexPath in visible bound
    // and you should implement this method if you are using cyclable table view.
    @objc
    optional func tableView(_ tableView: DLTableView, didSelectRowAt indexPath: IndexPath, withInternalIndex index: Int)

}

protocol DLTableViewDataSource: class {
    func tableView(_ tableView: DLTableView, cellForRowAt indexPath: IndexPath) -> DLTableViewCell?
    func tableView(_ tableView: DLTableView, numberOfRowsInSection section: Int) -> Int
}

// there are really not many things about the cell. It's totally up to you to inherit it and custom it.
class DLTableViewCell: UIView {
    var reuseID: String?
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.blue
        return label
    }()
    var containerView = UIView()
    
    
    override var frame: CGRect {
        didSet {
            titleLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            containerView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            selectedBackgroundColorView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        }
    }
    
    fileprivate let selectedBackgroundColorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        addSubview(selectedBackgroundColorView)
        selectedBackgroundColorView.isHidden = true
        selectedBackgroundColorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.9)
    }
    
    init(style: DLTableViewCellStyle, reuseIdentifier: String?) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        switch style {
        case .Custom:
            titleLabel.isHidden = true
            break
        case .Default:
            titleLabel.isHidden = false
            break
        }
        reuseID = reuseIdentifier
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        addSubview(selectedBackgroundColorView)
        selectedBackgroundColorView.isHidden = true
        selectedBackgroundColorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.9)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// This class will not implement things like sectionHeader, sectionFooter, etc.
// These can be implemented by using different kind of cell.
// For the floating section view, you can inherit DLTableView and add a subview to the top of the tableView when the row which is a fake section is about to scroll out.
class DLTableView: UIScrollView {

    var visibileCells = Array<DLTableViewCell>()
    var visibileCellsIndexPath = Array<IndexPath>()
    var selectedColor: UIColor?
    
    fileprivate var reuseCellsSet = Set<DLTableViewCell>()
    fileprivate var containerView = UIView()
    fileprivate static let DefaultCellLength:CGFloat = 40
    fileprivate var isContentSizeLessThanFrameSize = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        recenterIfNecessary()
        tileCells(inVisibleBounds: convert(bounds, to: containerView))
    }
    
    fileprivate func recenterIfNecessary() {
        if !enableCycleScroll {
            return
        }
        let currentOffset = contentOffset
        let contentLength = scrollDirection == .Vertical ? contentSize.height : contentSize.width
        let centerOffsetXOrY = (contentLength - (scrollDirection == .Vertical ? bounds.height : bounds.width)) / 2
        let distanceFromCenterXOrY = fabs((scrollDirection == .Vertical ? currentOffset.y : currentOffset.x) - centerOffsetXOrY)
        
        // TEST: haven't test it.
        if distanceFromCenterXOrY > (contentLength / 4) {
            contentOffset = scrollDirection == .Vertical ? CGPoint(x: currentOffset.x, y: centerOffsetXOrY) : CGPoint(x: centerOffsetXOrY, y: currentOffset.y)
            for cell in visibileCells {
                var center = containerView.convert(cell.center, to: self)
                if scrollDirection == .Vertical {
                    center.y += (centerOffsetXOrY - currentOffset.y)
                } else {
                    center.x += (centerOffsetXOrY - currentOffset.x)
                }
                cell.center = convert(center, to: containerView)
            }
        }
    }
    
    fileprivate func tileCells(inVisibleBounds visibleBounds: CGRect) {
        var cellChange = false
        let visibleCellsCount = visibileCells.count
        let minXOrY = scrollDirection == .Vertical ? visibleBounds.minY : visibleBounds.minX
        let maxXOrY = scrollDirection == .Vertical ? visibleBounds.maxY : visibleBounds.maxX
        
        if visibileCells.isEmpty {
            _ = placeNewCell(onNextEdge: minXOrY)
        }
        
        var lastCell = visibileCells.last!
        var nextEdge = scrollDirection == .Vertical ? lastCell.frame.maxY : lastCell.frame.maxX

        while nextEdge < maxXOrY {
            nextEdge = placeNewCell(onNextEdge: nextEdge)
        }
        
        if nextEdge == CGFloat.greatestFiniteMagnitude {
            var needContentSize = CGSize(width: 0, height: 0)
            if enableCycleScroll || tableFooterView == nil {
                needContentSize = scrollDirection == .Vertical ?
                    CGSize(width: contentSize.width, height: visibileCells.last!.frame.maxY) :
                    CGSize(width: visibileCells.last!.frame.maxX, height: contentSize.height)
            } else if let view = tableFooterView {
                if !isPositionForTableFooterViewKnown {
                    _ = scrollDirection == .Vertical ?
                        (view.frame.origin.y  = visibileCells.last!.frame.maxY) :
                        (view.frame.origin.x  = visibileCells.last!.frame.maxX)
                    isPositionForTableFooterViewKnown = true
                }
                needContentSize = scrollDirection == .Vertical ?
                    CGSize(width: contentSize.width, height: view.frame.maxY) :
                    CGSize(width: view.frame.maxX, height: contentSize.height)
            }
            if needContentSize.height < self.frame.height && scrollDirection == .Vertical {
                needContentSize.height = self.frame.height + 5
            } else if needContentSize.width < self.frame.width && scrollDirection == .Horizontal {
                needContentSize.width = self.frame.width + 5
            }
            contentSize = needContentSize
        }
        
        var headCell = visibileCells.first!
        var previousEdge = scrollDirection == .Vertical ? headCell.frame.minY : headCell.frame.minX
        while previousEdge > minXOrY {
            previousEdge = placeNewCell(onPreviousEdge: previousEdge)
        }
        
        lastCell = visibileCells.last!
        while (scrollDirection == .Vertical ? lastCell.frame.origin.y : lastCell.frame.origin.x) > maxXOrY {
            if visibileCells.count == 1 {
                // don't make visibileCells empty otherwise there is a problem
                break
            }
            lastCell.removeFromSuperview()
            let delIndexPath = visibileCellsIndexPath.removeLast()
            let delCell = visibileCells.removeLast()
            reuseCellsSet.insert(delCell)
            self.tableViewDelegate?.tableView?(self, didEndDisplaying: delCell, forRowAt: delIndexPath)
            lastCell = visibileCells.last!
            cellChange = true
        }
        
        headCell = visibileCells.first!
        while (scrollDirection == .Vertical ? headCell.frame.maxY : headCell.frame.maxX) < minXOrY {
            if visibileCells.count == 1 {
                break
            }
            headCell.removeFromSuperview()
            let delIndexPath = visibileCellsIndexPath.removeFirst()
            let delCell = visibileCells.removeFirst()
            reuseCellsSet.insert(delCell)
            self.tableViewDelegate?.tableView?(self, didEndDisplaying: delCell, forRowAt: delIndexPath)
            headCell = visibileCells.first!
            cellChange = true
        }
        
        if cellChange || visibleCellsCount != visibileCells.count {
            NotificationCenter.default.post(name: .DLTableViewCellDidChange, object: self)
        }
    }
    
    fileprivate func placeNewCell(onNextEdge nextEdge: CGFloat) -> CGFloat {
        
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
        
        let view = insertCell(withIndexPath: indexPath)
        var offsetXOrY: CGFloat = 0
        if let view = tableHeaderView {
            if visibileCells.isEmpty && !enableCycleScroll {
                offsetXOrY = scrollDirection == .Vertical ? view.frame.maxY : view.frame.maxX
            }
        }
        visibileCells.append(view)
        
        var frame = view.frame
        if scrollDirection == .Vertical {
            frame.origin.y = nextEdge + offsetXOrY
            frame.origin.x = 0
            frame.size.width = self.frame.width
            frame.size.height = DLTableView.DefaultCellLength
            if let height = self.tableViewDelegate?.tableView?(self, heightForRowAt: indexPath) {
                frame.size.height = height
            }
        } else {
            frame.origin.y = 0
            frame.origin.x = nextEdge + offsetXOrY
            frame.size.width = DLTableView.DefaultCellLength
            frame.size.height = self.frame.height
            if let width = self.tableViewDelegate?.tableView?(self, widthForRowAt: indexPath) {
                frame.size.width = width
            }
        }
        view.frame = frame
        
        return scrollDirection == .Vertical ? frame.maxY : frame.maxX
    }
    
    fileprivate func placeNewCell(onPreviousEdge previousEdge: CGFloat) -> CGFloat {
        
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
        
        let view = insertCell(withIndexPath: indexPath)
        visibileCells.insert(view, at: 0)
        
        var frame = view.frame
        if scrollDirection == .Vertical {
            frame.origin.x = 0
            frame.size.width = self.frame.width
            frame.size.height = DLTableView.DefaultCellLength
            if let height = self.tableViewDelegate?.tableView?(self, heightForRowAt: indexPath) {
                frame.size.height = height
            }
            frame.origin.y = previousEdge - frame.height
        } else {
            frame.origin.y = 0
            frame.size.width = DLTableView.DefaultCellLength
            frame.size.height = self.frame.height
            if let width = self.tableViewDelegate?.tableView?(self, widthForRowAt: indexPath) {
                frame.size.width = width
            }
            frame.origin.x = previousEdge - frame.width
        }
        view.frame = frame
        
        return scrollDirection == .Vertical ? frame.minY : frame.minX
    }
    
    func insertCell(withIndexPath indexPath: IndexPath) -> DLTableViewCell {
        if let cell = self.dataSource?.tableView(self, cellForRowAt: indexPath) {
            cell.frame = CGRect(x: 0, y: 0, width: 60, height: 100)
            cell.selectedBackgroundColorView.backgroundColor = selectedColor ?? cell.selectedBackgroundColorView.backgroundColor
            containerView.addSubview(cell)
            return cell
        }  else {
            // ds should not be nil
            assert(false)
            return DLTableViewCell()
        }
    }
    
    func reloadViews() {
        switch scrollDirection {
        case .Vertical:
            contentSize = CGSize(width: self.frame.width, height:  10000)
            if !enableCycleScroll {
                contentSize = CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude)
            }
            break
        case .Horizontal:
            contentSize = CGSize(width:  10000, height: self.frame.height)
            if !enableCycleScroll {
                contentSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: self.frame.height)
            }
            break
        }
        contentOffset = CGPoint(x: 0, y: 0)
        containerView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
        reuseCellsSet.removeAll()
        visibileCellsIndexPath.removeAll()
        visibileCells.removeAll()
        containerView.removeAllSubviews()
        isPositionForTableFooterViewKnown = false
        
        if !enableCycleScroll {
            if let view = tableFooterView {
                containerView.addSubview(view)
            }
            if let view = tableHeaderView {
                containerView.addSubview(view)
            }
            
            if scrollDirection == .Vertical {
                if let view = tableHeaderView {
                    view.frame.origin.x = 0
                    view.frame.origin.y = 0
                    view.frame.size.width = self.frame.width
                }
            } else {
                if let view = tableHeaderView {
                    view.frame.origin.x = 0
                    view.frame.origin.y = 0
                    view.frame.size.height = self.frame.height
                }
            }
            
            if scrollDirection == .Vertical {
                if let view = tableFooterView {
                    view.frame.origin.x = 0
                    view.frame.origin.y = -CGFloat.greatestFiniteMagnitude
                    view.frame.size.width = self.frame.width
                }
            } else {
                if let view = tableFooterView {
                    view.frame.origin.x = -CGFloat.greatestFiniteMagnitude
                    view.frame.origin.y = 0
                    view.frame.size.height = self.frame.height
                }
            }
        }
        setNeedsLayout()
    }
    
    func reloadData() {
        for (index, indexPath) in visibileCellsIndexPath.enumerated() {
            if let newCell = self.dataSource?.tableView(self, cellForRowAt: indexPath) {
                let cell = visibileCells[index]
                newCell.frame = cell.frame
                visibileCells[index] = newCell
                cell.removeFromSuperview()
                self.containerView.addSubview(newCell)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        let tapGest = UITapGestureRecognizer.init(target: self, action: #selector(tableViewTapped(sender:)))
        tapGest.cancelsTouchesInView = false
        self.addGestureRecognizer(tapGest)
        
        let longPressGest = UILongPressGestureRecognizer.init(target: self, action: #selector(tableViewLongPressDetected(sender:)))
        longPressGest.minimumPressDuration = 0.5
        self.addGestureRecognizer(longPressGest)
        tapGest.require(toFail: longPressGest)
        
    }
    
    @objc fileprivate func tableViewTapped(sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.containerView)
        if let cell = self.containerView.whichSubviewContains(point: point).last as? DLTableViewCell {
            if let index = self.visibileCells.index(of: cell) {
                cell.selectedBackgroundColorView.isHidden = false
                pressedCell = cell
                if !enableCycleScroll {
                    self.tableViewDelegate?.tableView?(self, didSelectRowAt: self.visibileCellsIndexPath[index])
                } else {
                    self.tableViewDelegate?.tableView?(self, didSelectRowAt: self.visibileCellsIndexPath[index], withInternalIndex: index)
                }
            }
        }
    }
    
    fileprivate var pressedCell: DLTableViewCell?
    @objc fileprivate func tableViewLongPressDetected(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            let point = sender.location(in: self.containerView)
            if let cell = self.containerView.whichSubviewContains(point: point).last as? DLTableViewCell {
                cell.selectedBackgroundColorView.isHidden = false
                pressedCell = cell
            }
            break
        case .changed:
            if let cell = pressedCell {
                let point = sender.location(in: self.containerView)
                if !cell.frame.contains(point) {
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.selectedBackgroundColorView.alpha = 0
                        }, completion: { (comp) in
                            cell.selectedBackgroundColorView.isHidden = true
                            cell.selectedBackgroundColorView.alpha = 1
                    })
                }
            }
            break
        default:
            if let cell = pressedCell {
                cell.selectedBackgroundColorView.isHidden = true
                pressedCell = nil
            }
        }
    }
    
    
    func deselectRow(at indexPath: IndexPath, animated: Bool) {
        deselectRow(at: indexPath, withInternalIndex: nil, animated: animated)
    }
    
    
    func deselectRow(at indexPath: IndexPath, withInternalIndex index: Int?, animated: Bool) {
        var idx = -1
        if let i = index {
            idx = i
        }
        if idx == -1 {
            for (i, ip) in visibileCellsIndexPath.enumerated() {
                if indexPath.row == ip.row && indexPath.section == ip.section {
                    idx = i
                    break
                }
            }
        }
        if idx != -1 {
            // maybe out of range when animation finish, so use a variable
            let cell = visibileCells[idx]
            cell.selectedBackgroundColorView.isHidden = false
            if animated {
                UIView.animate(withDuration: 0.5, animations: {
                    cell.selectedBackgroundColorView.alpha = 0
                    }, completion: { (comp) in
                        cell.selectedBackgroundColorView.isHidden = true
                        cell.selectedBackgroundColorView.alpha = 1
                })
            }
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // FIX: merge tableViewDelegate and delegate of the superclass
    weak var tableViewDelegate: DLTableViewDelegate?
    // dataSource can not be nil or crash
    weak var dataSource: DLTableViewDataSource?
    var enableCycleScroll = false
    // FIX when you change the value, tableHeaderView's and tableFooterView's frame will be wrong
    var scrollDirection = DLTableViewScrollDirection.Vertical
    
    func dequeueReusableCell(withIdentifier identifier: String) -> DLTableViewCell? {
        for cell in reuseCellsSet {
            if cell.reuseID == identifier {
                reuseCellsSet.remove(cell)
                return cell
            }
        }
        return nil
    }
    
    
    // when enableCycleScroll is true, there is no table header view
    var tableHeaderView: UIView? // accessory view for above row content. default is nil. not to be confused with section header
    // when enableCycleScroll is true, there is no table footer view
    var tableFooterView: UIView? // accessory view below content. default is nil. not to be confused with section footer
    fileprivate var isPositionForTableFooterViewKnown = false
    
    // if the scroll effect doesn't match your need, you can implement customed method based on this method
    // internalIndex is specific for cycle table view to get the exact indexPath when there may be many same indexPath in visible bound
    func scrollToRow(at indexPath: IndexPath, withInternalIndex index: Int?, at scrollPosition: DLTableViewScrollPosition, animated: Bool, completion: ((Bool) -> Swift.Void)? = nil) {
        let finialOffset = getOffset(at: indexPath, withInternalIndex: index, at: scrollPosition)
        setContentOffset(finialOffset, animated: animated)
    }
    
    func scrollToRow(at indexPath: IndexPath, at scrollPosition: DLTableViewScrollPosition, animated: Bool) {
        scrollToRow(at: indexPath, withInternalIndex: nil, at: scrollPosition, animated: animated)
    }
    
    func getOffset(at indexPath: IndexPath, withInternalIndex index: Int?, at scrollPosition: DLTableViewScrollPosition) -> CGPoint {
        // TODO if indexPath is too large
        // adjust visibleCells' frame and visibleCellIndexPath to the near of indexPath
        //
        
        var finialOffset: CGPoint = CGPoint(x: 0, y: 0)
        if enableCycleScroll {
            finialOffset = getOffset(forIndexPath: indexPath, withInternalIndex: index)
        } else {
            finialOffset = getOffsetWithNoCycle(forIndexPath: indexPath)
        }
        switch scrollPosition {
        case .bottom:
            var cellLength = DLTableView.DefaultCellLength
            if scrollDirection == .Vertical {
                if let height = self.tableViewDelegate?.tableView?(self, heightForRowAt: indexPath) {
                    cellLength = height
                }
                finialOffset.y -= (self.frame.height - cellLength)
            } else {
                if let width = self.tableViewDelegate?.tableView?(self, widthForRowAt: indexPath) {
                    cellLength = width
                }
                finialOffset.x -= (self.frame.width - cellLength)
            }
            break
        case .middle:
            var cellLength = DLTableView.DefaultCellLength
            if scrollDirection == .Vertical {
                if let height = self.tableViewDelegate?.tableView?(self, heightForRowAt: indexPath) {
                    cellLength = height
                }
                finialOffset.y -= (self.frame.height/2 - cellLength/2)
            } else {
                if let width = self.tableViewDelegate?.tableView?(self, widthForRowAt: indexPath) {
                    cellLength = width
                }
                finialOffset.x -= (self.frame.width/2 - cellLength/2)
            }
            break
        case .top:
            break
        }
        if !enableCycleScroll {
            finialOffset = restraint(offSet: finialOffset)
        }
        return finialOffset;
    }
    
    // FIX: we'd better cache the offset
    func getOffset(forIndexPath indexPath: IndexPath, withInternalIndex index: Int?) -> CGPoint {
        if let i = index {
            return visibileCells[i].frame.origin
        }
        for (i, index) in visibileCellsIndexPath.enumerated() {
            if index.row == indexPath.row && index.section == indexPath.section {
                return visibileCells[i].frame.origin
            }
        }
        
        let headIndexPath = visibileCellsIndexPath.first!
        let lastIndexPath = visibileCellsIndexPath.last!
//        let isHeaderGreater = headIndexPath.row > lastIndexPath.row
        let rowsCount = numberOfRows(inSection: indexPath.section)
        
        let distance1FromHead = abs(indexPath.row - headIndexPath.row)
        let distance2FromHead = rowsCount - abs(indexPath.row - headIndexPath.row)
        var distanceFromHead = distance1FromHead
        if distance2FromHead < distance1FromHead {
            distanceFromHead = distance2FromHead
        }
        
        let distance1FromLast = abs(indexPath.row - lastIndexPath.row)
        let distance2FromLast = rowsCount - abs(indexPath.row - lastIndexPath.row)
        var distanceFromLast = distance1FromLast
        if distance2FromLast < distance1FromLast {
            distanceFromLast = distance2FromLast
        }
        
        var isAdd = false
        var startCell = visibileCells.first!
        var tmpIndexPath = IndexPath.init(row: indexPath.row, section: 0)
        
        if distanceFromLast < distanceFromHead {
            startCell = visibileCells.last!
            tmpIndexPath = visibileCellsIndexPath.last!
            isAdd = true
        } else {
            startCell = visibileCells.first!
            tmpIndexPath = visibileCellsIndexPath.first!
            isAdd = false
        }
        
        var xOrY = scrollDirection == .Vertical ? startCell.frame.origin.y : startCell.frame.origin.x
        while true {
            if isAdd {
                tmpIndexPath.row += 1
            } else {
                tmpIndexPath.row -= 1
            }
            if tmpIndexPath.row < 0 {
                tmpIndexPath.row = rowsCount - 1
            } else if tmpIndexPath.row > rowsCount - 1 {
                tmpIndexPath.row = 0
            }
            if scrollDirection == .Vertical {
                if isAdd {
                    if let height = self.tableViewDelegate?.tableView?(self, heightForRowAt: tmpIndexPath) {
                        xOrY += height
                    } else {
                        xOrY += DLTableView.DefaultCellLength
                    }
                } else {
                    if let height = self.tableViewDelegate?.tableView?(self, heightForRowAt: tmpIndexPath) {
                        xOrY -= height
                    } else {
                        xOrY -= DLTableView.DefaultCellLength
                    }
                }
            } else {
                if isAdd {
                    if let width = self.tableViewDelegate?.tableView?(self, widthForRowAt: tmpIndexPath) {
                        xOrY += width
                    } else {
                        xOrY += DLTableView.DefaultCellLength
                    }
                } else {
                    if let width = self.tableViewDelegate?.tableView?(self, widthForRowAt: tmpIndexPath) {
                        xOrY -= width
                    } else {
                        xOrY -= DLTableView.DefaultCellLength
                    }
                }
            }
            if tmpIndexPath.row == indexPath.row && tmpIndexPath.section == indexPath.section {
                break
            }
        }
        
        var finialOffset = CGPoint(x: 0, y: 0)
        if scrollDirection == .Vertical {
            finialOffset = CGPoint(x: 0, y: xOrY)
        } else {
            finialOffset = CGPoint(x: xOrY, y: 0)
        }
        return finialOffset
    }
    
    // FIX: we'd better cache the offset
    func getOffsetWithNoCycle(forIndexPath indexPath: IndexPath) -> CGPoint {
        var flag = false
        var xOrY: CGFloat = 0
        for (i, index) in visibileCellsIndexPath.enumerated() {
            if index.row == indexPath.row && index.section == indexPath.section {
                xOrY = scrollDirection == .Vertical ? visibileCells[i].frame.origin.y : visibileCells[i].frame.origin.x
                flag = true
                break
            }
        }
        
        if !flag {
            let headIndexPath = visibileCellsIndexPath.first!
            let lastIndexPath = visibileCellsIndexPath.last!
            //        let isHeaderGreater = headIndexPath.row > lastIndexPath.row
            if indexPath.row < headIndexPath.row {
                // -
                xOrY = scrollDirection == .Vertical ? visibileCells.first!.frame.origin.y : visibileCells.first!.frame.origin.x
                var tmpIndexPath = IndexPath.init(row: headIndexPath.row, section: headIndexPath.section)
                
                while indexPath.row <= tmpIndexPath.row {
                    tmpIndexPath.row -= 1
                    var subValue = DLTableView.DefaultCellLength
                    if scrollDirection == .Vertical {
                        if let height = self.tableViewDelegate?.tableView?(self, heightForRowAt: IndexPath.init(row: tmpIndexPath.row, section: 0)) {
                            subValue = height
                        }
                    } else {
                        if let width = self.tableViewDelegate?.tableView?(self, widthForRowAt: IndexPath.init(row: tmpIndexPath.row, section: 0)) {
                            subValue = width
                        }
                    }
                    xOrY -= subValue
                    
                }
            } else {
                // +
                xOrY = scrollDirection == .Vertical ? visibileCells.last!.frame.origin.y : visibileCells.last!.frame.origin.x
                var tmpIndexPath = IndexPath.init(row: lastIndexPath.row, section: lastIndexPath.section)
                
                while indexPath.row >= tmpIndexPath.row {
                    tmpIndexPath.row += 1
                    var addValue = DLTableView.DefaultCellLength
                    if scrollDirection == .Vertical {
                        if let height = self.tableViewDelegate?.tableView?(self, heightForRowAt: IndexPath.init(row: tmpIndexPath.row, section: 0)) {
                            addValue = height
                        }
                    } else {
                        if let width = self.tableViewDelegate?.tableView?(self, widthForRowAt: IndexPath.init(row: tmpIndexPath.row, section: 0)) {
                            addValue = width
                        }
                    }
                    xOrY += addValue
                }
            }
        }
        var finialOffset = CGPoint(x: xOrY, y: 0)
        if scrollDirection == .Vertical {
            finialOffset = CGPoint(x: 0, y: xOrY)
        }
        return finialOffset
    }
    
    func restraint(offSetXOrY: CGFloat) -> CGPoint {
        var xOrY = offSetXOrY
        
        var finialOffset = CGPoint(x: 0, y: 0)
        if scrollDirection == .Vertical {
            if xOrY < 0 {
                xOrY = 0
            } else if xOrY > contentSize.height - self.frame.height {
                xOrY = contentSize.height - self.frame.height
            }
            finialOffset = CGPoint(x: 0, y: xOrY)
        } else {
            if xOrY < 0 {
                xOrY = 0
            } else if xOrY > contentSize.width - self.frame.width {
                xOrY = contentSize.width - self.frame.width
            }
            finialOffset = CGPoint(x: xOrY, y: 0)
        }
        return finialOffset
    }
    
    func restraint(offSet: CGPoint) -> CGPoint {
        var xOrY = offSet.x
        if scrollDirection == .Vertical {
            xOrY = offSet.y
        }
        return restraint(offSetXOrY: xOrY)
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        if let count = self.dataSource?.tableView(self, numberOfRowsInSection: section) {
            return count
        }
        return 0
    }
}

extension DLTableView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension Notification.Name {
    static let DLTableViewCellDidChange = Notification.Name("DLTableViewCellDidChange")
}
