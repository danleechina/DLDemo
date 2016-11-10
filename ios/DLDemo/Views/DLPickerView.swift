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
    /* implement both of these methods, none of them are optional */
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: DLPickerView) -> Int
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: DLPickerView, numberOfRowsInComponent component: Int) -> Int
}

@objc protocol DLPickerViewDelegate : NSObjectProtocol {
    /*
                    ---------------------------------------------------------------------
     
                            Following methods are from system UIPickerViewDelegate
     
                    ---------------------------------------------------------------------
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
                    ---------------------------------------------------------------------
             
                        Following methods are specific for DLPickerViewDelegete, 
                        Check out these methods if you want a different picker view!
             
                    ---------------------------------------------------------------------
     */
    
    // make using DLPickerView just like UITableView, if you implement the methods that return title, attributedTitle or view, this method will not be invoked
    @objc optional func pickerView(_ pickerView: DLPickerView, cellForRow row: Int, forComponent component: Int) -> DLPickerViewCell
    
    // whether or not the specific component can scroll cyclically
    @objc optional func enableCycleScroll(in pickerView: DLPickerView, forComponent component: Int) -> Bool
    
    // if pickerView(_ pickerView: DLPickerView, rowHeightForComponent component: Int) -> CGFloat is implemented, this will not be invoked
    // But it's not recommended that using different row height for a component because the effect is not good.
    @objc optional func pickerView(_ pickerView: DLPickerView, rowHeightForRow row: Int, inComponent component: Int) -> CGFloat
    
    // only specific cells of the component within the returned range can stop at center
    @objc optional func pickerView(_ pickerView: DLPickerView, enableScrollWithinRangeForComponent component: Int) -> Bool
    
    // if enable scroll within range for the component, this method will be invoked. User can scroll between location to location + length - 1, including both end.
    @objc optional func pickerView(_ pickerView: DLPickerView, getRangeForScrollInComponent component: Int) -> NSRange
    
    // custom the indictor view for the component if you want, make sure that you don't return different indicator views for the same component
    // TODO
    @objc optional func pickerView(_ pickerView: DLPickerView, customIndicatorViewForComponent component: Int) -> UIView
    
    // custom the scroll effect, so it scrolls not only like wheel, but can also be the style you want, and also by implementing this method you can make some visual effect to differnt cell. The effect should be based on the position
    // the position means the distance from cell's center to the component's center, and range from -1 to 1, negative value means it is above the center.
    @objc optional func pickerView(_ pickerView: DLPickerView, customScrollEffectForComponent component: Int, withPosition position: CGFloat) -> CATransform3D
    // it isn't recommended that you change the content of cell in this method. Change the cell's visiual effect. Basically return a CATransform3D is enough to change the visiual effect
    @objc optional func pickerView(_ pickerView: DLPickerView, customCellForComponent component: Int, withPosition position: CGFloat, andTheCell: DLPickerViewCell)
}

// layout style for components
enum DLPickerViewLayoutStyle {
    case Vertical
    case Horizontal
}

// selection style of the indicator, currently not using.
enum DLPickerViewSelectionStyle {
    case System
    case Custom
}

// inherit this class, make sure your every subview is added to containerView.
class DLPickerViewCell: DLTableViewCell {
    override var frame: CGRect {
        didSet {
            customView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        }
    }
    
    // using customized style, if you want to custom the cell.
    override init(style: DLTableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        containerView.addSubview(customView)
        titleLabel.font = UIFont.systemFont(ofSize: 23)
        titleLabel.textColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var customView = UIView()
}

// FIXME: when enable scroll range, indicator view may jump when animation ends. We should find out a better way to draw DLPickerViewInternalMagnifyingView.
// TODO: customized indicator view for different components.

/*
 
 DLPickerView's usage is just the same like UIPickerView, you can use it to replace UIPickerView and it works as if you are still using UIPickerView. In other words, UIPickerView is defined once again.

 DLPickerView has these features that UIPickerView doesn't have:

 1. You can make a component scroll cyclically, which means the bottom cell follows by the beginning cell, and the beginning cell is after the bottom cell. And this is not a fake effect, it is really scroll cyclically.
 2. You can make a component scroll within a specific range. And user can't scroll or select the cell out of the range.
 3. You can make a different layout of components, for example, components can be listed in vertically, not only in horizontally.
 4. You can use DLPickerView like UITableView, and just inherit DLPickerViewCell to implement your own customized cell class.
 5. You can disable the scroll sound effect if you want, and you can also custom the scroll sound effect.
 6. You can custom the scrol effect, so it scrolls not only like wheel, but can also be the style you want. And make some visual effect to the cell based on the cell's position.
 7. You can adjust the scale value of center indicator view by setting magnifyingViewScale.
 8. You can set night mode if you want.
 
 ... If you have some other ideas about the DLPickerView, please let me know.

 Some using advices:
 
 1. If you change some properties, make sure to invoke reloadComponent or reloadAllComponent methods.
 2. If you use different row height for a component, be sure to set showsSelectionIndicator to false.
 3. The custom indicator view for different components has not been currently finished developing, and I am think about how many people want this? I think system-provide-style is good enough.
 
 ... I will be grateful to you if you report some bugs to me.
 
*/

class DLPickerView : UIView {
    // MARK: - Open API, mix the UIPickView and some custom methods, properties
    
