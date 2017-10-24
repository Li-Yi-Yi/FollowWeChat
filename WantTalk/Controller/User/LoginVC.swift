//
//  LoginVC.swift
//  WantTalk
//
//  Created by 李依 on 2017/9/28.
//  Copyright © 2017年 李依. All rights reserved.
//

import Cocoa

class LoginVC: NSViewController,NSWindowDelegate {
    var windowController: NSWindowController?
    var mianWindowController: NSWindowController?
    var xmppManager: IMXMPPManager!


    @IBOutlet weak var workNumTF: NSTextField!
    @IBOutlet weak var passWordTF: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        
        
        self.xmppManager = IMXMPPManager.sharedXmppManager
        self.xmppManager.failHandler = {(message) -> Void in
//            IMProgressHUD.im_showErrorWithStatus(string: message!)
        }
        
        self.xmppManager.successHandler = { (userProfile) -> Void in
            IMSessionManager.sharedSessionManager.login(userProfile: userProfile)
        }
        

    }
    
    
    
    @IBAction func onClickLoginBtn(_ sender: NSButton) {
        IMXMPPManager.sharedXmppManager.loginWithuserName(userName: self.workNumTF.stringValue, password: self.passWordTF.stringValue, isLogined: false)
        // XMPP加载好友结束后 调用
        IMXMPPManager.sharedXmppManager.sucessLoginedHandle = { () in
                    let mainVC = MianSplitVC(nibName:"MianSplitVC",bundle:Bundle.main)
                    let mianWindow = mainVC != nil ? NSWindow(contentViewController:mainVC!) : nil
                    self.mianWindowController = NSWindowController(window:mianWindow)
                    self.mianWindowController?.showWindow(nil)
//                    self.mianWindowController.
                    self.windowController?.close()
                          }

  
        
              

        
        
/*
        // 创建视图控制器，加载xib文件
        
        let sub1ViewController = NSViewController(nibName: "sub1ViewController", bundle: Bundle.main)
        
        // 创建窗口，关联控制器
        
        let sub1Window = sub1ViewController != nil ? NSWindow(contentViewController: sub1ViewController!) : nil
        
        // 初始化窗口控制器
        
        sub1WindowController = NSWindowController(window: sub1Window)
        
        // 显示窗口
        
        sub1WindowController?.showWindow(nil)
 */
    }
}
