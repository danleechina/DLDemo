//
//  DLPickerView
//  DLDemo
//
//  Created by Dan.Lee on 2016/10/22.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

import UIKit

protocol DLPickerViewDataSource : NSObjectProtocol {
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: DLPickerView) -> Int
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: DLPickerView, numberOfRowsInComponent component: Int) -> Int
}

@objc protocol DLPickerViewDelegate : NSObjectProtocol {
    // returns width of column and height of row for each component.
    @objc
    optional func pickerView(_ pickerView: DLPickerView, widthForComponent component: Int) -> CGFloat
    
    @objc
    optional func pickerView(_ pickerView: DLPickerView, rowHeightForComponent component: Int) -> CGFloat
    
    // these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
    // for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
    // If you return back a different object, the old one will be released. the view will be centered in the row rect
    @objc
    optional func pickerView(_ pickerView: DLPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    
    @objc
    optional func pickerView(_ pickerView: DLPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? // attributed title is favored if both methods are implemented
    
    @objc
    optional func pickerView(_ pickerView: DLPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    
    @objc
    optional func pickerView(_ pickerView: DLPickerView, didSelectRow row: Int, inComponent component: Int)
    
    /*      ------------------------------------------------
            Following methods are specific for DLPickerView
            ------------------------------------------------
     */
    
    // whether or not the specific component can cycle scroll
    @objc
    optional func enableCycleScroll(in pickerView: DLPickerView, forComponent component: Int) -> Bool
    
    // if pickerView(_ pickerView: DLPickerView, rowHeightForComponent component: Int) -> CGFloat is implemented, this will not be invoked
    @objc
    optional func pickerView(_ pickerView: DLPickerView, rowHeightForRow row: Int, inComponent component: Int) -> CGFloat
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
            titleLabel.frame = CGRect(x: self.frame.width/4, y: 0, width: self.frame.width/2, height: self.frame.height)
            customView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        }
    }
    
    override init(style: DLTableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(customView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    fileprivate var containerView = UIView()
    fileprivate static let DefaultRowHeight:CGFloat = 44
    fileprivate var cachedCustomViews = Dictionary<String, UIView>()
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
            
            self.tableViews.append(tableView)
            self.containerView.addSubview(tableView)
            
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
    }
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
        cell.titleLabel.font = UIFont.systemFont(ofSize: 13)
        return cell
    }
    
    // delegate
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
        self.delegate?.pickerView?(self, didSelectRow: indexPath.row, inComponent: tableView.tag)
        tableView.scrollToRow(at: indexPath, withInternalIndex: nil, at: .middle, animated: true)
        tableView.deselectRow(at: indexPath, withInternalIndex: nil, animated: true)
    }
    
    func tableView(_ tableView: DLTableView, didSelectRowAt indexPath: IndexPath, withInternalIndex index: Int) {
        self.delegate?.pickerView?(self, didSelectRow: indexPath.row, inComponent: tableView.tag)
        tableView.scrollToRow(at: indexPath, withInternalIndex: index, at: .middle, animated: true)
        tableView.deselectRow(at: indexPath, withInternalIndex: index, animated: true)
    }
    
    // scrollview delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToCenter(scrollView: scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToCenter(scrollView: scrollView)
    }
    
    func scrollToCenter(scrollView: UIScrollView) {
        let tableView = scrollView as! DLTableView
        let centerY = tableView.contentOffset.y + tableView.frame.height/2
        
        var minIndex = 0
        var minValue = fabs(tableView.visibileCells.first!.frame.origin.y - centerY)
        for (index, cell) in tableView.visibileCells.enumerated() {
            if fabs(cell.frame.origin.y - centerY) < minValue {
                minValue = fabs(cell.frame.origin.y - centerY)
                minIndex = index
            }
        }
        tableView.scrollToRow(at: tableView.visibileCellsIndexPath[minIndex], withInternalIndex: nil, at: .middle, animated: true)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    }
}
