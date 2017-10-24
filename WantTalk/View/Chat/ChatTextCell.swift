//
//  ChatTextCell.swift
//  WantTalk
//
//  Created by 李依 on 2017/10/17.
//  Copyright © 2017年 李依. All rights reserved.
//

import Cocoa
import RxSwift
import Kingfisher

typealias textBubbleBlock = (IMChat) -> () //文字气泡Block
typealias tapBlock = () -> ()

class ChatTextCell: NSTableCellView {

    @IBOutlet weak var headIV: NSImageView!
    @IBOutlet weak var headIVTrailingCS: NSLayoutConstraint!
    @IBOutlet weak var headIVLeadingCS: NSLayoutConstraint!
    
    @IBOutlet weak var timeL: NSTextField!

    @IBOutlet weak var contextL: NSTextField!
    @IBOutlet weak var contextLHeightCS: NSLayoutConstraint!
    @IBOutlet weak var contextLTrailingCS: NSLayoutConstraint!
    @IBOutlet weak var contextLLeadingCS: NSLayoutConstraint!
    
    private let garden = PublishSubject<NSImage>() //true=女 false=男
    var disposeBag = DisposeBag()
    var imchatModel: IMChat?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
//        self.wantsLayer = true
//        self.layer?.backgroundColor = NSColor().colorWithHexCode(code: "#f7f7f8").cgColor
    }
    
     func setCellContent(model: IMChat) {
        self.imchatModel = model
        contextL.backgroundColor = NSColor.red
//        (red: 0, green: 226/255.0, blue: 61/255.0, alpha: 0.9)

        self.garden.subscribe(onNext: { [weak self]image in
            guard let strongSelf = self else{return}
            strongSelf.headIV?.image = image
        }).addDisposableTo(disposeBag)
        IMRxManager.sharedRxManager.observableGender(id: model.chatSendId!.components(separatedBy: "@").first!, subject: self.garden)

        timeL.stringValue = model.date!.getHHmm()
//        if let richTextAttributedString = model.richTextAttributedString {
            self.contextL.stringValue = model.messageContext ?? ""
//        }
        contextLHeightCS.constant = self.contextL.getHeightWithContent()
        self.layoutSubviews()
    }
    
    
    // 設置大頭貼
    func setAvatar(userId: String) {
        
        if userId == "00000000@coop" {
            self.headIV!.image = NSImage(named: "wz")
//            self.setNeedsLayout()
            return
        }
        self.garden.subscribe(onNext: { [weak self]image in
            guard let strongSelf = self else{return}
            strongSelf.headIV?.image = image
        }).addDisposableTo(disposeBag)
        
        IMRxManager.sharedRxManager.observableGender(id: userId.components(separatedBy: "@").first!, subject: self.garden)
        
    }
    
    func layoutSubviews(){
        guard let model = self.imchatModel else {
            return
        }
        if model.fromMe {
            self.headIVTrailingCS.constant = 20
//            self.headIVLeadingCS.constant = self.frame.size.width - 55
            self.contextLTrailingCS.constant = 75
            self.contextLLeadingCS.constant = 100
            self.contextL.alignment = .right
        }else{
            self.headIVLeadingCS.constant = 20
            self.contextLTrailingCS.constant = 100
            self.contextLLeadingCS.constant = 75
            self.contextL.alignment = .left
        }

    }

}
