//
//  ChatImageCell.swift
//  WantTalk
//
//  Created by 李依 on 2017/10/17.
//  Copyright © 2017年 李依. All rights reserved.
//

import Cocoa
import RxSwift
import Kingfisher



typealias imageBubbleBlock = () -> () //图片发送或者接收失败按钮

class ChatImageCell: NSTableCellView {
    
    @IBOutlet weak var timeL: NSTextField!
    @IBOutlet weak var headIV: NSImageView!
    @IBOutlet weak var headIVTrailingCS: NSLayoutConstraint!
    @IBOutlet weak var headIVLeadingCS: NSLayoutConstraint!
    
    @IBOutlet weak var chatImageView: NSImageView!
    @IBOutlet weak var chatIVTrailingCS: NSLayoutConstraint!
    @IBOutlet weak var chatIVLeadingingCS: NSLayoutConstraint!
    
    @IBOutlet weak var coverImageView: NSImageView!
    
    @IBOutlet weak var activityView: NSProgressIndicator!
    @IBOutlet weak var faildBtn: NSButton!  //感叹号 按钮
    @IBOutlet weak var sendActivity: NSProgressIndicator!

    
//    var avatarImageView: NSImageView?
//    var nickNamelLabel: UILabel?
    var model: IMChat?
    var imchatModel: IMChat?
    var tapAvatarHandle: tapBlock?
    var imagefailed: imageBubbleBlock?

//    var nameLabel: UILabel?
//    var dateLabel: UILabel!
    var isGroupChat: Bool = false
    var disposeBag = DisposeBag()
    private let garden = PublishSubject<NSImage>() //true=女 false=男

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    func setCellContent(model: IMChat,isGroupChat:Bool = false) {
        self.isGroupChat = isGroupChat
        
        self.imchatModel = model
        
        self.activityView.isHidden = true
        self.activityView.stopAnimation(nil)
        
        self.sendActivity.isHidden = true
        self.sendActivity.stopAnimation(nil)
        self.faildBtn.isHidden = true
        
        //我发送的
        if model.fromMe == true {
            if model.messgaeContentStr == "1"{
                switch model.sendType {
                case .Loading:
                    self.faildBtn.isEnabled = false
                    self.sendActivity.isHidden = false
                    self.sendActivity.startAnimation(nil)
                case .Failed:
                    self.faildBtn.isEnabled = true
                    self.faildBtn.isHidden = false
                default:
                    break
                }
            }
            
            if let _ = model.photoName {
                //不管是发送方还是接受方,都用kingfisher缓存管理区处理图片
                //列表页面显示缩略图,因为内存会暴增
                let image = NSImage(data: model.imageData as Data)
//                    NSImage(data: model.imageData as Data)
                let originalImage = NSImage.ts_fixImageOrientation(image!)//重新绘制，里面的方法注释掉了
                let thumbSize = ChatConfig.getThumbImageSize(originalImage.size)
                let thumbNail = originalImage
//                let thumbNail = originalImage.ts_resize(thumbSize)//需要重写
                self.chatImageView.image = thumbNail
            }
        } else {
            let image = NSImage(data: model.imageData as Data)
            self.chatImageView.image = image
            
            switch model.downType {
            case .Loading:
                self.faildBtn.isEnabled = false
                self.activityView.isHidden = false
                self.activityView.startAnimation(nil)
            case .Success:
                break
            case .Failed:
                self.faildBtn.isHidden = false
                self.faildBtn.isEnabled = true
            }
        }
        
        if self.isGroupChat {
            var name = model.nickName!
            if name.hasSuffix(")"){
                name = name.components(separatedBy: "(").first()!
            }
            
//            self.nickNamelLabel?.text = name//好友姓名
        }
        
        self.timeL?.stringValue = (model.date?.getHHmm())!
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
        var imageOriginalWidth = kChatImageMinWidth  //默认临时加上最小的值
        var imageOriginalHeight = kChatImageMinHeight   //默认临时加上最小的值
        
        if (model.imageWidth != nil) {
            imageOriginalWidth = stringToFloat(str: model.imageWidth!)
        }
        
        if (model.imageHeight != nil) {
            imageOriginalHeight = stringToFloat(str: model.imageHeight!)
        }
        
        //根据原图尺寸等比获取缩略图的 size
        let originalSize = CGSize(width: imageOriginalWidth, height: imageOriginalHeight)
        self.chatImageView!.frame.size = ChatConfig.getThumbImageSize(originalSize)
        
        if model.fromMe {
            self.headIVTrailingCS.constant = 20
//            self.headIVLeadingCS.constant = self.frame.size.width - 55
            self.chatIVTrailingCS.constant = 75
        }else{
            self.headIVLeadingCS.constant = 20
            self.chatIVLeadingingCS.constant = 75
        }

    }
}