    // default is nil. weak reference
    weak var dataSource: DLPickerViewDataSource?
    // default is nil. weak reference
    weak var delegate: DLPickerViewDelegate?
    // default is true
    var showsSelectionIndicator = true {
        didSet {
            topIndicatorLine.isHidden = !showsSelectionIndicator
            bottomIndicatorLine.isHidden = !showsSelectionIndicator
            self.selectionIndicatorViews.forEach({$0.isHidden = !showsSelectionIndicator})
        }
    }
    
    // the exist of mask views make DLPickerView like UIPickerView, but you can also disable it. default is true
    var showMaskViewsForSystemEffect = true {
        didSet {
            topMaskView.isHidden = !showMaskViewsForSystemEffect
            centerMaskView.isHidden = !showMaskViewsForSystemEffect
            bottomMaskView.isHidden = !showMaskViewsForSystemEffect
        }
    }

    // info that was fetched and cached from the data source and delegate
    private(set) var numberOfComponents: Int
    // Enable the scroll sound effect if you want, default is true
    var enableScrollSound = true
    
    // layout style for components
    var layoutStyle = DLPickerViewLayoutStyle.Horizontal {
        didSet {
            // Everything inside is transformed.
            // If you want a vertical layout, you should be careful about the transformed content.
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
    
    // change the scale value of center magnify view.
    var magnifyingViewScale = 1.04 {
        didSet {
            selectionIndicatorViews.forEach({$0.scale = magnifyingViewScale})
        }
    }
    
    // enable night mode, night mode isn't responsible for the content of the cell. default is false
    var enableNightMode = false {
        didSet {
            if enableNightMode {
                self.backgroundColor = UIColor.black
            } else {
                self.backgroundColor = UIColor.white
            }
        }
    }
    
    // customized scroll sound effect, the sound source should be about 1~2 second
    var soundURL: URL? {
        didSet {
            if let surl = soundURL {
                var aSound = DLPickerView.mySound
                AudioServicesCreateSystemSoundID(surl as CFURL, &aSound)
                DLPickerView.mySound = aSound
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
        if self.tableViews.count <= component {
            return CGSize(width: 0, height: 0)
        }
        let tableView = self.tableViews[component]
        return CGSize(width: tableView.frame.width, height: tableView.tableViewDelegate!.tableView!(tableView, heightForRowAt: IndexPath.init(row: row, section: 0)))
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
        if self.tableViews.count <= component {
            return
        }
        self.tableViews[component].reloadViews()
    }
    
    // selection. in this case, it means showing the appropriate row in the middle
    func selectRow(_ row: Int, inComponent component: Int, animated: Bool){ // scrolls the specified row to center.
        if self.tableViews.count <= component {
            return
        }
        self.tableViews[component].scrollToRow(at: IndexPath.init(row: row, section: 0), at: .middle, animated: true)
    }
    
    // returns selected row. -1 if nothing selected
    func selectedRow(inComponent component: Int) -> Int{
        if self.lastSelectedRow.count <= component {
            return -1
        }
        return self.lastSelectedRow[component]
    }
    
    override init(frame: CGRect) {
        numberOfComponents = 0
        super.init(frame: frame)
        addSubview(containerView)
        addSubview(topIndicatorLine)
        addSubview(bottomIndicatorLine)
        addSubview(topMaskView)
        addSubview(centerMaskView)
        addSubview(bottomMaskView)
        topIndicatorLine.isHidden = false
        bottomIndicatorLine.isHidden = false
        topMaskView.isUserInteractionEnabled = false
        centerMaskView.isUserInteractionEnabled = false
        bottomMaskView.isUserInteractionEnabled = false
        self.addGestureRecognizer(tapGest)
        self.addGestureRecognizer(longPressGest)
        backgroundColor = UIColor.white
        
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
    fileprivate var isUserDraggingComponents            = [Bool ]()
    fileprivate var hasMakeSureNotOutOfRange            = [Bool]()
    fileprivate var lastSelectedRow                     = [Int]()
    fileprivate var canPlaySound                        = false
    fileprivate var usingPickerViewLikeTabelView        = false
    fileprivate var topMaskView                         = UIView()
    fileprivate var centerMaskView                      = UIView()
    fileprivate var bottomMaskView                      = UIView()
    fileprivate var lastCenterRows                      = [Int]()
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
        let longPressGest = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressDetected(sender:)))
        longPressGest.minimumPressDuration = 0.1
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
    
    @objc fileprivate func longPressDetected(sender: UILongPressGestureRecognizer) {
        // print("longPressDetected")
    }
    
    fileprivate func setAppearance() {
        usingPickerViewLikeTabelView = false
        containerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        topIndicatorLine.frame = CGRect(x: 0, y: frame.height/2 - DLPickerView.DefaultRowHeight/2 - 1, width: frame.width, height: 1)
        bottomIndicatorLine.frame = CGRect(x: 0, y: frame.height/2 + DLPickerView.DefaultRowHeight/2 , width: frame.width, height: 1)
        
        topMaskView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height/2 - DLPickerView.DefaultRowHeight/2)
        centerMaskView.frame = CGRect(x: 0, y: frame.height/2 - DLPickerView.DefaultRowHeight/2, width: frame.width, height: DLPickerView.DefaultRowHeight)
        bottomMaskView.frame = CGRect(x: 0, y: frame.height/2 + DLPickerView.DefaultRowHeight/2, width: frame.width, height: frame.height/2 - DLPickerView.DefaultRowHeight/2)
        
        if enableNightMode {
            topIndicatorLine.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            bottomIndicatorLine.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            topMaskView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            centerMaskView.backgroundColor = UIColor.clear
            bottomMaskView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        } else {
            topIndicatorLine.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            bottomIndicatorLine.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            topMaskView.backgroundColor = UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 0.55)
            centerMaskView.backgroundColor = UIColor.clear
            bottomMaskView.backgroundColor = UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 0.55)
        }

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
        self.lastSelectedRow.removeAll()
        self.customSelectionIndicatorViews.removeAll()
        self.lastCenterRows.removeAll()
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
            var firstCellHeight = DLPickerView.DefaultRowHeight
            var lastCellHeight = DLPickerView.DefaultRowHeight
            if !tableView.enableCycleScroll {
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
            selectionIndicatorView.frame = CGRect(x: frame.origin.x, y: frame.height/2 - firstCellHeight/2, width: frame.width, height: firstCellHeight)
            
            // TODO: selection style for customing
            
            // step 6: update array and view
            self.tableViews.append(tableView)
            self.isUserDraggingComponents.append(false)
            self.hasMakeSureNotOutOfRange.append(false)
            self.lastSelectedRow.append(-1)
            self.lastCenterRows.append(-1)
            self.selectionIndicatorViews.append(selectionIndicatorView)
            self.containerView.addSubview(tableView)
            self.addSubview(selectionIndicatorView)
        }
        
        // Make components center
        let remainSpaceInHorizontal = self.frame.width - self.tableViews.last!.frame.maxX
        if  remainSpaceInHorizontal > 1 {
            let offsetX = remainSpaceInHorizontal/2
            tableViews.forEach({$0.frame.origin.x += offsetX})
            selectionIndicatorViews.forEach({$0.frame.origin.x += offsetX})
        }
        
        selectionIndicatorViews.forEach({$0.scale = magnifyingViewScale})
        initAppearance(delay: 0.05)
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
        if minIndex == -1 {
            return
        }
        let indexPath = tableView.visibileCellsIndexPath[minIndex]
        if indexPath.row != self.lastSelectedRow[tableView.tag]
            && !isSelectedOutOfRangeOfIndexPath(tableView: tableView, indexPath: indexPath) {
            self.delegate?.pickerView?(self, didSelectRow: indexPath.row, inComponent: tableView.tag)
            self.lastSelectedRow[tableView.tag] = indexPath.row
        }
    }
    
