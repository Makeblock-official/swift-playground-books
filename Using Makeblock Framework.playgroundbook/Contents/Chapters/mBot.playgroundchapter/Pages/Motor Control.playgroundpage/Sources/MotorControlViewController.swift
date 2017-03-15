//
//  MotorControlViewController.swift
//  MakeblockPlaygrounds
//
//  Created by CatchZeng on 2016/12/15.
//  Copyright © 2016年 makeblock. All rights reserved.
//

import UIKit

public class MotorControlViewController: UIViewController {
    
    private var startButton: UIButton!
    
    public var listenStartButtonClicked: ((_ sender: UIButton)-> Void)?
    
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
        
        //Start Button
        startButton = UIButton()
        view.addSubview(startButton)
        startButton.setTitle("Start", for:.normal)
        startButton.setTitleColor(UIColor.orange, for: .normal)
        startButton.backgroundColor = UIColor.white
        startButton.layer.cornerRadius = 30
        startButton.layer.borderWidth = 1
        startButton.layer.borderColor = UIColor.white.cgColor
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant:-50).isActive = true
        startButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        startButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        startButton.addTarget(self, action:#selector(startButtonClicked(sender:)), for:.touchUpInside)
    }
    
    func startButtonClicked(sender: Any) {
        listenStartButtonClicked?(sender as! UIButton)
    }
}
