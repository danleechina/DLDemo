//
//  DLPickerView
//  DLDemo
//
//  Created by Dan.Lee on 2016/10/22.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

import UIKit
import AVFoundation

protocol DLPickerViewDataSource : NSObjectProtocol {
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: DLPickerView) -> Int
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: DLPickerView, numberOfRowsInComponent component: Int) -> Int
}

@objc protocol DLPickerViewDelegate : NSObjectProtocol {
    /*
             ------------------------------------------------------
                 Following methods are from system UIPickerView
             ------------------------------------------------------
     */
    
    // returns width of column and height of row for each component.
    @objc optional func pickerView(_ pickerView: DLPickerView, widthForComponent component: Int) -> CGFloat
    
    @objc optional func pickerView(_ pickerView: DLPickerView, rowHeightForComponent component: Int) -> CGFloat
    
    // these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
    // for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
    // If you return back a different object, the old one will be released. the view will be centered in the row rect
    @objc optional func pickerView(_ pickerView: DLPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    
    @objc optional func pickerView(_ pickerView: DLPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? // attributed title is favored if both methods are implemented
    
    @objc optional func pickerView(_ pickerView: DLPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    
    @objc optional func pickerView(_ pickerView: DLPickerView, didSelectRow row: Int, inComponent component: Int)
    
    /*      
            ------------------------------------------------------
                Following methods are specific for DLPickerView
            ------------------------------------------------------
     */
    
    // whether or not the specific component can scroll cyclically
    @objc optional func enableCycleScroll(in pickerView: DLPickerView, forComponent component: Int) -> Bool
    
    // if pickerView(_ pickerView: DLPickerView, rowHeightForComponent component: Int) -> CGFloat is implemented, this will not be invoked
    @objc optional func pickerView(_ pickerView: DLPickerView, rowHeightForRow row: Int, inComponent component: Int) -> CGFloat
    
    // only specific cell of the component within the returned range can stop at center
    @objc optional func pickerView(_ pickerView: DLPickerView, enableScrollWithinRangeForComponent component: Int) -> Bool
    // it enable scroll within range for the component, this method will be invoked
    @objc optional func pickerView(_ pickerView: DLPickerView, getRangeForScrollInComponent component: Int) -> NSRange
    // custom the indictor view for the component if you want, make sure that you don't return different indicator views for the same component
    @objc optional func pickerView(_ pickerView: DLPickerView, customIndictorViewForComponent component: Int) -> UIView
}

enum DLPickerViewLayoutStyle {
    case Vertical
    case Horizontal
}

enum DLPickerViewSelectionStyle {
    case System
    case Custom
}

class DLPickerViewInternalCell: DLTableViewCell {
    var customView = UIView()
    
    override var frame: CGRect {
        didSet {
            customView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        }
    }
    
    override init(style: DLTableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        containerView.addSubview(customView)
        titleLabel.font = UIFont.systemFont(ofSize: 23)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DLPickerViewInternalMagnifyingView: UIView {
    fileprivate weak var magnifyingView: UIView?
    override func draw(_ rect: CGRect) {
        if let magnifyingView = self.magnifyingView {
            let ctx = UIGraphicsGetCurrentContext()
            ctx!.scaleBy(x: 1.04, y: 1.04)
            ctx!.translateBy(x: -frame.origin.x, y: -magnifyingView.frame.height/2 + DLPickerView.DefaultRowHeight/2)
            // not sure why this method will crash in ios 8 and working with warning in ios 10
            // magnifyingView.layer.render(in: ctx!)
            magnifyingView.drawHierarchy(in: magnifyingView.bounds, afterScreenUpdates: true)
        }
    }
}

// FIXME: view disappear when scroll, sound effect didn't stop
// TODO: selection style for customing
class DLPickerView : UIView {
    
    weak var dataSource: DLPickerViewDataSource? // default is nil. weak reference
    weak var delegate: DLPickerViewDelegate? // default is nil. weak reference
    var showsSelectionIndicator = true {
        didSet {
            topIndicatorLine.isHidden = !showsSelectionIndicator
            bottomIndicatorLine.isHidden = !showsSelectionIndicator
            self.selectionIndicatorViews.forEach({$0.isHidden = !showsSelectionIndicator})
        }
    }

    // info that was fetched and cached from the data source and delegate
    var numberOfComponents: Int
    // Enable the scroll sound effect if you want.
    var enableScrollSound = true;
    // you can set the custom selection indicator view in this array, also you can implement the protocol method in DLPickerViewDelegate
    // these two kinds of ways are the same.
    var customSelectionIndicatorViews = [UIView]()
    var selectionStyle = DLPickerViewSelectionStyle.System {
        didSet {
            if selectionStyle == .Custom {
                
            } else {
                showsSelectionIndicator = true
            }
        }
    }
    
    var layoutStyle = DLPickerViewLayoutStyle.Horizontal {
        didSet {
            // This is ugly but simple, and everything inside is transformed. Typically, you'd better not use it.
            // If you really want a vertical layout, you should be careful about the transformed content.
            // Maybe you can anti-transform a square content when you set.
            switch layoutStyle {
            case .Horizontal:
                self.transform = CGAffineTransform(rotationAngle: 0)
                break
            case .Vertical:
                self.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI/2 * 3))
                break
            }
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            self.selectionIndicatorViews.forEach({$0.backgroundColor = backgroundColor;})
        }
    }
    
    func numberOfRows(inComponent component: Int) -> Int {
        if let ds = self.dataSource?.pickerView(self, numberOfRowsInComponent: component) {
            return ds
        }
        return 0
    }
    
    func rowSize(at row: Int, forComponent component: Int) -> CGSize {
        let tableView = self.tableViews[component]
        if let height = tableView.tableViewDelegate?.tableView?(tableView, heightForRowAt: IndexPath.init(row: row, section: 0)) {
            return CGSize(width: tableView.frame.width, height: height)
        }
        return CGSize(width: tableView.frame.width, height: DLPickerView.DefaultRowHeight)
    }
    
    // returns the view provided by the delegate via pickerView:viewForRow:forComponent:reusingView:
    // or nil if the row/component is not visible or the delegate does not implement
    // pickerView:viewForRow:forComponent:reusingView:
    func view(forRow row: Int, forComponent component: Int) -> UIView? {
        let cachedCustomView = cachedCustomViews["\(component)=\(row)"]
        if cachedCustomView?.superview == nil {
            return nil
        }
        return cachedCustomView
    }
    
    // Reloading whole view or single component
    func reloadAllComponents() {
        setAppearance()
        self.tableViews.forEach({$0.reloadViews()})
    }
    
    func reloadComponent(_ component: Int) {
        self.tableViews[component].reloadViews()
    }
    
    // selection. in this case, it means showing the appropriate row in the middle
    func selectRow(_ row: Int, inComponent component: Int, animated: Bool){ // scrolls the specified row to center.
        self.tableViews[component].scrollToRow(at: IndexPath.init(row: row, section: 0), at: .middle, animated: true)
    }
    
    
    func selectedRow(inComponent component: Int) -> Int{ // returns selected row. -1 if nothing selected
        return self.lastSelectedRow[component]
    }
    
    override init(frame: CGRect) {
        numberOfComponents = 0
        super.init(frame: frame)
        addSubview(containerView)
        addSubview(topIndicatorLine)
        addSubview(bottomIndicatorLine)
        topIndicatorLine.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        bottomIndicatorLine.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        topIndicatorLine.isHidden = false
        bottomIndicatorLine.isHidden = false
        self.addGestureRecognizer(tapGest)
        self.addGestureRecognizer(longPressGest)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal Implemention of DLPickerView
    
    fileprivate static let DefaultRowHeight:CGFloat     = 40
    fileprivate var containerView                       = UIView()
    fileprivate var topIndicatorLine                    = UIView()
    fileprivate var bottomIndicatorLine                 = UIView()
    fileprivate var cachedCustomViews                   = Dictionary<String, UIView>()
    fileprivate var selectionIndicatorViews             = [DLPickerViewInternalMagnifyingView]()
    fileprivate var tableViews                          = [DLTableView]()
    fileprivate var scrollWithinContentOffset           = [[CGPoint]]()
    fileprivate var isUserDraggingComponents            = [Bool ]()
    fileprivate var hasMakeSureNotOutOfRange            = [Bool]()
    fileprivate var lastSelectedRow                     = [Int]()
    fileprivate var canPlaySound = false
    fileprivate var playJustOnce = true
    static private var mySound:SystemSoundID = {
        var aSound:SystemSoundID = 1000
        if let soundURL = Bundle.main.url(forResource: "clockwork", withExtension: "wav") {
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &aSound)
        }
        return aSound
    }()
    
    fileprivate func playSoundEffect() {
        if canPlaySound && enableScrollSound {
            AudioServicesPlaySystemSound(DLPickerView.mySound)
        }
    }
    fileprivate lazy var tapGest: UITapGestureRecognizer = {
        let tapGest = UITapGestureRecognizer.init(target: self, action: #selector(tapDetected))
        tapGest.cancelsTouchesInView = false
        tapGest.require(toFail: self.longPressGest)
        return tapGest
    }()
    
    fileprivate lazy var longPressGest: UILongPressGestureRecognizer = {
        let longPressGest = UILongPressGestureRecognizer.init(target: self, action: nil)
        longPressGest.minimumPressDuration = 0.05
        longPressGest.allowableMovement = 1000
        return longPressGest
    }()
    
    @objc fileprivate func tapDetected(sender: UITapGestureRecognizer) {
        for (_, tableView) in self.tableViews.enumerated() {
            let point = sender.location(in: tableView)
            if let cell = tableView.containerView.whichSubviewContains(point: point).last as? DLTableViewCell {
                let index = tableView.visibileCells.index(of: cell)!
                let indexPath = tableView.visibileCellsIndexPath[index]
                if !isSelectedOutOfRangeOfIndexPath(tableView: tableView, indexPath: indexPath) {
                    tableView.scrollToRow(at: indexPath, withInternalIndex: index, at: .middle, animated: true, completion: nil)
                }
                break
            }
        }
    }
    
    fileprivate func setAppearance() {
        containerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        topIndicatorLine.frame = CGRect(x: 0, y: frame.height/2 - DLPickerView.DefaultRowHeight/2 - 1, width: frame.width, height: 1)
        bottomIndicatorLine.frame = CGRect(x: 0, y: frame.height/2 + DLPickerView.DefaultRowHeight/2 , width: frame.width, height: 1)
        
        if let numberOfComponents = self.dataSource?.numberOfComponents(in: self) {
            self.numberOfComponents = numberOfComponents
        } else {
            self.numberOfComponents = 0
        }
        self.tableViews.forEach({$0.removeFromSuperview()})
        self.tableViews.removeAll()
        self.isUserDraggingComponents.removeAll()
        self.hasMakeSureNotOutOfRange.removeAll()
        self.selectionIndicatorViews.removeAll()
        self.scrollWithinContentOffset.removeAll()
        self.lastSelectedRow.removeAll()
        self.customSelectionIndicatorViews.removeAll()
        for index in 0 ..< numberOfComponents {
            // step 1: basic configure
            let tableView = DLTableView()
            tableView.tag = index
            tableView.delegate = self
            tableView.tableViewDelegate = self
            tableView.dataSource = self
            tableView.selectedColor = UIColor.clear
            tableView.backgroundColor = UIColor.clear
            tableView.disableLongPressGest = true
            tableView.disableTapGest = true
            
            // step 2: set if enable cycle scroll
            if let enableCycleScroll = self.delegate?.enableCycleScroll?(in: self, forComponent: index) {
                tableView.enableCycleScroll = enableCycleScroll
            } else {
                tableView.enableCycleScroll = false
            }
            
            // step 3: set frame
            var frame = tableView.frame
            if let width = self.delegate?.pickerView?(self, widthForComponent: index) {
                frame.size.width = width
                frame.origin.x = self.tableViews.last?.frame.maxX ?? 0
            } else {
                frame.size.width = self.frame.width / CGFloat(numberOfComponents)
                frame.origin.x = CGFloat(index) * self.frame.width / CGFloat(numberOfComponents)
            }
            frame.origin.y = 0
            frame.size.height = self.frame.height
            tableView.frame = frame
            
            // step 4: if disable cycle scroll, make sure top and bottom cell can stop at center of tableView
            if !tableView.enableCycleScroll {
                var firstCellHeight = DLPickerView.DefaultRowHeight
                var lastCellHeight = DLPickerView.DefaultRowHeight
                if let height = self.delegate?.pickerView?(self, rowHeightForComponent: tableView.tag) {
                    firstCellHeight = height
                    lastCellHeight = height
                } else if let height = self.delegate?.pickerView?(self, rowHeightForRow: 0, inComponent: tableView.tag) {
                    firstCellHeight = height
                    lastCellHeight = self.delegate!.pickerView!(self, rowHeightForRow: tableView.numberOfRows(inSection: 0) - 1, inComponent: tableView.tag)
                }
                
                tableView.tableHeaderView = UIView()
                tableView.tableFooterView = UIView()
                tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height/2 - firstCellHeight/2)
                tableView.tableFooterView?.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height/2 - lastCellHeight/2)
                tableView.tableHeaderView?.backgroundColor = UIColor.clear
                tableView.tableFooterView?.backgroundColor = UIColor.clear
            }
            
            // step 5: in the center of each tableView, there is a magnifying view.
            let selectionIndicatorView = DLPickerViewInternalMagnifyingView()
            selectionIndicatorView.magnifyingView = self.containerView
            selectionIndicatorView.backgroundColor = backgroundColor
            selectionIndicatorView.isUserInteractionEnabled = false
            selectionIndicatorView.frame = CGRect(x: frame.origin.x, y: frame.height/2 - DLPickerView.DefaultRowHeight/2, width: frame.width, height: DLPickerView.DefaultRowHeight)
            
            // TODO:
            
            // step 6: update array and view
            self.tableViews.append(tableView)
            self.isUserDraggingComponents.append(false)
            self.hasMakeSureNotOutOfRange.append(false)
            self.lastSelectedRow.append(-1)
            self.selectionIndicatorViews.append(selectionIndicatorView)
            self.containerView.addSubview(tableView)
            self.addSubview(selectionIndicatorView)
        }
        
        initAppearance(delay: 0.05)
        initIfEnableScrollRange(delay: 0.05)
        makeSureIndicatorViewsShowRight(delay: 0.15)
        nowWeCanPlaySound(delay: 0.5)
    }
    
    fileprivate func initAppearance(delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            for (_, tableView) in self.tableViews.enumerated() {
                self.transformCellLayer(scrollView: tableView)
                self.scrollToCenter(scrollView: tableView, animated: false)
            }
        }
    }
    
    fileprivate func initIfEnableScrollRange(delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            for (idx, tableView) in self.tableViews.enumerated() {
                self.scrollWithinContentOffset.append(Array<CGPoint>())
                if let enableScrollRange = self.delegate?.pickerView?(self, enableScrollWithinRangeForComponent: idx) {
                    if enableScrollRange {
                        if let range = self.delegate?.pickerView?(self, getRangeForScrollInComponent: idx) {
                            let startOffset = tableView.getOffset(at: IndexPath.init(row: range.location, section: 0), withInternalIndex: nil, at: .middle)
                            let endOffset = tableView.getOffset(at: IndexPath.init(row: range.location + range.length - 1, section: 0), withInternalIndex: nil, at: .middle)
                            self.scrollWithinContentOffset[idx].append(startOffset)
                            self.scrollWithinContentOffset[idx].append(endOffset)
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func nowWeCanPlaySound(delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.canPlaySound = true
        }
    }
    
    fileprivate func makeSureIndicatorViewsShowRight(delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            for (idx, _) in self.tableViews.enumerated() {
                self.selectionIndicatorViews[idx].setNeedsDisplay()
            }
        }
    }
    
    
    // MARK: - Supporting Function
    fileprivate func toggleSelectedActionIfNeeded(tableView: DLTableView) {
        DLPickerView.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(toggleSelectedAcionRightAway(tableView:)), with: tableView, afterDelay: 0.5)
    }
    
    @objc fileprivate func toggleSelectedAcionRightAway(tableView: DLTableView) {
        let minIndex = getIndexWhichIsTheClosestToCenter(scrollView: tableView)
        let indexPath = tableView.visibileCellsIndexPath[minIndex]
        if indexPath.row != self.lastSelectedRow[tableView.tag]
            && !isSelectedOutOfRangeOfIndexPath(tableView: tableView, indexPath: indexPath) {
            self.delegate?.pickerView?(self, didSelectRow: indexPath.row, inComponent: tableView.tag)
            self.lastSelectedRow[tableView.tag] = indexPath.row
        }
    }
    
    fileprivate func makeSureNotScrollOutOfRange(scrollView: UIScrollView, needScrollWhenOut: Bool) -> Bool {
        if !self.isUserDraggingComponents[scrollView.tag]
            && self.scrollWithinContentOffset.count > scrollView.tag
            && !self.scrollWithinContentOffset[scrollView.tag].isEmpty {
            if self.scrollWithinContentOffset[scrollView.tag][1].y < scrollView.contentOffset.y {
                if needScrollWhenOut {
                    scrollView.setContentOffset(self.scrollWithinContentOffset[scrollView.tag][1], animated: true)
                }
                return true
            } else if scrollView.contentOffset.y < self.scrollWithinContentOffset[scrollView.tag][0].y {
                if needScrollWhenOut {
                    scrollView.setContentOffset(self.scrollWithinContentOffset[scrollView.tag][0], animated: true)
                }
                return true
            } else {
                
            }
        }
        return false
    }
    
    fileprivate func isSelectedOutOfRangeOfIndexPath(tableView: DLTableView, indexPath: IndexPath) -> Bool {
        let idx = tableView.tag
        if let enableScrollRange = self.delegate?.pickerView?(self, enableScrollWithinRangeForComponent: idx) {
            if enableScrollRange {
                if let range = self.delegate?.pickerView?(self, getRangeForScrollInComponent: idx) {
                    if indexPath.row <  range.location || indexPath.row > range.location + range.length - 1 {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    fileprivate func scrollToCenter(scrollView: UIScrollView, animated: Bool) {
        if makeSureNotScrollOutOfRange(scrollView: scrollView, needScrollWhenOut: false) {
            return
        }
        let tableView = scrollView as! DLTableView
        let minIndex = getIndexWhichIsTheClosestToCenter(scrollView: scrollView)
        tableView.scrollToRow(at: tableView.visibileCellsIndexPath[minIndex], withInternalIndex: minIndex, at: .middle, animated: animated)
    }
    
    fileprivate func getIndexWhichIsTheClosestToCenter(scrollView: UIScrollView) -> Int {
        let tableView = scrollView as! DLTableView
        let centerY = tableView.contentOffset.y + tableView.frame.height/2
        
        var minIndex = 0
        var minValue = fabs(tableView.visibileCells.first!.frame.origin.y + tableView.visibileCells.first!.frame.height/2 - centerY)
        for (index, cell) in tableView.visibileCells.enumerated() {
            if fabs(cell.frame.origin.y + cell.frame.height/2 - centerY) < minValue {
                minValue = fabs(cell.frame.origin.y - centerY)
                minIndex = index
            }
        }
        return minIndex
    }
    
    fileprivate func transformCellLayer(scrollView: UIScrollView) {
        let currCenterOffset = scrollView.contentOffset.y + scrollView.frame.height/2
        let tableView = scrollView as! DLTableView
        for cell in tableView.visibileCells {
            let distanceFromCenter = currCenterOffset - cell.frame.origin.y
            let disPercent = distanceFromCenter / scrollView.frame.height * 2
            var rotationPerspectiveTrans = CATransform3DIdentity
            rotationPerspectiveTrans.m34 = -1 / 500
            rotationPerspectiveTrans = CATransform3DRotate(rotationPerspectiveTrans, disPercent * CGFloat(M_PI/180 * 65), 1, 0, 0)
            cell.containerView.layer.transform = rotationPerspectiveTrans
        }
    }
}

extension DLPickerView: DLTableViewDelegate, DLTableViewDataSource {
    // MARK:- DLTableViewDataSource
    func tableView(_ tableView: DLTableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfRows(inComponent: tableView.tag)
    }
    
    func tableView(_ tableView: DLTableView, cellForRowAt indexPath: IndexPath) -> DLTableViewCell? {
        var temp = tableView.dequeueReusableCell(withIdentifier: "HelloCell") as? DLPickerViewInternalCell
        if temp == nil {
            temp = DLPickerViewInternalCell.init(style: .Default, reuseIdentifier: "HelloCell")
        }
        let cell = temp!
        cell.containerView.layer.drawsAsynchronously = true
        let cachedCustomView = cachedCustomViews["\(tableView.tag)=\(indexPath.row)"]
        if let arrtTitle = self.delegate?.pickerView?(self, attributedTitleForRow: indexPath.row, forComponent: tableView.tag) {
            cell.titleLabel.isHidden = false
            cell.customView.isHidden = true
            cell.titleLabel.attributedText = arrtTitle
        } else if let title = self.delegate?.pickerView?(self, titleForRow: indexPath.row, forComponent: tableView.tag) {
            cell.titleLabel.isHidden = false
            cell.customView.isHidden = true
            cell.titleLabel.text = title
        } else if let view = self.delegate?.pickerView?(self, viewForRow: indexPath.row, forComponent: tableView.tag, reusing: cachedCustomView) {
            if cachedCustomView != view {
                // FIX: if there are too many rows in the component, memory usage will be high.
                cachedCustomViews["\(tableView.tag)=\(indexPath.row)"] = view
            }
            view.frame.origin.x = tableView.frame.width/2 - view.frame.width/2
            if let height = self.delegate?.pickerView?(self, rowHeightForComponent: tableView.tag) {
                view.frame.origin.y = height/2 - view.frame.height/2
            } else if let height = self.delegate?.pickerView?(self, rowHeightForRow: indexPath.row, inComponent: tableView.tag) {
                view.frame.origin.y = height/2 - view.frame.height/2
            } else {
                view.frame.origin.y = DLPickerView.DefaultRowHeight/2 - view.frame.height/2
            }
            cell.titleLabel.isHidden = true
            cell.customView.isHidden = false
            cell.customView.removeAllSubviews()
            cell.customView.addSubview(view)
        } else {
            assert(false)
        }
        playSoundEffect()
        playJustOnce = true
        return cell
    }
    
    // MARK:- DLTableViewDelegate
    func tableView(_ tableView: DLTableView, didEndDisplaying cell: DLTableViewCell, forRowAt indexPath: IndexPath) {
        if !tableView.enableCycleScroll {
            if playJustOnce {
                playJustOnce = false
                return
            }
            playSoundEffect()
        }
    }
    
    func tableView(_ tableView: DLTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = self.delegate?.pickerView?(self, rowHeightForComponent: tableView.tag) {
            return height
        }
        if let height = self.delegate?.pickerView?(self, rowHeightForRow: indexPath.row, inComponent: tableView.tag) {
            return height
        }
        return DLPickerView.DefaultRowHeight
    }
    
    // MARK:- UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let tableView = scrollView as! DLTableView
        transformCellLayer(scrollView: scrollView)
        selectionIndicatorViews[tableView.tag].setNeedsDisplay()
        if !self.hasMakeSureNotOutOfRange[scrollView.tag]
            && makeSureNotScrollOutOfRange(scrollView: scrollView, needScrollWhenOut: true) {
            self.hasMakeSureNotOutOfRange[scrollView.tag] = true
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isUserDraggingComponents[scrollView.tag] = true
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
     //   self.isUserDraggingComponents[scrollView.tag] = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.isUserDraggingComponents[scrollView.tag] = false
        if !decelerate {
            if !self.hasMakeSureNotOutOfRange[scrollView.tag] && makeSureNotScrollOutOfRange(scrollView: scrollView, needScrollWhenOut: true) {
                self.hasMakeSureNotOutOfRange[scrollView.tag] = true
                return
            }
            scrollToCenter(scrollView: scrollView, animated: true)
            makeSureIndicatorViewsShowRight(delay: 0.5)
            toggleSelectedActionIfNeeded(tableView: scrollView as! DLTableView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToCenter(scrollView: scrollView, animated: true)
        makeSureIndicatorViewsShowRight(delay: 0.5)
        toggleSelectedActionIfNeeded(tableView: scrollView as! DLTableView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.hasMakeSureNotOutOfRange[scrollView.tag] = false
        makeSureIndicatorViewsShowRight(delay: 0.5)
        toggleSelectedActionIfNeeded(tableView: scrollView as! DLTableView)
    }
}
