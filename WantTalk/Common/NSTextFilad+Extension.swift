//
//  NSTextFilad+Extension.swift
//  WantTalk
//
//  Created by 李依 on 2017/10/10.
//  Copyright © 2017年 李依. All rights reserved.
//

import Foundation
import AppKit

extension NSTextField{
    
    
    //自适应文字的高度
    func sizeFitHeight(){
        let w = self.frame.width
        self.sizeToFit()
        self.frame.size.width = w
    }
    
    //自适应文字的宽度
    func sizeFitWidth(padding: CGFloat = 0){
        let h = self.frame.height
        self.sizeToFit()
        self.frame.size.height = h
        
        self.frame.size.width += padding
    }

}

//文字+颜色的实体类
struct MutableTextColor{
    var text: String!
    var color: NSColor!
    init(text: String, color: NSColor){
        self.text = text
        self.color = color
    }
}

extension NSTextField{
    //彩色的label...
    func addTextByColor(texts: [MutableTextColor]){
        var curStr = ""
        for text in texts{
            curStr += text.text
        }
        
        let countStr = NSMutableAttributedString(string: curStr)
        for text in texts{
            if (curStr as NSString).range(of: text.text).location != NSNotFound{
                countStr.addAttribute(NSForegroundColorAttributeName, value: text.color, range: (curStr as NSString).range(of: text.text))
            }
        }
        self.attributedStringValue = countStr
     }
    
    public func getHeightWithContent()->CGFloat{
        if stringValue.characters.count == 0 {
            return 0
        }
             let atts = [NSFontAttributeName:self.font]
        let text1 = stringValue as NSString
        
        let size = CGSize(width:self.frame.size.width,height:1000)
        let rect = text1.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: atts, context: NSStringDrawingContext())

        return rect.size.height
    }

}
