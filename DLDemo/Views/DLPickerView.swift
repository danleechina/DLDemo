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
            Following methods are Specific for DLPickerView
            ------------------------------------------------
     */
    
    // whether or not the specific component can cycle scroll
    @objc
    optional func enableCycleScroll(in pickerView: DLPickerView, forComponent component: Int) -> Bool
    
    // if pickerView(_ pickerView: DLPickerView, rowHeightForComponent component: Int) -> CGFloat is implemented, this will not be invoked
    @objc
    optional func pickerView(_ pickerView: DLPickerView, rowHeightForRow row: Int, inComponent component: Int) -> CGFloat
}

class DLPickerView : UIView {
    
    weak var dataSource: DLPickerViewDataSource? {// default is nil. weak reference
        didSet {
            if let ds = self.dataSource {
                self.numberOfComponents = ds.numberOfComponents(in: self)
            } else {
                self.numberOfComponents = 0
            }
        }
    }
    
    weak var delegate: DLPickerViewDelegate? // default is nil. weak reference
    
    var showsSelectionIndicator: Bool // default is NO
    
    // info that was fetched and cached from the data source and delegate
    var numberOfComponents: Int {
        didSet {
            self.tableViews.forEach({$0.removeFromSuperview()})
            self.tableViews.removeAll()
            for index in 0 ..< numberOfComponents {
                let tableView = DLTableView()
                tableView.tag = index
                tableView.delegate = self
                tableView.dataSource = self
                if let enableCycleScroll = self.delegate?.enableCycleScroll?(in: self, forComponent: index) {
                    tableView.enableCycleScroll = enableCycleScroll
                } else {
                    tableView.enableCycleScroll = false
                }
                if let width = self.delegate?.pickerView?(self, widthForComponent: index) {
                    tableView.frame.size.width = width
                } else {
                    tableView.frame.size.width = self.frame.width / CGFloat(numberOfComponents)
                }
                self.tableViews.append(tableView)
                self.containerView.addSubview(tableView)
            }
        }
    }
    
    func numberOfRows(inComponent component: Int) -> Int {
        if let ds = self.dataSource {
            return ds.pickerView(self, numberOfRowsInComponent: component)
        }
        return 0
    }
    
    func rowSize(forComponent component: Int) -> CGSize {
        return CGSize(width: 0, height: 0)
    }
    
    // returns the view provided by the delegate via pickerView:viewForRow:forComponent:reusingView:
    // or nil if the row/component is not visible or the delegate does not implement
    // pickerView:viewForRow:forComponent:reusingView:
    func view(forRow row: Int, forComponent component: Int) -> UIView? {
        return nil
    }
    
    // Reloading whole view or single component
    func reloadAllComponents() {
        
    }
    
    func reloadComponent(_ component: Int) {
        
    }
    
    // selection. in this case, it means showing the appropriate row in the middle
    func selectRow(_ row: Int, inComponent component: Int, animated: Bool){ // scrolls the specified row to center.
    }
    
    
    func selectedRow(inComponent component: Int) -> Int{ // returns selected row. -1 if nothing selected
        return 0
    }
    
    override var frame: CGRect {
        didSet {
            containerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        }
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
    
}

extension DLPickerView: DLTableViewDelegate, DLTableViewDataSource {
    // dataSource
    func tableView(_ tableView: DLTableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfRows(inComponent: tableView.tag)
    }
    
    func tableView(_ tableView: DLTableView, cellForRowAt indexPath: IndexPath) -> DLTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelloCell")
        cell.titleLabel.text = "r:\(indexPath.row) c:\(tableView.tag)"
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
}
