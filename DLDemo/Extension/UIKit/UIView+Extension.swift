//
//  UIView+Extension.swift
//  DLDemo
//
//  Created by Zhengda Lee on 10/21/16.
//  Copyright © 2016 Dan Lee. All rights reserved.
//

import UIKit

extension UIView {
    func topLeftPoint() -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    
    func topRightPoint() -> CGPoint {
        return CGPoint(x: frame.width, y: 0)
    }
    
    func bottomLeftPoint() -> CGPoint {
        return CGPoint(x: 0, y: frame.height)
    }
    
    func bottomRightPoint() -> CGPoint {
        return CGPoint(x: frame.width, y: frame.height)
    }
    
    func subviewsPassThrought(onY: CGFloat) -> Array<UIView> {
        var rightViews = Array<UIView>()
        for view in subviews {
            let frame = view.frame
            if frame.minY >= onY && frame.maxY <= onY {
                rightViews.append(view)
            }
        }
        return rightViews
    }
    
    func subviewsPassThrought(onX: CGFloat) -> Array<UIView> {
        var rightViews = Array<UIView>()
        for view in subviews {
            let frame = view.frame
            if frame.minX >= onX && frame.maxX <= onX {
                rightViews.append(view)
            }
        }
        return rightViews
    }
    
    func subviewsOnBottomRight(point: CGPoint) ->Array<UIView> {
        var rightViews = Array<UIView>()
        for view in subviews {
            let bottomRightPoint = view.bottomRightPoint()
            if bottomRightPoint.x > point.x && bottomRightPoint.y > point.y {
                rightViews.append(view)
            }
        }
        return rightViews
    }
    
    func subviewOnBottomLeft(point: CGPoint) -> Array<UIView> {
        var rightViews = Array<UIView>()
        for view in subviews {
            let bottomLeftPoint = view.bottomLeftPoint()
            if bottomLeftPoint.x < point.x && bottomLeftPoint.y > point.y {
                rightViews.append(view)
            }
        }
        return rightViews
    }
    
    func subviewOnTopRight(point: CGPoint) -> Array<UIView> {
        var rightViews = Array<UIView>()
        for view in subviews {
            let topRightPoint = view.topRightPoint()
            if topRightPoint.x > point.x && topRightPoint.y < point.y {
                rightViews.append(view)
            }
        }
        return rightViews
    }

    func subviewOnTopLeft(point: CGPoint) -> Array<UIView> {
        var rightViews = Array<UIView>()
        for view in subviews {
            let topLeftPoint = view.topLeftPoint()
            if topLeftPoint.x < point.x && topLeftPoint.y < point.y {
                rightViews.append(view)
            }
        }
        return rightViews
    }

}
