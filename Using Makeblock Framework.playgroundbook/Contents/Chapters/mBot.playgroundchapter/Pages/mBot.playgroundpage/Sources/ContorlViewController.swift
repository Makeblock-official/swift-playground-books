//
//  ContorlViewController.swift
//  MakeblockPlaygrounds
//
//  Created by CatchZeng on 2016/12/15.
//  Copyright © 2016年 makeblock. All rights reserved.
//

import UIKit

private class ColorWell: UIView {
    let color: UIColor
    var selected = false {
        didSet {
            if selected {
                self.layer.borderWidth = 5
            } else {
                self.layer.borderWidth = 1
            }
        }
    }
    let action: (ColorWell) -> Void
    
    init(color: UIColor, action: @escaping (ColorWell) -> Void) {
        self.color = color
        self.action = action
        
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 25.0
        self.backgroundColor = color
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ColorWell.tapped(_:)))
        self.addGestureRecognizer(tapRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        action(self)
    }
}

private class FlipImageView : UIImageView {
    public var onImage: UIImage!
    public var offImage: UIImage!
    
    public func flipOn() -> Void {
        image = onImage;
    }
    
    public func flipOff() -> Void {
        image = offImage;
    }
    
    public func setFlip(value:(Bool)) -> Void {
        if value {
            self.flipOn()
        }
        else {
            self.flipOff()
        }
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        offImage = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


public class ContorlViewController: UIViewController {
    private var joystickView: UIView!
    private var joystickBgView: UIImageView!
    private var joystickThumbView: UIImageView!
    private var joystickUpArrowView: FlipImageView!
    private var joystickDownArrowView: FlipImageView!
    private var joystickLeftArrowView: FlipImageView!
    private var joystickRightArrowView: FlipImageView!
    private var colorWellContainer: UIStackView!
    private var hintLabel: UILabel!
    public var defaultHintInfo: String = ""
    
    public var joystickMoved: ((_ angle: Double,_ magnitude: Double,_ targetPoint:CGPoint,_ centerPoint:CGPoint,_ radius:Double) -> Void)?
    public var colorSelected: ((UIColor) -> Void)?
    
    private var selectedWell: ColorWell! {
        didSet {
            if selectedWell.selected {
                return
            }
            
            selectedWell.selected = true
            if let old = oldValue {
                old.selected = false
            }
            colorSelected?(selectedWell.color)
        }
    }
    
    public func setHintInfo(content: String){
        hintLabel.text = content
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        
        //HintLabel
        hintLabel = UILabel(frame: CGRect(x:10, y:60, width:500, height:30))
        view.addSubview(hintLabel)
        hintLabel.textColor = UIColor.orange
        hintLabel.text = self.defaultHintInfo
        
        let joystickWidthMultiplier:CGFloat = 0.5
        
        //Joystick
        joystickView = UIView()
        view.addSubview(joystickView)
        joystickView.translatesAutoresizingMaskIntoConstraints = false
        joystickView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        joystickView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant:-50).isActive = true
        joystickView.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier:joystickWidthMultiplier).isActive = true
        joystickView.heightAnchor.constraint(equalTo: joystickView.widthAnchor).isActive = true
        
        joystickBgView = UIImageView(image: UIImage(named: "joystick-base")!)
        joystickView.addSubview(joystickBgView)
        joystickBgView.translatesAutoresizingMaskIntoConstraints = false
        joystickBgView.centerXAnchor.constraint(equalTo: joystickView.centerXAnchor).isActive = true
        joystickBgView.centerYAnchor.constraint(equalTo: joystickView.centerYAnchor).isActive = true
        joystickBgView.leftAnchor.constraint(equalTo: joystickView.leftAnchor).isActive = true
        joystickBgView.topAnchor.constraint(equalTo: joystickView.topAnchor).isActive = true
        
        joystickUpArrowView = FlipImageView(image: UIImage(named: "joystick-highlighter-u")!)
        joystickUpArrowView.onImage = UIImage(named: "joystick-highlighter-u-a")!
        joystickUpArrowView.contentMode = .scaleAspectFit
        joystickView.addSubview(joystickUpArrowView)
        joystickUpArrowView.translatesAutoresizingMaskIntoConstraints = false
        joystickView.addConstraint(NSLayoutConstraint(item: joystickUpArrowView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.centerY, multiplier: 0.25, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickUpArrowView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickUpArrowView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.width, multiplier: 0.1, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickUpArrowView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.width, multiplier: 0.1*17.0/21.0, constant: 0))
        
        joystickDownArrowView = FlipImageView(image: UIImage(named: "joystick-highlighter-d")!)
        joystickDownArrowView.onImage = UIImage(named: "joystick-highlighter-d-a")!
        joystickView.addSubview(joystickDownArrowView)
        joystickDownArrowView.contentMode = .scaleAspectFit
        joystickDownArrowView.translatesAutoresizingMaskIntoConstraints = false
        joystickView.addConstraint(NSLayoutConstraint(item: joystickDownArrowView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.centerY, multiplier: 1.75, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickDownArrowView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickDownArrowView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.width, multiplier: 0.1, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickDownArrowView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.width, multiplier: 0.1*17.0/21.0, constant: 0))
        
        
        joystickLeftArrowView = FlipImageView(image: UIImage(named: "joystick-highlighter-l")!)
        joystickLeftArrowView.onImage = UIImage(named: "joystick-highlighter-l-a")!
        joystickLeftArrowView.contentMode = .scaleAspectFit
        joystickView.addSubview(joystickLeftArrowView)
        joystickLeftArrowView.translatesAutoresizingMaskIntoConstraints = false
        joystickView.addConstraint(NSLayoutConstraint(item: joystickLeftArrowView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickLeftArrowView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.centerX, multiplier: 0.25, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickLeftArrowView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.height, multiplier: 0.1*21.0/17.0, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickLeftArrowView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.height, multiplier: 0.1, constant: 0))
        
        joystickRightArrowView = FlipImageView(image: UIImage(named: "joystick-highlighter-r")!)
        joystickRightArrowView.onImage = UIImage(named: "joystick-highlighter-r-a")!
        joystickRightArrowView.contentMode = .scaleAspectFit
        joystickView.addSubview(joystickRightArrowView)
        joystickRightArrowView.translatesAutoresizingMaskIntoConstraints = false
        joystickView.addConstraint(NSLayoutConstraint(item: joystickRightArrowView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickRightArrowView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.centerX, multiplier: 1.75, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickRightArrowView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.height, multiplier: 0.1*21.0/17.0, constant: 0))
        joystickView.addConstraint(NSLayoutConstraint(item: joystickRightArrowView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: joystickView, attribute: NSLayoutAttribute.height, multiplier: 0.1, constant: 0))
        
        joystickThumbView = UIImageView(image: UIImage(named: "joystick-thumb")!)
        joystickView.addSubview(joystickThumbView)
        joystickThumbView.translatesAutoresizingMaskIntoConstraints = false
        joystickThumbView.centerXAnchor.constraint(equalTo: joystickView.centerXAnchor).isActive = true
        joystickThumbView.centerYAnchor.constraint(equalTo: joystickView.centerYAnchor).isActive = true
        joystickThumbView.widthAnchor.constraint(equalTo: joystickView.widthAnchor, multiplier:0.333).isActive = true
        joystickThumbView.heightAnchor.constraint(equalTo: joystickThumbView.widthAnchor, multiplier:1.157).isActive = true
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didTap(_:)))
        joystickView.addGestureRecognizer(gestureRecognizer)
        
        
        //ColorWell
        colorWellContainer = UIStackView(arrangedSubviews: [])
        colorWellContainer.translatesAutoresizingMaskIntoConstraints = false
        colorWellContainer.distribution = .equalCentering
        
        let colors = [#colorLiteral(red: 0, green: 0.4793452024, blue: 0.9990863204, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1), #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)]
        for color in colors {
            let well = ColorWell(color: color, action: { (selectedWell) in
                self.selectedWell = selectedWell
            })
            well.translatesAutoresizingMaskIntoConstraints = false
            
            colorWellContainer.addArrangedSubview(well)
        }
        
        colorWellContainer.backgroundColor = UIColor.clear
        view.addSubview(colorWellContainer)
        colorWellContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        view.trailingAnchor.constraint(equalTo: colorWellContainer.trailingAnchor, constant: 20).isActive = true
        view.bottomAnchor.constraint(equalTo: colorWellContainer.bottomAnchor, constant: 100).isActive = true
        colorWellContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    @objc private func didTap(_ gestureRecognizer: UIPinchGestureRecognizer) {
        var targetPoint = gestureRecognizer.location(in: joystickBgView)
        let centerPoint = joystickBgView.center
        let thumbDistance = distance(point1: targetPoint, point2: centerPoint)
        
        let joystickThumbMaxDragRadius = joystickThumbView.bounds.height*0.5
        
        if thumbDistance > joystickThumbMaxDragRadius {
            let x = centerPoint.x + (targetPoint.x-centerPoint.x)/thumbDistance*joystickThumbMaxDragRadius
            let y = centerPoint.y + (targetPoint.y-centerPoint.y)/thumbDistance*joystickThumbMaxDragRadius
            targetPoint = CGPoint(x: x, y: y)
        }
        
        if gestureRecognizer.state == .ended {
            joystickThumbView.image = UIImage(named: "joystick-thumb-shadowed")
            joystickThumbView.center = centerPoint
            self.highlightArrow(x: 0, y: 0)
            //stop
            joystickMoved?(Double(0), Double(0),targetPoint,centerPoint,Double(joystickThumbMaxDragRadius))
            
        }else {
            if gestureRecognizer.state == .began{
                joystickThumbView.image = UIImage(named: "joystick-thumb")
            }
            joystickThumbView.center = targetPoint;
            self.highlightArrow(x: targetPoint.x - centerPoint.x, y: targetPoint.y - centerPoint.y)
            judgeDirection(targetPoint: targetPoint, centerPoint: centerPoint, radius: joystickThumbMaxDragRadius)
        }
    }
    
    private func judgeDirection(targetPoint:CGPoint , centerPoint:CGPoint , radius:CGFloat) {
        let angle = Double(atan2(centerPoint.y-targetPoint.y, centerPoint.x - targetPoint.x) * 180) / M_PI
        let dis = distance(point1: targetPoint, point2: centerPoint)
        let magnitude = dis / radius
        joystickMoved?(angle,Double(magnitude),targetPoint, centerPoint,Double(radius))
    }
    
    private func distance(point1:CGPoint, point2:CGPoint) -> CGFloat {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        return sqrt((dx*dx + dy*dy))
    }
    
    private func highlightArrow(x:(CGFloat), y:(CGFloat)) -> Void {
        let highlightTolerance: CGFloat = 10.0
        joystickUpArrowView.setFlip(value: !(y < -highlightTolerance ? false : true))
        joystickDownArrowView.setFlip(value: !(y > highlightTolerance ? false : true))
        joystickRightArrowView.setFlip(value: !(x > highlightTolerance ? false : true))
        joystickLeftArrowView.setFlip(value: !(x < -highlightTolerance ? false : true))
    }
}
