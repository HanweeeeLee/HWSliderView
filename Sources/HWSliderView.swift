//
//  HWSliderView.swift
//  ColorPalette
//
//  Created by Hanwe Lee on 02/07/2019.
//  Copyright © 2019 Hanwe Lee. All rights reserved.
//

import UIKit

protocol HWSliderViewDelegate:class {
    func sliderDraged(sliderView:HWSliderView,nowIndex:CGFloat)
}

class HWSliderView: UIView {
    
    //MARK: public var
    
    public var borderWidth:CGFloat = 1.0 {
        didSet {
            self.sliderView.layer.borderWidth = self.borderWidth
            self.setNeedsLayout()
        }
    }
    public var bordorColor:UIColor = .black {
        didSet {
            self.sliderView.layer.borderColor = self.bordorColor.cgColor
            self.setNeedsLayout()
        }
    }
    
    public var sliderHandleWidth:CGFloat = 20 {
        didSet {
            self.sliderHandleView.frame = CGRect(x: 0, y: 0, width: self.sliderHandleWidth, height: self.frame.height)
        }
    }
    public var sliderHandleViewCornerRadius:CGFloat = 2.0 {
        didSet {
            self.sliderView.layer.cornerRadius = self.sliderHandleViewCornerRadius
        }
    }
    public var sliderHandleViewBackgroundColor:UIColor = .black {
        didSet {
            self.sliderView.backgroundColor = self.sliderHandleViewBackgroundColor
        }
    }
    

    
    public weak var delegate:HWSliderViewDelegate?
    
    //MARK: private var
    
    private var isCalledinitLayerUI:Bool = false
    private var intervalBarToHandle:CGFloat = 7
    private let backgroundGradientLayer = CAGradientLayer()
    private var backgroundColorArr : [Any] = [UIColor.white.cgColor,
                                      UIColor.white.cgColor]
    private let sliderView:UIView = UIView()
    private var sliderHandleView:UIView = UIView()
    
    private var sliderViewConstraintArr:Array = [NSLayoutConstraint]()
    private var emptySpaceSliderView:CGFloat = 10
    private var emptySpaceSliderHandle:CGFloat = 5
    
    //MARK: life cycle
    
    override func awakeFromNib() {
        initUI()
    }
    
    //MARK: func
    
    private func initUI() {
        self.layer.masksToBounds = false
        self.clipsToBounds = true
        self.sliderView.layer.masksToBounds = false
        self.sliderView.clipsToBounds = true
        self.sliderHandleView.layer.masksToBounds = false
        self.sliderHandleView.clipsToBounds = true
        self.backgroundColor = .clear
        self.sliderView.frame = CGRect(x: 0, y: 0, width: self.layer.frame.width - (2 * emptySpaceSliderView), height: self.layer.frame.height - self.intervalBarToHandle*2)
        self.addSubview(self.sliderView)
        let sliderViewConstraint1 = NSLayoutConstraint(item: self.sliderView , attribute: .leading, relatedBy: .equal,
                                                        toItem: self, attribute: .leading,
                                                        multiplier: 1.0, constant: emptySpaceSliderView)
        
        let sliderViewConstraint2 = NSLayoutConstraint(item: self.sliderView, attribute: .trailing, relatedBy: .equal,
                                                        toItem: self, attribute: .trailing,
                                                        multiplier: 1.0, constant: -emptySpaceSliderView)
        let sliderViewConstraint3 = NSLayoutConstraint(item: self.sliderView, attribute: .centerY, relatedBy: .equal,
                                                toItem: self, attribute: .centerY,
                                                multiplier: 1.0, constant: 0)
        let sliderViewConstraint4 = self.sliderView.heightAnchor.constraint(equalToConstant: self.layer.frame.height - self.intervalBarToHandle*2)
        self.sliderViewConstraintArr = [sliderViewConstraint1, sliderViewConstraint2, sliderViewConstraint3, sliderViewConstraint4]
        self.addConstraints(self.sliderViewConstraintArr)
        self.sliderView.translatesAutoresizingMaskIntoConstraints = false
        
        self.sliderView.layer.borderWidth = self.borderWidth
        self.sliderView.layer.borderColor = self.bordorColor.cgColor

        self.sliderView.layer.shadowColor = UIColor.black.cgColor
        self.sliderView.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.sliderView.layer.shadowRadius = 1
        self.sliderView.layer.shadowOpacity = 0.5
        
        self.sliderView.layer.cornerRadius = self.sliderView.frame.height/2
        self.sliderView.layer.masksToBounds = false
        
        self.sliderHandleView.frame = CGRect(x: 0, y: 0, width: self.sliderHandleWidth, height: self.frame.height)
        self.addSubview(sliderHandleView)
        self.sliderHandleView.backgroundColor = .black
        self.sliderHandleView.layer.cornerRadius = self.sliderHandleViewCornerRadius
        self.sliderHandleView.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.sliderHandleView.layer.shadowColor = UIColor(red:0.09, green:0.11, blue:0.15, alpha:0.05).cgColor
        self.sliderHandleView.layer.shadowOpacity = 1
        self.sliderHandleView.layer.shadowRadius = 2.0
        self.sliderHandleView.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self, action:  #selector(handleDrag(_:)))
        self.addGestureRecognizer(panGesture)
        
        self.setNeedsLayout()
    }
    
