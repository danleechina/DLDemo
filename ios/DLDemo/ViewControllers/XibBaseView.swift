//
//  XibBaseView.swift
//  DLDemo
//
//  Created by Dan.Lee on 2017/8/19.
//  Copyright © 2017年 Dan Lee. All rights reserved.
//

import UIKit
import SnapKit

class XibBaseView: UIView {
    
    var contentView : UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        contentView = loadViewFromNib()
        addSubview(contentView!)
        contentView?.snp.makeConstraints({[unowned self] (make) in
            make.left.right.top.bottom.equalTo(self)
        })
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: self.classForCoder)
        let nib = UINib(nibName:String(describing: self.classForCoder), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        return view
    }
    
    func customStyle() {}

}
