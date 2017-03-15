//
//  MotorControlViewController.swift
//  MakeblockPlaygrounds
//
//  Created by CatchZeng on 2016/12/15.
//  Copyright © 2016年 makeblock. All rights reserved.
//

import UIKit

public class WriteSomeCodeViewController: UIViewController {
    
    private var tryButton: UIButton!
    
    public var listenTryButtonClicked: ((_ sender: UIButton)-> Void)?
    
    private var hintLabel: UILabel!
    public var defaultHintInfo: String = ""
    
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
        
        //Try Button
        tryButton = UIButton()
        view.addSubview(tryButton)
        tryButton.setTitle("Try it!", for:.normal)
        tryButton.setTitleColor(UIColor.orange, for: .normal)
        tryButton.backgroundColor = UIColor.white
        tryButton.layer.cornerRadius = 30
        tryButton.layer.borderWidth = 1
        tryButton.layer.borderColor = UIColor.white.cgColor
        tryButton.translatesAutoresizingMaskIntoConstraints = false
        tryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tryButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant:-50).isActive = true
        tryButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        tryButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        tryButton.addTarget(self, action:#selector(tryButtonClicked(sender:)), for:.touchUpInside)
    }
    
    func tryButtonClicked(sender: Any) {
        listenTryButtonClicked?(sender as! UIButton)
    }
}
