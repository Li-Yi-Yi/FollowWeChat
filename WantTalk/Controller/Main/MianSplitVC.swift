//
//  MianSplitVC.swift
//  WantTalk
//
//  Created by 李依 on 2017/10/12.
//  Copyright © 2017年 李依. All rights reserved.
//

import Cocoa

class MianSplitVC: NSSplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.addSplitItem()
    }
    
    //添加splitItem
    func addSplitItem(){
        let item1 = NSSplitViewItem(contentListWithViewController: LeftMenuVC())
        item1.maximumThickness = 70
        item1.minimumThickness = 70
        let item2 = NSSplitViewItem(contentListWithViewController: CentreMsgListVC())
        item2.minimumThickness = 250
        item2.maximumThickness = 300
        let item3 = NSSplitViewItem(contentListWithViewController: RightChatDetailVC())
        item3.minimumThickness = 550
        item3.maximumThickness = 1100
        for item in [item1,item2,item3]{
            self.addSplitViewItem(item)
        }
    }
    
//    override func splitView(_ splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
//       
//        return false
//    }
    
//    override func splitView(_ splitView: NSSplitView, shouldCollapseSubview subview: NSView, forDoubleClickOnDividerAt dividerIndex: Int) -> Bool {
//        return true
//    }
    
//    func splitView(_ splitView: NSSplitView, shouldHideDividerAt dividerIndex: Int) -> Bool {
//         return true
//    }
//    override func splitView(_ splitView: NSSplitView, additionalEffectiveRectOfDividerAt dividerIndex: Int) -> NSRect {
//        return CGRect(x: 0, y: 0, width: 500, height: 550)
//    }
}
