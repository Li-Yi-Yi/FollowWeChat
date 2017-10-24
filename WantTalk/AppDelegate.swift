//
//  AppDelegate.swift
//  WantTalk
//
//  Created by 李依 on 2017/9/27.
//  Copyright © 2017年 李依. All rights reserved.
//

import Cocoa
import ApplicationServices
import RealmSwift
import Alamofire

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var windowVC:NSWindowController?
    var loginVC:LoginVC?
    
    var isFirstLogin: Bool = false //在登录页面登录
    var pushKey: String?
    var isPushLogout: Bool = false
    let netWorkManager = NetworkReachabilityManager()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        
        loginVC = LoginVC(nibName: "LoginVC", bundle: Bundle.main)
        
        let mainWindow = loginVC != nil ? NSWindow(contentViewController: loginVC!) : nil
        
        windowVC = NSWindowController(window: mainWindow)
        
        loginVC?.windowController = windowVC
        windowVC?.showWindow(nil)
        
        
        
        
/*
        window = NSWindow(contentRect: NSMakeRect(10,10,300,300),styleMask: NSWindowStyleMask.borderless, backing: NSBackingStoreType.buffered, defer: false)
        let loginVC = LoginVC()
        window?.contentView?.addSubview(loginVC.view)
        window?.makeKeyAndOrderFront(nil)
        */
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    //MARK:
    func getChatterSize() -> CGSize {
        
        return CGSize(width: 280, height: 480)
    }
    
}

