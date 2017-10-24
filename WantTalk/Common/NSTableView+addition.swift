//
//  NSTableView+addition.swift
//  WantTalk
//
//  Created by 李依 on 2017/10/19.
//  Copyright © 2017年 李依. All rights reserved.
//

import Cocoa

 extension NSTableView{
    
    
    
    var lastIndexPath: Int? {
            return self.numberOfRows
    }
    
    // 键盘动画结束后调用
    func scrollBottomToLastRow() {

        
        //        guard let indexPath = self.lastIndexPath  else {
//            return
//        }
//        self.scrollRowToVisible(indexPath)
    }

}
