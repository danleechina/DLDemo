//
//  SliderView.swift
//  WMPayDayLoan
//
//  Created by Dan.Lee on 2017/8/18.
//  Copyright © 2017年 WUMII. All rights reserved.
//

import UIKit

class SliderContainerView: UIView {
    let paddingLeft: CGFloat = 0
    let paddingRight: CGFloat = 0
    let paddingTop: CGFloat = 0
    let paddingBottom: CGFloat = 0
    
    var view: UIView? {
        didSet {
            removeAllSubviews()
            if view != nil {
                addSubview(view!)
                view?.frame = CGRect(x: paddingLeft,
                                     y: paddingTop,
                                     width: bounds.width - paddingRight - paddingLeft,
                                     height: bounds.height - paddingTop - paddingBottom)
            }
        }
    }
}

// TODO
// 不能允许两只手指相继滚动

class SliderView: UIView {
    enum SlideDirection {
        case Vertical
        case Horizontal
    }
    fileprivate var scrollView = UIScrollView()
    fileprivate var pageControl = UIPageControl()
    fileprivate var previousView = SliderContainerView()
    fileprivate var currentView = SliderContainerView()
    fileprivate var nextView = SliderContainerView()
    fileprivate var userDragging:Bool = false
    fileprivate var lastContentOffset = CGPoint.zero
    fileprivate var isToNext = 0
    fileprivate var hasScrolled = false
    
    let paddingLeft: CGFloat = 45
    let paddingRight: CGFloat = 45
    let paddingTop: CGFloat = 15
    let paddingBottom: CGFloat = 35
    
    // If a page is not full of screen width or height, next/previous view shows like flash.
    // No good solutions, so I decided to animate the showing
    // But the animate is not always happening if the view is already there
    private func animate(view: UIView) {
        if !hasScrolled {
            return
        }
        scrollView.isUserInteractionEnabled = false
        let animateTime = 0.5
        let animateDistance: CGFloat = 45
        let of = view.frame
        var nf = view.frame
        if slideDirection == .Horizontal {
            if view == previousView {
                nf.origin.x -= animateDistance
            } else {
                nf.origin.x += animateDistance
            }
        } else {
            if view == previousView {
                nf.origin.y -= animateDistance
            } else {
                nf.origin.y += animateDistance
            }
        }
        view.frame = nf
        UIView.animate(withDuration: animateTime, delay: 0, options: .curveEaseOut, animations: {
            view.frame = of
        }, completion: {[weak self] (finish) in
            view.frame = of
            self?.scrollView.isUserInteractionEnabled = true
        })
    }
    
    private(set) var currentIndex = 0 {
        didSet {
            if currentIndex >= viewsToShow.count {
                currentIndex = circleSlide ? 0 : viewsToShow.count - 1
            } else if currentIndex < 0 {
                currentIndex = circleSlide ? viewsToShow.count - 1 : 0
            }
            pageControl.currentPage = currentIndex
            
            if circleSlide {
                if viewsToShow.count == 1 {
                    previousView.view = nil
                    currentView.view = viewsToShow[0]
                    nextView.view = nil
                } else {
                    currentView.view = viewsToShow[currentIndex]
                    if viewsToShow.count >= 3 {
                        previousView.view = viewsToShow[currentIndex == 0 ? viewsToShow.count - 1 : currentIndex - 1]
                        nextView.view = viewsToShow[currentIndex >= viewsToShow.count - 1 ? 0 : currentIndex + 1]
                    } else if viewsToShow.count == 2 {
                        previousView.view = viewsToShow[currentIndex == 0 ? 1 : 0]
                        nextView.view = viewsToShow[currentIndex == 0 ? 1 : 0]
                    }
                    
                    if slideDirection == .Horizontal {
                        scrollView.contentOffset = CGPoint(x:scrollView.bounds.width, y:0)
                    } else {
                        scrollView.contentOffset = CGPoint(x:0, y:scrollView.bounds.height)
                    }
                    
                    if isToNext > 0 {
                        animate(view: nextView)
                    } else if isToNext < 0 {
                        animate(view: previousView)
                    }
                }
            } else {
                let pageCount = min(viewsToShow.count, 3)
                if pageCount == 1 {
                    previousView.view = viewsToShow[0]
                    currentView.view = nil
                    nextView.view = nil
                } else if pageCount == 2 {
                    previousView.view = viewsToShow[0]
                    currentView.view = viewsToShow[1]
                    nextView.view = nil
                } else if pageCount == 3 {
                    if currentIndex == 0 {
                        previousView.view = viewsToShow[0]
                        currentView.view = viewsToShow[1]
                        nextView.view = viewsToShow[2]
                    } else if currentIndex == viewsToShow.count - 1 {
                        previousView.view = viewsToShow[currentIndex - 2]
                        currentView.view = viewsToShow[currentIndex - 1]
                        nextView.view = viewsToShow[currentIndex]
                    } else {
                        if slideDirection == .Horizontal {
                            scrollView.contentOffset = CGPoint(x:scrollView.bounds.width, y:0)
                        } else {
                            scrollView.contentOffset = CGPoint(x:0, y:scrollView.bounds.height)
                        }
                        
                        previousView.view = viewsToShow[currentIndex - 1]
                        currentView.view = viewsToShow[currentIndex]
                        nextView.view = viewsToShow[currentIndex + 1]
                        
                        if viewsToShow.count != 3 {
                            if currentIndex == 1 {
                                if isToNext < 0 {
                                    animate(view: previousView)
                                }
                            } else if currentIndex == viewsToShow.count - 2 {
                                if isToNext > 0 {
                                    animate(view: nextView)
                                }
                            } else if viewsToShow.count != 4 {
                                if isToNext > 0 {
                                    animate(view: nextView)
                                } else {
                                    animate(view: previousView)
                                }
                            }
                        }
                    }
                }
            }
            isToNext = 0
        }
    }
    
