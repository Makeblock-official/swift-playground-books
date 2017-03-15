//
//  MusicViewController.swift
//  MakeblockPlaygrounds
//
//  Created by CatchZeng on 2016/12/21.
//  Copyright © 2016年 makeblock. All rights reserved.
//

import UIKit

public enum MusicKeyType{
    case Do,Re,Mi,Fa,Sol,La,Si
}

public class MusicViewController: UIViewController {
    
    private var hintLabel: UILabel!
    public var defaultHintInfo: String = ""
    
    private var bgView: UIView!
    private var btnDo: UIButton!,btnRe: UIButton!,btnMi: UIButton!,
    btnFa: UIButton!,btnSol: UIButton!,btnLa: UIButton!,
    btnSi: UIButton!
    
    public var listenMusicKeyClicked: ((_ keyType: MusicKeyType) -> Void)?
    
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
        
        //Background view
        bgView = UIView()
        view.addSubview(bgView)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bgView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant:-50).isActive = true
        bgView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier:0.8).isActive = true
        bgView.heightAnchor.constraint(equalTo: bgView.widthAnchor, multiplier:261/153.0/7).isActive = true
        
        //Do
        btnDo = UIButton(type: UIButtonType.custom)
        btnDo.setBackgroundImage(UIImage(named:"musickey-do-normal"), for:.normal)
        btnDo.setBackgroundImage(UIImage(named:"musickey-do-press"), for:.highlighted)
        bgView.addSubview(btnDo)
        btnDo.translatesAutoresizingMaskIntoConstraints = false
        btnDo.leftAnchor.constraint(equalTo:bgView.leftAnchor, constant:0).isActive = true
        btnDo.topAnchor.constraint(equalTo:bgView.topAnchor, constant:0).isActive = true
        btnDo.widthAnchor.constraint(equalTo:bgView.widthAnchor, multiplier:1.0/7).isActive = true
        btnDo.heightAnchor.constraint(equalTo:btnDo.widthAnchor, multiplier:261.0/153).isActive = true
        
        //Re
        btnRe = UIButton(type: UIButtonType.custom)
        btnRe.setBackgroundImage(UIImage(named:"musickey-re-normal"), for:.normal)
        btnRe.setBackgroundImage(UIImage(named:"musickey-re-press"), for:.highlighted)
        bgView.addSubview(btnRe)
        btnRe.translatesAutoresizingMaskIntoConstraints = false
        btnRe.leftAnchor.constraint(equalTo:btnDo.rightAnchor, constant:0).isActive = true
        btnRe.topAnchor.constraint(equalTo:bgView.topAnchor, constant:0).isActive = true
        btnRe.widthAnchor.constraint(equalTo:bgView.widthAnchor, multiplier:1.0/7).isActive = true
        btnRe.heightAnchor.constraint(equalTo:btnRe.widthAnchor, multiplier:246.0/153).isActive = true
        
        //Mi
        btnMi = UIButton(type: UIButtonType.custom)
        btnMi.setBackgroundImage(UIImage(named:"musickey-mi-normal"), for:.normal)
        btnMi.setBackgroundImage(UIImage(named:"musickey-mi-press"), for:.highlighted)
        bgView.addSubview(btnMi)
        btnMi.translatesAutoresizingMaskIntoConstraints = false
        btnMi.leftAnchor.constraint(equalTo:btnRe.rightAnchor, constant:0).isActive = true
        btnMi.topAnchor.constraint(equalTo:bgView.topAnchor, constant:0).isActive = true
        btnMi.widthAnchor.constraint(equalTo:bgView.widthAnchor, multiplier:1.0/7).isActive = true
        btnMi.heightAnchor.constraint(equalTo:btnMi.widthAnchor, multiplier:230.0/153).isActive = true
        
        //Fa
        btnFa = UIButton(type: UIButtonType.custom)
        btnFa.setBackgroundImage(UIImage(named:"musickey-fa-normal"), for:.normal)
        btnFa.setBackgroundImage(UIImage(named:"musickey-fa-press"), for:.highlighted)
        bgView.addSubview(btnFa)
        btnFa.translatesAutoresizingMaskIntoConstraints = false
        btnFa.leftAnchor.constraint(equalTo:btnMi.rightAnchor, constant:0).isActive = true
        btnFa.topAnchor.constraint(equalTo:bgView.topAnchor, constant:0).isActive = true
        btnFa.widthAnchor.constraint(equalTo:bgView.widthAnchor, multiplier:1.0/7).isActive = true
        btnFa.heightAnchor.constraint(equalTo:btnFa.widthAnchor, multiplier:215.0/153).isActive = true
        
        //Sol
        btnSol = UIButton(type: UIButtonType.custom)
        btnSol.setBackgroundImage(UIImage(named:"musickey-sol-normal"), for:.normal)
        btnSol.setBackgroundImage(UIImage(named:"musickey-sol-press"), for:.highlighted)
        bgView.addSubview(btnSol)
        btnSol.translatesAutoresizingMaskIntoConstraints = false
        btnSol.leftAnchor.constraint(equalTo:btnFa.rightAnchor, constant:0).isActive = true
        btnSol.topAnchor.constraint(equalTo:bgView.topAnchor, constant:0).isActive = true
        btnSol.widthAnchor.constraint(equalTo:bgView.widthAnchor, multiplier:1.0/7).isActive = true
        btnSol.heightAnchor.constraint(equalTo:btnSol.widthAnchor, multiplier:199.0/153).isActive = true
        
        //La
        btnLa = UIButton(type: UIButtonType.custom)
        btnLa.setBackgroundImage(UIImage(named:"musickey-la-normal"), for:.normal)
        btnLa.setBackgroundImage(UIImage(named:"musickey-la-press"), for:.highlighted)
        bgView.addSubview(btnLa)
        btnLa.translatesAutoresizingMaskIntoConstraints = false
        btnLa.leftAnchor.constraint(equalTo:btnSol.rightAnchor, constant:0).isActive = true
        btnLa.topAnchor.constraint(equalTo:bgView.topAnchor, constant:0).isActive = true
        btnLa.widthAnchor.constraint(equalTo:bgView.widthAnchor, multiplier:1.0/7).isActive = true
        btnLa.heightAnchor.constraint(equalTo:btnLa.widthAnchor, multiplier:184.0/153).isActive = true
        
        //Si
        btnSi = UIButton(type: UIButtonType.custom)
        btnSi.setBackgroundImage(UIImage(named:"musickey-si-normal"), for:.normal)
        btnSi.setBackgroundImage(UIImage(named:"musickey-si-press"), for:.highlighted)
        bgView.addSubview(btnSi)
        btnSi.translatesAutoresizingMaskIntoConstraints = false
        btnSi.leftAnchor.constraint(equalTo:btnLa.rightAnchor, constant:0).isActive = true
        btnSi.topAnchor.constraint(equalTo:bgView.topAnchor, constant:0).isActive = true
        btnSi.widthAnchor.constraint(equalTo:bgView.widthAnchor, multiplier:1.0/7).isActive = true
        btnSi.heightAnchor.constraint(equalTo:btnSi.widthAnchor, multiplier:169.0/153).isActive = true
        
        let btnArray = [btnDo,btnRe,btnMi,btnFa,btnSol,btnLa,btnSi]
        
        for btn in btnArray {
            btn?.addTarget(self, action:#selector(musicKeyClicked(sender:)), for:.touchUpInside)
        }
    }
    
    func musicKeyClicked(sender: UIButton) {
        if btnDo == sender{
            listenMusicKeyClicked?(.Do)
        }
        else if btnRe == sender{
            listenMusicKeyClicked?(.Re)
        }
        else if btnMi == sender{
            listenMusicKeyClicked?(.Mi)
        }
        else if btnFa == sender{
            listenMusicKeyClicked?(.Fa)
        }
        else if btnSol == sender{
            listenMusicKeyClicked?(.Sol)
        }
        else if btnLa == sender{
            listenMusicKeyClicked?(.La)
        }
        else if btnSi == sender{
            listenMusicKeyClicked?(.Si)
        }
    }
}
