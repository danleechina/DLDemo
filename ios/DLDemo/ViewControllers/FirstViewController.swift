//
//  FirstViewController.swift
//  DLDemo
//
//  Created by Dan.Lee on 2016/10/16.
//  Copyright © 2016年 Dan Lee. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController  {

    private let imageSliderView = ImageSliderView()
    private var indexOfNum = 0;
    fileprivate let indicatorLabel :UILabel = {
        let label = UILabel()
        label.textColor = UIColor.blue
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        imageSliderView.slideDirection = .Vertical
        changeNumber(sender: nil)
        imageSliderView.frame =  CGRect(x:5, y:100, width:self.view.frame.width - 10, height:self.view.frame.height * 0.6)
        imageSliderView.backgroundColor = UIColor.brown
        imageSliderView.delegate = self
        
        /*
         * Attention: need to set automaticallyAdjustsScrollViewInsets false 
         * when in container view controller like UINavigationController if
         * you want to use vertical slider.
         */
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.addSubview(imageSliderView)
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(indicatorLabel)
        
        let directionButton = UIButton()
        directionButton.frame = CGRect(x: 44, y: self.view.frame.height - 100, width: 120, height: 44)
        directionButton.setTitle("改成水平滚动", for: .normal)
        directionButton.setTitleColor(UIColor.blue, for: .normal)
        directionButton.addTarget(self, action: #selector(changeDirection), for: .touchUpInside)
        self.view.addSubview(directionButton)
        
        let numberButton = UIButton()
        numberButton.frame = CGRect(x: 170, y: self.view.frame.height - 100, width: 120, height: 44)
        numberButton.setTitle("改变图片数量", for: .normal)
        numberButton.setTitleColor(UIColor.blue, for: .normal)
        numberButton.addTarget(self, action: #selector(changeNumber), for: .touchUpInside)
        self.view.addSubview(numberButton)
        imageSliderView.startToSlide()
        
        let button1 = UIButton()
        button1.frame = CGRect(x: 0, y: self.view.frame.height - 44, width: 100, height: 44)
        button1.setTitle("设置图片", for: .normal)
        button1.setTitleColor(UIColor.blue, for: .normal)
        button1.addTarget(self, action: #selector(setImage), for: .touchUpInside)
        self.view.addSubview(button1)
        
        imageView.frame = CGRect(x:5, y:100, width:self.view.frame.width / 2, height:self.view.frame.height / 2)
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
    }
    
    private let imageView = UIImageView()
    
    func setImage() {
        imageView.image = imageSliderView.getImage(ofRect: CGRect(x: 0, y: 0, width: imageSliderView.frame.width, height: imageSliderView.frame.height))
        imageView.isHidden = false
        imageSliderView.alpha = 0.5
    }

    func changeDirection(sender: UIButton?) {
        switch imageSliderView.slideDirection {
        case .Vertical:
            imageSliderView.slideDirection = .Horizontal
            sender?.setTitle("改成垂直滚动", for: .normal)
            break
        case .Horizontal:
            imageSliderView.slideDirection = .Vertical
            sender?.setTitle("改成水平滚动", for: .normal)
            break
        }
        imageSliderView.startToSlide()
    }
    
    func changeNumber(sender: UIButton?) {
        let nums = [1,2,3,4,5,6]
        
        var images = Array<UIImage>()
        
        for i: Int in 1 ..< nums[indexOfNum] {
            let image = UIImage.init(named: "\(i)")
            images.append(image!)
        }
        indexOfNum += 1
        indexOfNum %= 6
        sender?.setTitle("改成\(nums[indexOfNum] - 1)张图片", for: .normal)
        imageSliderView.images = images
        imageSliderView.startToSlide()
    }
}

extension FirstViewController:ImageSliderViewDelegate {
    func didSelectAtPage(index: Int) {
        print("press at page: \(index)")
        indicatorLabel.text = "点击了第\(index+1)页"
        indicatorLabel.sizeToFit()
        indicatorLabel.frame = CGRect(x: self.view.frame.width/2 - indicatorLabel.frame.width/2,
                                      y: self.view.frame.height - indicatorLabel.frame.height - 10,
                                      width: indicatorLabel.frame.width,
                                      height: indicatorLabel.frame.height)
    }
}