    var circleSlide = false {
        didSet {
            setAppearance()
        }
    }
    
    var slideDirection = SlideDirection.Horizontal {
        didSet {
            setAppearance()
        }
    }
    
    var viewsToShow = [UIView]() {
        didSet {
            setAppearance()
        }
    }
    
    override func layoutSubviews() {
        superview?.layoutSubviews()
        setAppearance()
    }
    
    private func setAppearance() {
        hasScrolled = false
        scrollView.frame = CGRect(x: paddingLeft,
                                  y: paddingTop,
                                  width: frame.width - paddingLeft - paddingRight,
                                  height: frame.height - paddingTop - paddingBottom)
        setInitContentOffset()
        setPageControl()
        setContentSize()
        setContainerView()
        configAppearance()
        currentIndex = 0
    }
    
    private func setInitContentOffset() {
        if circleSlide {
            if slideDirection == .Horizontal {
                scrollView.contentOffset = CGPoint(x:scrollView.bounds.width, y:0)
            } else {
                scrollView.contentOffset = CGPoint(x:0, y:scrollView.bounds.height)
            }
        } else {
            scrollView.contentOffset = CGPoint(x:0, y:0)
        }
    }
    
    private func setPageControl() {
        pageControl.transform = CGAffineTransform.identity
        pageControl.numberOfPages = viewsToShow.count
        pageControl.currentPage = 0
        let minSize = pageControl.size(forNumberOfPages: pageControl.numberOfPages)
        let superViewWidth = bounds.width
        let superViewHeight = bounds.height
        switch slideDirection {
        case .Horizontal:
            pageControl.center = CGPoint(x: superViewWidth/2, y: superViewHeight - minSize.height/2)
            pageControl.transform = CGAffineTransform(rotationAngle: 0)
            break
        case .Vertical:
            pageControl.center = CGPoint(x: superViewWidth - minSize.height/2, y: superViewHeight/2)
            pageControl.transform = CGAffineTransform(rotationAngle: CGFloat(CGFloat.pi / 2))
            break
        }
    }
    
    private func setContentSize() {
        let count = CGFloat(min(viewsToShow.count, 3))
        
        switch slideDirection {
        case .Horizontal:
            scrollView.contentSize = CGSize(width:scrollView.bounds.width * count, height:scrollView.bounds.height)
            break
        case .Vertical:
            scrollView.contentSize = CGSize(width:scrollView.bounds.width, height:scrollView.bounds.height * count)
            break
        }
    }
    
    private func setContainerView() {
        previousView.transform = CGAffineTransform.identity
        currentView.transform = CGAffineTransform.identity
        nextView.transform = CGAffineTransform.identity
        
        var frame = scrollView.bounds
        if slideDirection == .Horizontal {
            frame.origin.x = 0
            previousView.frame = frame
            frame.origin.x = frame.width
            currentView.frame = frame
            frame.origin.x = frame.width * 2
            nextView.frame = frame
        } else {
            frame.origin.y = 0
            previousView.frame = frame
            frame.origin.y = frame.height
            currentView.frame = frame
            frame.origin.y = frame.height * 2
            nextView.frame = frame
        }
    }
    
