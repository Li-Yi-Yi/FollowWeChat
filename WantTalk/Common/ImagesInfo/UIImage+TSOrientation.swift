//
//  NSImage+TSOrientation.swift
//  WantTalk
//
//  Created by 李依 on 2017/10/20.
//  Copyright © 2017年 李依. All rights reserved.
//

import Cocoa
import QuartzCore
import CoreGraphics
import Accelerate

 extension NSImage {

    class func ts_fixImageOrientation(_ src:NSImage) -> NSImage {
        
//        if src.imageOrientation == NSImageOrientation.up {
//            return src
//        }
//        
//        var transform: CGAffineTransform = CGAffineTransform.identity
//        
//        switch src.imageOrientation {
//        case NSImageOrientation.down, NSImageOrientation.downMirrored:
//            transform = transform.translatedBy(x: src.size.width, y: src.size.height)
//            transform = transform.rotated(by: CGFloat(Double.pi))
//            break
//        case NSImageOrientation.left, NSImageOrientation.leftMirrored:
//            transform = transform.translatedBy(x: src.size.width, y: 0)
//            transform = transform.rotated(by: CGFloat(Double.pi / 2))
//            break
//        case NSImageOrientation.right, NSImageOrientation.rightMirrored:
//            transform = transform.translatedBy(x: 0, y: src.size.height)
//            transform = transform.rotated(by: CGFloat(-(Double.pi / 2)))
//            break
//        case NSImageOrientation.up, NSImageOrientation.upMirrored:
//            break
//        }
//        
//        switch src.imageOrientation {
//        case NSImageOrientation.upMirrored, NSImageOrientation.downMirrored:
//            transform.translatedBy(x: src.size.width, y: 0)
//            transform.scaledBy(x: -1, y: 1)
//            break
//        case NSImageOrientation.leftMirrored, NSImageOrientation.rightMirrored:
//            transform.translatedBy(x: src.size.height, y: 0)
//            transform.scaledBy(x: -1, y: 1)
//        case NSImageOrientation.up, NSImageOrientation.down, NSImageOrientation.left, NSImageOrientation.right:
//            break
//        }
//        
//        let ctx:CGContext = CGContext(data: nil, width: Int(src.size.width), height: Int(src.size.height), bitsPerComponent: src.cgImage!.bitsPerComponent, bytesPerRow: 0, space: src.cgImage!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
//        
//        ctx.concatenate(transform)
//        
//        switch src.imageOrientation {
//        case NSImageOrientation.left, NSImageOrientation.leftMirrored, NSImageOrientation.right, NSImageOrientation.rightMirrored:
//            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.height, height: src.size.width))
//            break
//        default:
//            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.width, height: src.size.height))
//            break
//        }
//        
//        let cgimage:CGImage = ctx.makeImage()!
//        let image:NSImage = NSImage(cgImage: cgimage)
        
        return src
    }
    
}