    fileprivate func makeSureNotScrollOutOfRange(scrollView: UIScrollView, needScrollWhenOut: Bool) -> Bool {
        let tableView = scrollView as! DLTableView
        if let enableScrollRange = self.delegate?.pickerView?(self, enableScrollWithinRangeForComponent: tableView.tag) {
            if enableScrollRange {
                if let range = self.delegate?.pickerView?(self, getRangeForScrollInComponent: tableView.tag) {
                    let minIndex = getIndexWhichIsTheClosestToCenter(scrollView: scrollView)
                    if minIndex == -1 {
                        return false
                    }
                    let centerIndexPath = tableView.visibileCellsIndexPath[minIndex]
                    if centerIndexPath.row <  range.location {
                        if needScrollWhenOut {
                            tableView.scrollToRow(at: IndexPath.init(row: range.location, section: 0), at: .middle, animated: true)
                        }
                        return true
                    } else if centerIndexPath.row > range.location + range.length - 1 {
                        if needScrollWhenOut {
                            tableView.scrollToRow(at: IndexPath.init(row: range.location + range.length - 1, section: 0), at: .middle, animated: true)
                        }
                        return true
                    }
                }
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
        if minIndex == -1 {
            return
        }
        tableView.scrollToRow(at: tableView.visibileCellsIndexPath[minIndex], withInternalIndex: minIndex, at: .middle, animated: animated)
    }
    
    fileprivate func getIndexWhichIsTheClosestToCenter(scrollView: UIScrollView) -> Int {
        let tableView = scrollView as! DLTableView
        let centerY = tableView.contentOffset.y + tableView.frame.height/2
        
        var minIndex = -1
        if let firstCell = tableView.visibileCells.first {
            minIndex = 0
            var minValue = fabs(firstCell.frame.origin.y + firstCell.frame.height/2 - centerY)
            for (index, cell) in tableView.visibileCells.enumerated() {
                if fabs(cell.frame.origin.y + cell.frame.height/2 - centerY) < minValue {
                    minValue = fabs(cell.frame.origin.y - centerY)
                    minIndex = index
                }
            }
        }
        return minIndex
    }
    
    fileprivate func transformCellLayer(scrollView: UIScrollView) {
        let currCenterOffset = scrollView.contentOffset.y + scrollView.frame.height/2
        let tableView = scrollView as! DLTableView
        for cell in tableView.visibileCells {
            let distanceFromCenter = currCenterOffset - cell.frame.origin.y - cell.frame.height/2
            var disPercent = distanceFromCenter / (scrollView.frame.height / 2)
            if disPercent < -1 {
                disPercent = CGFloat(-1)
            } else if disPercent > 1 {
                disPercent = CGFloat(1)
            }
            if let transform = self.delegate?.pickerView?(self, customScrollEffectForComponent: scrollView.tag, withPosition: disPercent) {
                cell.containerView.layer.transform = transform
            } else {
                var rotationPerspectiveTrans = CATransform3DIdentity
                rotationPerspectiveTrans.m34 = -1 / 500
                rotationPerspectiveTrans = CATransform3DRotate(rotationPerspectiveTrans, disPercent * CGFloat(M_PI/180 * 65), 1, 0, 0)
                cell.containerView.layer.transform = rotationPerspectiveTrans
            }
        }
    }
    
    // MARK: - TODO
    
    // you can set the custom selection indicator view in this array, also you can implement the protocol method in DLPickerViewDelegate
    // these two kinds of ways are the same.
    // currently not using.
    fileprivate var customSelectionIndicatorViews = [UIView]()
    // provide single indicator for all components, if we use this, customSelectionIndicatorViews will not be used.
    // currently not using.
    fileprivate var customSelectionIndicatorView: UIView?
    // currently not using.
    fileprivate var selectionStyle = DLPickerViewSelectionStyle.System {
        didSet {
            if selectionStyle == .Custom {
            } else {
                showsSelectionIndicator = true
            }
        }
    }
}

extension DLPickerView: DLTableViewDelegate, DLTableViewDataSource {
    // MARK:- DLTableViewDataSource
    
    func tableView(_ tableView: DLTableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfRows(inComponent: tableView.tag)
    }
    
    func tableView(_ tableView: DLTableView, cellForRowAt indexPath: IndexPath) -> DLTableViewCell? {
        if usingPickerViewLikeTabelView {
            if let cell = self.delegate?.pickerView?(self, cellForRow: indexPath.row, forComponent: tableView.tag) {
                usingPickerViewLikeTabelView = true
                return cell
            } else {
                assert(false, "You should implement at least one method to return title, attributedTitle, view, or cell for row")
            }
        }
        var temp = tableView.dequeueReusableCell(withIdentifier: "DLPickViewInternalCell") as? DLPickerViewCell
        if temp == nil {
            temp = DLPickerViewCell.init(style: .Default, reuseIdentifier: "DLPickViewInternalCell")
            switch layoutStyle {
            case .Horizontal:
                //temp!.titleLabel.transform = CGAffineTransform(rotationAngle: 0)
                temp!.containerView.subviews.forEach({$0.transform = CGAffineTransform(rotationAngle: 0);})
                break
            case .Vertical:
                //temp!.titleLabel.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI/2))
                temp!.containerView.subviews.forEach({$0.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI/2));})
                break
            }
            if enableNightMode {
                temp?.titleLabel.textColor = UIColor.white
            } else {
                temp?.titleLabel.textColor = UIColor.black
            }
            //temp?.backgroundColor = UIColor.randomColor()
        }
        let cell = temp!
        cell.containerView.layer.drawsAsynchronously = true
        let cachedCustomView = cachedCustomViews["\(tableView.tag)=\(indexPath.row)"]
        if let arrtTitle = self.delegate?.pickerView?(self, attributedTitleForRow: indexPath.row, forComponent: tableView.tag) {
            cell.titleLabel.isHidden = false
            cell.customView.isHidden = true
            cell.titleLabel.text = nil
            cell.titleLabel.attributedText = arrtTitle
        } else if let title = self.delegate?.pickerView?(self, titleForRow: indexPath.row, forComponent: tableView.tag) {
            cell.titleLabel.isHidden = false
            cell.customView.isHidden = true
            cell.titleLabel.attributedText = nil
            cell.titleLabel.text = title
        } else if let view = self.delegate?.pickerView?(self, viewForRow: indexPath.row, forComponent: tableView.tag, reusing: cachedCustomView) {
            if cachedCustomView != view {
                // FIXME: if there are too many rows in the component, memory usage will be high.
                cachedCustomViews["\(tableView.tag)=\(indexPath.row)"] = view
            }
            cell.titleLabel.isHidden = true
            cell.customView.isHidden = false
            cell.customView.removeAllSubviews()
            cell.customView.addSubview(view)
        } else if let icell = self.delegate?.pickerView?(self, cellForRow: indexPath.row, forComponent: tableView.tag) {
            usingPickerViewLikeTabelView = true
            return icell
        } else {
            assert(false, "You should implement at least one method to return title, attributedTitle, view, or cell for row")
        }
        return cell
    }
    
