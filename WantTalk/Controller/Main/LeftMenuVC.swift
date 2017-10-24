//
//  LeftMenuVC.swift
//  WantTalk
//
//  Created by 李依 on 2017/10/12.
//  Copyright © 2017年 李依. All rights reserved.
//

import Cocoa

class LeftMenuVC: NSViewController {

    @IBOutlet weak var headBtn: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(red:0.15, green:0.15, blue:0.15, alpha:1.00).cgColor
    }
    
    
    @IBAction func OnClickMenuBtns(_ sender: NSButton) {
        
        switch sender.tag {
        case 1:
            print("点击头像")
        case 2:
            print("点击消息")
        case 3:
            print("点击用户")
        case 4:
            print("点击其他")
        default:
            break
        }
    }
    
    
}
