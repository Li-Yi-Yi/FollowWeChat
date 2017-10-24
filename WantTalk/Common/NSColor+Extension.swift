//
//  NSColor+Extension.swift
//  WantTalk
//
//  Created by 李依 on 2017/10/10.
//  Copyright © 2017年 李依. All rights reserved.
//
/**
 *  颜色扩展，项目内所用到的颜色，在这里进行配置
 */


import Foundation
import AppKit

public extension NSColor {
   
    //	//16进制转换成NSColor
    public class func colorWithRGBHex(hex:UInt32,alpha:CGFloat = 1) -> NSColor {
        let r = CGFloat((hex >> 16) & 0xFF)
        let g = CGFloat((hex >> 8) & 0xFF)
        let b = CGFloat((hex) & 0xFF)
        return NSColor(red: r/225.0, green:g/225.0, blue: b/225.0, alpha: alpha)
    }

    func colorWithHexCode(code : String) -> NSColor{
        let colorComponent = {(start : Int ,length : Int) -> CGFloat in
        let i = code.index(code.startIndex, offsetBy: start)
        let j = code.index(code.startIndex, offsetBy: start+length)
            
        var subHex = code.substring(with: Range(i..<j)) //
            
        subHex = subHex.characters.count < 2 ? "\(subHex)\(subHex)" : subHex
        var component:UInt32 = 0
            Scanner(string: subHex).scanHexInt32(&component)
          return CGFloat(component) / 255.0
        }
        
        let argb = {() -> (CGFloat,CGFloat,CGFloat,CGFloat) in
            switch(code.characters.count) {
            case 3: //#RGB
                let red = colorComponent(0,1)
                let green = colorComponent(1,1)
                let blue = colorComponent(2,1)
                return (red,green,blue,1.0)
            case 4: //#ARGB
                let alpha = colorComponent(0,1)
                let red = colorComponent(1,1)
                let green = colorComponent(2,1)
                let blue = colorComponent(3,1)
                return (red,green,blue,alpha)
            case 6: //#RRGGBB
                let red = colorComponent(0,2)
                let green = colorComponent(2,2)
                let blue = colorComponent(4,2)
                return (red,green,blue,1.0)
            case 8: //#AARRGGBB
                let alpha = colorComponent(0,2)
                let red = colorComponent(2,2)
                let green = colorComponent(4,2)
                let blue = colorComponent(6,2)
                return (red,green,blue,alpha)
            default:
                return (1.0,1.0,1.0,1.0)
            }}
        let color = argb()
        return NSColor(red: color.0, green: color.1, blue: color.2, alpha: color.3)
    }


}
