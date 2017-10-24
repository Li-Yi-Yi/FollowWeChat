//
//  MainCell.swift
//  WantTalk
//
//  Created by 李依 on 2017/10/10.
//  Copyright © 2017年 李依. All rights reserved.
//


import Cocoa
import RxSwift
import Kingfisher

class MainCell: NSTableCellView {
    @IBOutlet weak var headIV: NSImageView!
    @IBOutlet weak var nameTF: NSTextField!
    @IBOutlet weak var messageTF: NSTextField!
    @IBOutlet weak var timeTF: NSTextField!
    
    private var disposeBag = DisposeBag()
    private let garden = PublishSubject<NSImage>() //true=女 false=男

//    override init(frame frameRect: NSRect) {
//        super.init(frame: frameRect)
//    }
    

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    

    // 配置UI显示
    func configureWithFriendProfile(friendProfile: IMMessageList2) {
        
        if friendProfile.userId!.contains("@conference.coop") {
            if friendProfile.nickName != "" {
                self.nameTF!.stringValue = friendProfile.nickName
            } else {
                self.nameTF!.stringValue = friendProfile.userId!.components(separatedBy: "@").first!
            }
        }else{
            let predicate = NSPredicate(format: "userId = %@", friendProfile.userId!.components(separatedBy: "@coop").first!)
            let friends = IMRealmUtil.findObjects(predicate: predicate, object: IMFriend2.self)
            if friends.count > 0{
                if ((friends.first) as! IMFriend2).myId != IMSessionManager.sharedSessionManager.username{
                    if ((friends.first) as! IMFriend2).name == ""{
                        self.nameTF!.stringValue = ((friends.first) as! IMFriend2).userId!
                        IMObjectManager.sharedObjectManager.taskToFetchFriendDetail(id:((friends.first) as! IMFriend2).userId!).continueWith { (task) in //调用接口修改姓名
                            if task.error == nil {
                                let friend = IMFriend2(id: task.result!.first!.id!+"@coop", nickName: (task.result!.first!.name)!)
                                friend.name = (task.result!.first!.name)!
                                IMFriendsManager.sharedFriendManager.addfriend(friend: friend,isInterim: true) //用户信息存储。
                                self.nameTF!.stringValue = (task.result!.first!.name)!
                            }
                        }
                    }else{
                        self.nameTF!.stringValue = ((friends.first) as! IMFriend2).name
                    }
                }else{
                    self.nameTF!.stringValue = ((friends.first) as! IMFriend2).nickName!
                }
            }else{
                self.nameTF!.stringValue = friendProfile.nickName
            }
        }
        
//        self.tipLabel!.isHidden = !friendProfile.isShowTip
//        self.tipLabel!.snp.removeConstraints()
//        if friendProfile.unreadMesNumber > 99 {
//            self.tipLabel!.text = "99+"
//            self.tipLabel!.snp.makeConstraints { [weak self](make) in
//                guard let strongSelf = self else { return }
//                make.centerY.equalTo(strongSelf.contentView.snp.centerY).offset(10.0)
//                make.right.equalTo(strongSelf.contentView.snp.right).offset(-15.0)
//                make.height.equalTo(20.0)
//                make.width.equalTo(30.0)
//            }
//        } else if friendProfile.unreadMesNumber == 0{
//            self.tipLabel!.isHidden = true
//        }else{
//            self.tipLabel!.text = "\(friendProfile.unreadMesNumber)"
//            self.tipLabel!.snp.makeConstraints { [weak self](make) in
//                guard let strongSelf = self else { return }
//                make.centerY.equalTo(strongSelf.contentView.snp.centerY).offset(10.0)
//                make.right.equalTo(strongSelf.contentView.snp.right).offset(-15.0)
//                make.width.height.equalTo(20.0)
//            }
//        }
        if friendProfile.draft == ""{
            self.messageTF!.stringValue = friendProfile.recentMessage
        }else{
            let textList = [MutableTextColor(text: "[草稿] ", color: NSColor().colorWithHexCode(code : "8B0000")), MutableTextColor(text: friendProfile.draft, color: NSColor.black)]
            self.messageTF!.addTextByColor(texts: textList)
        }
        
        self.timeTF!.stringValue = friendProfile.date.getHHmm()
        
        
        if friendProfile.isGroupChat == true {
            self.headIV!.kf.setImage(with: nil, placeholder: NSImage(named: "head－group"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        else {
            self.garden.subscribe(onNext: { [weak self]image in
                guard let strongSelf = self else{return}
                strongSelf.headIV?.image = image
            }).addDisposableTo(self.disposeBag)
            IMRxManager.sharedRxManager.observableGender(id: friendProfile.userId!.components(separatedBy: "@").first!, subject: self.garden)
        }
    }

    
}
