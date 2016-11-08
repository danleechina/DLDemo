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
    
    /*      ------------------------------------------------
            Following methods are specific for DLPickerView
            ------------------------------------------------
     */
    
    // whether or not the specific component can cycle scroll
    @objc optional func enableCycleScroll(in pickerView: DLPickerView, forComponent component: Int) -> Bool
    
    // if pickerView(_ pickerView: DLPickerView, rowHeightForComponent component: Int) -> CGFloat is implemented, this will not be invoked
    @objc optional func pickerView(_ pickerView: DLPickerView, rowHeightForRow row: Int, inComponent component: Int) -> CGFloat
    
    // only specific cell of the component within the returned range can stop at center
    @objc optional func pickerView(_ pickerView: DLPickerView, enableScrollWithinRangeForComponent component: Int) -> Bool
    @objc optional func pickerView(_ pickerView: DLPickerView, getRangeForScrollInComponent component: Int) -> NSRange
}

enum DLPickerViewLayoutStyle {
    case Vertical
    case Horizontal
}

enum DLPickerViewStyle {
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
    weak var magnifyingView: UIView?
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

class DLPickerView : UIView {
    
    weak var dataSource: DLPickerViewDataSource? // default is nil. weak reference
    
    weak var delegate: DLPickerViewDelegate? // default is nil. weak reference
    
    var showsSelectionIndicator: Bool // default is NO
    
    // info that was fetched and cached from the data source and delegate
    var numberOfComponents: Int
    
