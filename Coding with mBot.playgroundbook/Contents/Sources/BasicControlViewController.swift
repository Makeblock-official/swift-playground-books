//
//  BasicControlViewController.swift
//  MakeblockPlaygrounds
//
//  Created by CatchZeng on 2016/12/15.
//  Edited by Wangyu
//  Copyright © 2016年 makeblock. All rights reserved.
//

import UIKit

public class BasicControlViewController: UIViewController {
    
    private var graphView: ScrollableGraphView!
    private var data: [Double] = [0,0,0,0,0,0]
    
    private var startButton: UIButton!
    
    public var listenStartButtonClicked: ((_ sender: UIButton)-> Void)?
    
    private var hintLabel: UILabel!
    public var defaultHintInfo: String = ""
    public var connection: BluetoothConnection!
    public var mBot: MBot!
    
    public func setHintInfo(content: String){
        hintLabel.text = content
    }
    
    public func setShowGraphView(show: Bool){
        graphView.isHidden = !show
    }
    
    public func appendValue(value:Double){
        data.append(value)
        graphView.reload(data: data, withLabels: [])
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        
        //HintLabel
        hintLabel = UILabel(frame: CGRect(x:10, y:60, width:500, height:30))
        view.addSubview(hintLabel)
        hintLabel.textColor = UIColor.orange
        hintLabel.text = self.defaultHintInfo
        
        //GraphView
        graphView = ScrollableGraphView(frame:  CGRect(x:200, y:0, width: 300, height: 300))
        view.addSubview(graphView)
        graphView.isHidden = true
        graphView.lineStyle = .smooth
        graphView.shouldAnimateOnStartup = true
        graphView.animationDuration = 0.2
        graphView.shouldAutomaticallyDetectRange = true
        graphView.set(data: data, withLabels: [])
        
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
        
        // connection
        connection = BluetoothConnection()
        mBot = MBot(connection:connection)
        mBot.nearest()
        
        self.defaultHintInfo = Message.nearmBot.rawValue
        
        connection.onStateChanged = { state in
            if state == BluetoothConnectionState.idle{
                self.setHintInfo(content:Message.nearmBot.rawValue)
            }
            else if state == BluetoothConnectionState.connected{
                self.setHintInfo(content:Message.connected.rawValue)
            }
            else if state == BluetoothConnectionState.connecting{
                self.setHintInfo(content:Message.connecting.rawValue)
            }
        }

    }
    
    func startButtonClicked(sender: Any) {
        listenStartButtonClicked?(sender as! UIButton)
    }
}