    //MARK: public function
    
    public func initLayerUI() {
        self.isCalledinitLayerUI = true
        self.backgroundGradientLayer.frame = CGRect(x: 0, y: 0, width: self.sliderView.bounds.width, height: self.sliderView.frame.height)
        self.backgroundGradientLayer.colors = self.backgroundColorArr
        self.backgroundGradientLayer.locations = [0, 1]
        self.backgroundGradientLayer.startPoint = CGPoint(x: 0, y: 1)
        self.backgroundGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        self.backgroundGradientLayer.cornerRadius = self.sliderView.frame.height/2
        self.backgroundGradientLayer.removeFromSuperlayer()
        self.sliderView.layer.addSublayer(self.backgroundGradientLayer)
    }
    
    public func setSliderBackgroundColor(_ startColor:UIColor, _ endColor:UIColor) {
        self.backgroundColorArr.removeAll()
        self.backgroundColorArr.append(startColor.cgColor)
        self.backgroundColorArr.append(endColor.cgColor)
        self.backgroundGradientLayer.colors = self.backgroundColorArr
        self.setNeedsLayout()
    }
    
    public func setSliderHandleViewPoint(_ xPoint:CGFloat) {// 0~1
        let maxXPoint:CGFloat = self.sliderView.frame.width - self.sliderHandleView.frame.width + (2 * self.emptySpaceSliderHandle)
        self.sliderHandleView.frame = CGRect(x: (xPoint * maxXPoint) - self.emptySpaceSliderHandle + self.emptySpaceSliderView, y: 0, width: self.sliderHandleWidth, height: self.frame.height)
        delegate?.sliderDraged(sliderView: self, nowIndex: xPoint)
        self.setNeedsLayout()
    }
    
    public func setSliderCornerRadius(_ radius:CGFloat) {
        
    }
    
    //MARK: action
    
    @objc func handleDrag(_ sender: UIPanGestureRecognizer) {
        let transition = sender.translation(in: self.sliderHandleView)
        var changeX = self.sliderHandleView.center.x + transition.x
        
        if changeX < self.sliderHandleWidth/2 - self.emptySpaceSliderHandle + self.emptySpaceSliderView {
            changeX = self.sliderHandleWidth/2 - self.emptySpaceSliderHandle + self.emptySpaceSliderView
        }
        else if changeX > (self.sliderView.frame.width - self.sliderHandleWidth/2) + self.emptySpaceSliderHandle + self.emptySpaceSliderView {
            changeX = (self.sliderView.frame.width - self.sliderHandleWidth/2) + self.emptySpaceSliderHandle + self.emptySpaceSliderView
        }
        self.sliderHandleView.center = CGPoint(x: changeX, y: self.sliderHandleView.center.y)
        sender.setTranslation(CGPoint.zero, in: self.sliderHandleView)
        let maxXPoint:CGFloat = self.sliderView.frame.width - self.sliderHandleView.frame.width + (2 * self.emptySpaceSliderHandle)
        let movePoint = (self.sliderHandleView.frame.minX + self.emptySpaceSliderHandle - self.emptySpaceSliderView)/maxXPoint
        
        delegate?.sliderDraged(sliderView: self, nowIndex: movePoint)
        
    }

}