    func numberOfRows(inComponent component: Int) -> Int {
        if let ds = self.dataSource {
            return ds.pickerView(self, numberOfRowsInComponent: component)
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
        self.tableViews.forEach({
            $0.reloadViews()
        })
    }
    
    func reloadComponent(_ component: Int) {
        setAppearance()
        self.tableViews[component].reloadViews()
    }
    
    // selection. in this case, it means showing the appropriate row in the middle
    func selectRow(_ row: Int, inComponent component: Int, animated: Bool){ // scrolls the specified row to center.
        self.tableViews[component].scrollToRow(at: IndexPath.init(row: row, section: 0), at: .middle, animated: true)
    }
    
    
    func selectedRow(inComponent component: Int) -> Int{ // returns selected row. -1 if nothing selected
        return 0
    }
    
    override init(frame: CGRect) {
        showsSelectionIndicator = false
        numberOfComponents = 0
        super.init(frame: frame)
        addSubview(containerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var tableViews = Array<DLTableView>()
    fileprivate var scrollWithinContentOffset = [[CGPoint]]()
    fileprivate var isUserDraggingComponents = Array< Bool >()
    fileprivate var hasMakeSureNotOutOfRange = [Bool]()
    fileprivate var initCountOfCell = Array<Int>()
    fileprivate var hasFinishInitTableViewCount = 0 {
        didSet {
            if hasFinishInitTableViewCount == self.tableViews.count {
                hasFinishAll = true
            }
        }
    }
    fileprivate var hasFinishAll = false {
        didSet {
            if hasFinishAll {
                for tableView in self.tableViews {
                    scrollToCenter(scrollView: tableView)
                    transformCellLayer(scrollView: tableView)
                }
                perform(#selector(nowWeCanPlaySound), with: nil, afterDelay: 0.5)
                
                for (idx, tableView) in tableViews.enumerated() {
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
    }
    func nowWeCanPlaySound() {
        canPlaySound = true
    }
    fileprivate var canPlaySound = false
    fileprivate var containerView = UIView()
    fileprivate static let DefaultRowHeight:CGFloat = 40
    fileprivate var cachedCustomViews = Dictionary<String, UIView>()
    fileprivate var selectionIndicatorViews = Array<DLPickerViewInternalMagnifyingView>()
    
    var layoutStyle = DLPickerViewLayoutStyle.Horizontal {
        didSet {
            // This is ugly but simple, and everything inside is transformed. typically, you'd better not use it.
            // If you really want a vertical layout, you should be careful about the transformed content.
            // You can anti-transform a square content when you set.
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
    
    fileprivate func setAppearance() {
        containerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        if let ds = self.dataSource {
            self.numberOfComponents = ds.numberOfComponents(in: self)
        } else {
            self.numberOfComponents = 0
        }
        
        self.tableViews.forEach({$0.removeFromSuperview()})
        self.tableViews.removeAll()
        self.isUserDraggingComponents.removeAll()
        self.hasMakeSureNotOutOfRange.removeAll()
        self.selectionIndicatorViews.removeAll()
        self.scrollWithinContentOffset.removeAll()
        for index in 0 ..< numberOfComponents {
            let tableView = DLTableView()
            tableView.tag = index
            tableView.delegate = self
            tableView.tableViewDelegate = self
            tableView.dataSource = self
            if let enableCycleScroll = self.delegate?.enableCycleScroll?(in: self, forComponent: index) {
                tableView.enableCycleScroll = enableCycleScroll
            } else {
                tableView.enableCycleScroll = false
            }
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
            
            if !tableView.enableCycleScroll {
                
                var lastCellHeight = DLPickerView.DefaultRowHeight
                var firstCellHeight = DLPickerView.DefaultRowHeight
                if let height = self.delegate?.pickerView?(self, rowHeightForComponent: tableView.tag) {
                    lastCellHeight = height
                    firstCellHeight = height
                } else if let height = self.delegate?.pickerView?(self, rowHeightForRow: 0, inComponent: tableView.tag) {
                    firstCellHeight = height
                    lastCellHeight = self.delegate!.pickerView!(self, rowHeightForRow: tableView.numberOfRows(inSection: 0) - 1, inComponent: tableView.tag)
                }
                
                tableView.tableHeaderView = UIView()
                tableView.tableFooterView = UIView()
                tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height/2 - firstCellHeight/2)
                tableView.tableFooterView?.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.height/2 - lastCellHeight/2)
                tableView.tableHeaderView?.backgroundColor = UIColor.purple
                tableView.tableFooterView?.backgroundColor = UIColor.yellow
            }
            tableView.selectedColor = UIColor.clear
            self.tableViews.append(tableView)
            self.isUserDraggingComponents.append(false)
            self.hasMakeSureNotOutOfRange.append(false)
            self.containerView.addSubview(tableView)
            
            let selectionIndicatorView = DLPickerViewInternalMagnifyingView()
            selectionIndicatorView.magnifyingView = self.containerView
            selectionIndicatorView.backgroundColor = UIColor.clear
            selectionIndicatorView.isUserInteractionEnabled = false
            selectionIndicatorView.frame = CGRect(x: frame.origin.x, y: frame.height/2 - DLPickerView.DefaultRowHeight/2, width: frame.width, height: DLPickerView.DefaultRowHeight)

            self.selectionIndicatorViews.append(selectionIndicatorView)
            self.addSubview(selectionIndicatorView)

            if index == 0 {
                tableView.backgroundColor = UIColor.white
            } else if index == 1 {
                tableView.backgroundColor = UIColor.green
            } else if index == 2 {
                tableView.backgroundColor = UIColor.red
            } else if index == 3 {
                tableView.backgroundColor = UIColor.purple
            }
        }
        
        initInitCountOfCell()
    }
    
    func initInitCountOfCell() {
        hasFinishInitTableViewCount = 0
        hasFinishAll = false
        canPlaySound = false
        initCountOfCell.removeAll()
        for table in tableViews {
            var cnt = 0
            var height: CGFloat = 0
            if table.tableHeaderView != nil {
                height += table.tableHeaderView!.frame.height
            }
            let numberOfCell = table.dataSource?.tableView(table, numberOfRowsInSection: 0)
            var indexOfRow = 0
            while height < table.frame.height {
                if let ch = table.tableViewDelegate?.tableView?(table, heightForRowAt: IndexPath.init(row: indexOfRow, section: 0)) {
                    height += ch
                } else {
                    height += DLPickerView.DefaultRowHeight
                }
                cnt += 1
                indexOfRow += 1
                if indexOfRow > numberOfCell! - 1 {
                    if !table.enableCycleScroll {
                        break
                    } else {
                        indexOfRow = 0
                    }
                }
            }
            initCountOfCell.append(cnt)
        }
    }
    
    static private var mySound:SystemSoundID = {
        var aSound:SystemSoundID = 1000
        if let soundURL = Bundle.main.url(forResource: "clockwork", withExtension: "wav") {
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &aSound)
        }
        return aSound
    }()
    
    func playSoundEffect() {
        if canPlaySound && enableScrollSound {
            AudioServicesPlaySystemSound(DLPickerView.mySound)
        }
    }
    
    fileprivate var playJustOnce = true
    // Enable the scroll sound effect as you wish.
    var enableScrollSound = true;
    
}

extension DLPickerView: DLTableViewDelegate, DLTableViewDataSource {
    // dataSource
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
        // sub one is because datasource called before insert into visibileCells
        if tableView.visibileCells.count >= initCountOfCell[tableView.tag] - 1{
            hasFinishInitTableViewCount += 1
        }
        return cell
    }
    
    // delegate
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
    
    func tableView(_ tableView: DLTableView, didSelectRowAt indexPath: IndexPath) {
        if makeSureNotSelectOutOfRangeOfIndexPath(tableView: tableView, indexPath: indexPath) {
            return
        }
        self.delegate?.pickerView?(self, didSelectRow: indexPath.row, inComponent: tableView.tag)
        tableView.scrollToRow(at: indexPath, withInternalIndex: nil, at: .middle, animated: true)
        tableView.deselectRow(at: indexPath, withInternalIndex: nil, animated: true)
    }
    
    func tableView(_ tableView: DLTableView, didSelectRowAt indexPath: IndexPath, withInternalIndex index: Int) {
        if makeSureNotSelectOutOfRangeOfIndexPath(tableView: tableView, indexPath: indexPath) {
            return
        }
        self.delegate?.pickerView?(self, didSelectRow: indexPath.row, inComponent: tableView.tag)
        tableView.scrollToRow(at: indexPath, withInternalIndex: index, at: .middle, animated: true)
        tableView.deselectRow(at: indexPath, withInternalIndex: index, animated: true)
    }
    
    // scrollview delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let tableView = scrollView as! DLTableView
        transformCellLayer(scrollView: scrollView)
        selectionIndicatorViews[tableView.tag].setNeedsDisplay()
        if makeSureNotScrollOutOfRange(scrollView: scrollView, needScrollWhenOut: false) {
            if !self.hasMakeSureNotOutOfRange[scrollView.tag] {
                _ = makeSureNotScrollOutOfRange(scrollView: scrollView, needScrollWhenOut: true)
                self.hasMakeSureNotOutOfRange[scrollView.tag] = true
            }
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
            scrollToCenter(scrollView: scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToCenter(scrollView: scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.hasMakeSureNotOutOfRange[scrollView.tag] = false
    }
    
    func makeSureNotScrollOutOfRange(scrollView: UIScrollView, needScrollWhenOut: Bool) -> Bool {
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
    
    func makeSureNotSelectOutOfRangeOfIndexPath(tableView: DLTableView, indexPath: IndexPath) -> Bool {
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
    
    func scrollToCenter(scrollView: UIScrollView) {
        if makeSureNotScrollOutOfRange(scrollView: scrollView, needScrollWhenOut: false) {
            return
        }
        let tableView = scrollView as! DLTableView
        let centerY = tableView.contentOffset.y + tableView.frame.height/2
        
        var minIndex = 0
        var minValue = fabs(tableView.visibileCells.first!.frame.origin.y - centerY)
        for (index, cell) in tableView.visibileCells.enumerated() {
            if fabs(cell.frame.origin.y + cell.frame.height/2 - centerY) < minValue {
                minValue = fabs(cell.frame.origin.y - centerY)
                minIndex = index
            }
        }
        tableView.scrollToRow(at: tableView.visibileCellsIndexPath[minIndex], withInternalIndex: minIndex, at: .middle, animated: true)

    }
    
    func transformCellLayer(scrollView: UIScrollView) {
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
