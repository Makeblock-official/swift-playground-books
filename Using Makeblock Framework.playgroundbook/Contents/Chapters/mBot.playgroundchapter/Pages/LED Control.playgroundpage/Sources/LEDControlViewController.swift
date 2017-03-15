//
//  LEDControlViewController.swift
//  MakeblockPlaygrounds
//
//  Created by CatchZeng on 2016/12/15.
//  Copyright © 2016年 makeblock. All rights reserved.
//

import UIKit
import Foundation

public struct HSB {
    let h:Double?
    let s:Double?
    let b:Double?
    
    public init(h: Double,s: Double,b: Double) {
        self.h = h
        self.s = s
        self.b = b
    }
}

public struct RGBA {
    var r:Double?
    var g:Double?
    var b:Double?
    var a:Double?
    
    public init(r: Double,g: Double,b: Double,a: Double) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
}


public class LEDControlViewController: UIViewController {
    private var hintLabel: UILabel!
    public var defaultHintInfo: String = ""
    
    private var bgView: UIView!
    private var colorHoopView: UIImageView!
    private var pointView: UIView!
    
    private var colorHue = 0.0
    public var listenColorChanged: ((_ color: UIColor)-> Void)?
    
    public func setHintInfo(content: String){
        hintLabel.text = content
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        //HintLabel
        hintLabel = UILabel(frame: CGRect(x:10, y:60, width:500, height:30))
        view.addSubview(hintLabel)
        hintLabel.textColor = UIColor.orange
        hintLabel.text = self.defaultHintInfo
        
        //Background view
        bgView = UIView()
        view.addSubview(bgView)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bgView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant:0).isActive = true
        bgView.widthAnchor.constraint(equalToConstant: 227).isActive = true
        bgView.heightAnchor.constraint(equalToConstant: 227).isActive = true
        
        //Color hoop
        colorHoopView = UIImageView(image: UIImage(named: "color-hoop"))
        view.addSubview(colorHoopView)
        colorHoopView.translatesAutoresizingMaskIntoConstraints = false
        colorHoopView.centerXAnchor.constraint(equalTo: bgView.centerXAnchor).isActive = true
        colorHoopView.centerYAnchor.constraint(equalTo: bgView.centerYAnchor, constant:0).isActive = true
        colorHoopView.widthAnchor.constraint(equalTo: bgView.widthAnchor, multiplier:1.0).isActive = true
        colorHoopView.heightAnchor.constraint(equalTo: bgView.widthAnchor, multiplier:1.0).isActive = true
        
        //point view
        pointView = UIView()
        pointView.backgroundColor = UIColor.red
        view.addSubview(pointView)
        pointView.translatesAutoresizingMaskIntoConstraints = false
        pointView.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant:2).isActive = true
        pointView.centerYAnchor.constraint(equalTo: bgView.centerYAnchor, constant:0).isActive = true
        pointView.widthAnchor.constraint(equalTo: bgView.widthAnchor, multiplier:0.19).isActive = true
        pointView.heightAnchor.constraint(equalTo: pointView.widthAnchor, multiplier:1.0).isActive = true
        pointView.layer.borderWidth = 1;
        pointView.layer.borderColor = UIColor(red:1, green:1, blue:1, alpha: 0.5).cgColor
        
        pointView.isUserInteractionEnabled = false
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panOrTap(recognizer:)))
        bgView.addGestureRecognizer(panRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(panOrTap(recognizer:)))
        bgView.addGestureRecognizer(tapRecognizer)
    }
    
    func panOrTap(recognizer: UIGestureRecognizer){
        switch recognizer.state{
        case .changed,.ended:
            let point = recognizer.location(in: self.bgView)
            let dx = point.x - bgView.frame.size.height/2.0
            let dy = point.y - bgView.frame.size.height/2.0
            var angle:Double = Double(atan2f(Float(dy), Float(dx)))
            if dy != 0 {
                angle += M_PI
                colorHue = angle / (2*M_PI)
            }
            else if dx > 0{
                colorHue = 0.5
            }
            
            valuesChanged()
            
        default:
            break
        }
    }
    
    func valuesChanged() {
        movePickerPoint()
        
        let hsb = HSB(h: colorHue*360.0, s: 1.0, b: 1.0)
        
        let rgba = UIColor.RGBfromHSB(value: hsb)
        print("rgba:\(rgba)")
        
        let color = UIColor(red:CGFloat(rgba.r!), green:CGFloat(rgba.g!), blue:CGFloat(rgba.b!), alpha:CGFloat(rgba.a!))
        pointView.backgroundColor = color
        
        listenColorChanged?(color)
    }
    
    func movePickerPoint(){
        let angle = M_PI*2*colorHue-M_PI
        var pickMoveRadius = bgView.frame.size.height*0.5 - pointView.frame.size.height*0.5
        pickMoveRadius *= 1.02
        let colorDiskRadius = bgView.frame.size.height*0.5
        let pickerPointRadius = pointView.frame.size.height*0.5
        
        let cx = Double(pickMoveRadius) * cos(angle) + Double(colorDiskRadius + bgView.frame.origin.x - pickerPointRadius)
        
        let cy = Double(pickMoveRadius) * sin(angle) + Double(colorDiskRadius + bgView.frame.origin.y - pickerPointRadius)
        
        var frame = pointView.frame
        frame.origin.x = CGFloat(cx)
        frame.origin.y = CGFloat(cy)
        pointView.frame = frame
    }
    
    public override func viewDidLayoutSubviews() {
        pointView.layer.cornerRadius = pointView.frame.width/2.0
        pointView.layer.masksToBounds = true
        valuesChanged()
    }
}


extension UIColor {
    public class func RGBfromHSB(value:HSB) -> RGBA{
        var hh = 0.0
        var p = 0.0
        var q = 0.0
        var t = 0.0
        var ff = 0.0
        
        var i:u_long = 0
        var out:RGBA = RGBA(r:0, g: 0, b: 0, a: 1.0)
        
        if value.s! <= 0.0 { // < is bogus, just shuts up warnings
            // error - should never happen
            out.r = 0.0
            out.g = 0.0
            out.b = 0.0
            return out
        }
        
        hh = value.h!
        if(hh >= 360.0){
            hh = 0.0
        }
        
        hh /= 60.0;
        i = u_long(hh)
        ff = hh - Double(i)
        p = value.b! * (1.0 - value.s!)
        q = value.b! * (1.0 - (value.s! * ff))
        t = value.b! * (1.0 - (value.s! * (1.0 - ff)))
        
        switch(i)
        {
        case 0:
            out.r = value.b;
            out.g = t;
            out.b = p;
        case 1:
            out.r = q;
            out.g = value.b;
            out.b = p;
        case 2:
            out.r = p;
            out.g = value.b;
            out.b = t;
        case 3:
            out.r = p;
            out.g = q;
            out.b = value.b;
        case 4:
            out.r = t;
            out.g = p;
            out.b = value.b;
        default:
            out.r = value.b;
            out.g = p;
            out.b = q;
        }
        return out;
    }
}