    fileprivate func configAppearance() {
        let contentOffset = scrollView.contentOffset
        var previousViewDiff: CGFloat
        var currentViewDiff: CGFloat
        var nextViewDiff: CGFloat
        
        if slideDirection == .Horizontal {
            previousViewDiff = min(abs(contentOffset.x - previousView.frame.minX)/scrollView.bounds.width, 1)
            currentViewDiff = min(abs(contentOffset.x - currentView.frame.minX)/scrollView.bounds.width, 1)
            nextViewDiff = min(abs(contentOffset.x - nextView.frame.minX)/scrollView.bounds.width, 1)
        } else {
            previousViewDiff = min(abs(contentOffset.y - previousView.frame.minY)/scrollView.bounds.height, 1)
            currentViewDiff = min(abs(contentOffset.y - currentView.frame.minY)/scrollView.bounds.height, 1)
            nextViewDiff = min(abs(contentOffset.y - nextView.frame.minY)/scrollView.bounds.height, 1)
        }
        
        previousView.transform = CGAffineTransform.identity.scaledBy(x: cos(previousViewDiff * CGFloat.pi/6), y: cos(previousViewDiff * CGFloat.pi/6))
        currentView.transform = CGAffineTransform.identity.scaledBy(x: cos(currentViewDiff * CGFloat.pi/6), y: cos(currentViewDiff * CGFloat.pi/6))
        nextView.transform = CGAffineTransform.identity.scaledBy(x: cos(nextViewDiff * CGFloat.pi/6), y: cos(nextViewDiff * CGFloat.pi/6))
        
        previousView.alpha = cos(previousViewDiff * CGFloat.pi/4)
        currentView.alpha = cos(currentViewDiff * CGFloat.pi/4)
        nextView.alpha = cos(nextViewDiff * CGFloat.pi/4)
    }
    
    fileprivate func didScrollToNextPage() {
        let count = CGFloat(min(viewsToShow.count, 3))
        if slideDirection == .Horizontal {
            if lastContentOffset.x == scrollView.contentOffset.x {
                if lastContentOffset.x == 0 {
                    isToNext = -1
                } else if lastContentOffset.x == (count - 1) * scrollView.bounds.width {
                    isToNext = 1
                } else {
                    isToNext = 0
                }
            } else {
                if lastContentOffset.x > scrollView.contentOffset.x {
                    isToNext = -1
                } else {
                    isToNext = 1
                }
            }
        } else {
            if lastContentOffset.y == scrollView.contentOffset.y {
                if lastContentOffset.y == 0 {
                    isToNext = -1
                } else if lastContentOffset.y == (count - 1) * scrollView.bounds.height  {
                    isToNext = 1
                } else {
                    isToNext = 0
                }
            } else {
                if lastContentOffset.y > scrollView.contentOffset.y {
                    isToNext = -1
                } else {
                    isToNext = 1
                }
            }
        }
        if isToNext != 0 {
            currentIndex += isToNext
        }
        
    }
    
    fileprivate func viewInit() {
        layer.masksToBounds = true
        clipsToBounds = true
        addSubview(scrollView)
        addSubview(pageControl)
        scrollView.addSubview(previousView)
        scrollView.addSubview(currentView)
        scrollView.addSubview(nextView)
        
        scrollView.isPagingEnabled = true
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.clipsToBounds = false
        pageControl.hidesForSinglePage = true
    }
    
    init(views: [UIView]) {
        super.init(frame: CGRect.zero)
        viewsToShow = views
        viewInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewInit()
    }
}

extension SliderView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var contentOffset = scrollView.contentOffset
        if slideDirection == .Horizontal {
            contentOffset.y = 0
        } else {
            contentOffset.x = 0
        }
        scrollView.contentOffset = contentOffset
        configAppearance()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hasScrolled = true
        lastContentOffset = scrollView.contentOffset
        self.userDragging = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollView.isUserInteractionEnabled = false
        self.userDragging = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.isUserInteractionEnabled = true
        self.didScrollToNextPage()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollView.isUserInteractionEnabled = true
        self.didScrollToNextPage()
    }
}