    // MARK:- DLTableViewDelegate
    
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
        let minIndex = getIndexWhichIsTheClosestToCenter(scrollView: scrollView)
        if minIndex == -1 {
            return
        }
        let centerIndexPath = tableView.visibileCellsIndexPath[minIndex]
        if lastCenterRows[tableView.tag] != centerIndexPath.row {
            playSoundEffect()
            lastCenterRows[tableView.tag] = centerIndexPath.row
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
            doSomeEndWork(scrollView: scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        doSomeEndWork(scrollView: scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if !self.hasMakeSureNotOutOfRange[scrollView.tag]
            && makeSureNotScrollOutOfRange(scrollView: scrollView, needScrollWhenOut: true) {
            self.hasMakeSureNotOutOfRange[scrollView.tag] = true
            return
        }
        
        self.hasMakeSureNotOutOfRange[scrollView.tag] = false
        makeSureIndicatorViewsShowRight(delay: 0.05)
        toggleSelectedActionIfNeeded(tableView: scrollView as! DLTableView)
    }
    
    func doSomeEndWork(scrollView: UIScrollView) {
        if !self.hasMakeSureNotOutOfRange[scrollView.tag]
            && makeSureNotScrollOutOfRange(scrollView: scrollView, needScrollWhenOut: true) {
            self.hasMakeSureNotOutOfRange[scrollView.tag] = true
            return
        }
        
        scrollToCenter(scrollView: scrollView, animated: true)
        makeSureIndicatorViewsShowRight(delay: 0.05)
        toggleSelectedActionIfNeeded(tableView: scrollView as! DLTableView)
    }
}

fileprivate class DLPickerViewInternalMagnifyingView: UIView {
    fileprivate weak var magnifyingView: UIView?
    fileprivate var scale = 1.04
    override func draw(_ rect: CGRect) {
        if let magnifyingView = self.magnifyingView {
            let ctx = UIGraphicsGetCurrentContext()
            ctx!.scaleBy(x: CGFloat(scale), y: CGFloat(scale))
            ctx!.translateBy(x: -frame.origin.x, y: -magnifyingView.frame.height/2 + DLPickerView.DefaultRowHeight/2)
            // not sure why this method will crash in ios 8 and working with warning in ios 10
            // magnifyingView.layer.render(in: ctx!)
            magnifyingView.drawHierarchy(in: magnifyingView.bounds, afterScreenUpdates: true)
        }
    }
}
