//
//  GroupChatDetailVC.swift
//  WantTalk
//
//  Created by 李依 on 2017/10/16.
//  Copyright © 2017年 李依. All rights reserved.
//

import Cocoa
import RealmSwift
import Realm
import SwiftyJSON
import SnapKit
import RxSwift
import Alamofire
import Kingfisher



class GroupChatDetailVC: RightChatDetailVC , IMRoomMessageDelegate{

    private var charToken: NotificationToken? //聊天列表通知
    var isNeedRemoveParentController = false
    var roomMembers = [JSON]()
    var isShowunRead = true
    var row: Int?



    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isGroupChat = true
        if let room = self.roomModel{
            IMMessageManager.sharedMessageManager.unReadToZero(id: "\(room.roomJidString!)+\(IMSessionManager.sharedSessionManager.username!)@coop")
        }
        
        self.refreshGroupList()
        IMXMPPManager.sharedXmppManager.groupRefreshHandler = {[weak self] in
            guard let strongSelf = self else{return}
            strongSelf.refreshGroupList()
        }
        self.isFirstIn = true

        self.itemDataSource = IMMessageManager.sharedMessageManager.getLocalOffLineMessage(friendId: self.roomModel!.roomJidString!+"+"+IMSessionManager.sharedSessionManager.username!+"@coop").sorted(by: ["date"]).map({return $0 })
        IMXMPPManager.sharedXmppManager.roomMessageDelegate = self

        let chatPredicate = NSPredicate(format: "userId = %@", "\(self.roomModel!.roomJidString!)+\(IMSessionManager.sharedSessionManager.username!)@coop")
        let chats = IMRealmUtil.findObjects(predicate: chatPredicate, object: IMChat.self)
        
        self.charToken = chats.addNotificationBlock({ [weak self](changes) in
            guard let strongSelf = self else{
                return
            }
            switch changes {
            case .initial:
                break
            case .update(let chats, let deletions, let insertions, _):
                strongSelf.itemDataSource = chats.sorted(by: ["date"]).map({ return $0 as! IMChat})
                if insertions.first() != nil && deletions.first() == nil{  //插入操作
                    let rows = insertions.map({IndexSet(IndexSet(integer: $0))})
                    if strongSelf.itemDataSource.last()!.fromMe && strongSelf.itemDataSource.count > 0{
                        for oneRow in rows{
                        strongSelf.chatDetailTV.insertRows(at: oneRow, withAnimation: .slideRight)
                        }
                    }else{
                        for oneRow in rows{
                            strongSelf.chatDetailTV.insertRows(at: oneRow, withAnimation: .slideLeft)
                        }
                    }
                    strongSelf.chatDetailTV.scrollRowToVisible(<#T##row: Int##Int#>)
                }else{
                    strongSelf.tableView.reloadData()
                }
                
                break
                
            case .error(let error):
                // 如果在后台工作线程中打开 Realm 文件，则会发生错误
                log.error("\(error)")
                fatalError("\(error)")
                break
            }
        })
        

    }
    
    //刷新群聊列表
    func refreshGroupList(){
        
        let roomId: String
        if self.roomModel!.roomName!.contains("@conference.coop") {
            roomId = self.roomModel!.roomName!
        } else {
            roomId = self.roomModel!.roomName! + "@conference.coop"
        }
        
        IMObjectManager.sharedObjectManager.taskToFetchGroupChatMembers(roomId: roomId).continueWith { [weak self](task) in
            guard let strongSelf = self else { return }
            if task.error != nil {
//                IMProgressHUD.im_showWarningWithStatus(string: task.error!.localizedDescription)
            } else {
                if !task.result!.isEmpty {
                    strongSelf.roomMembers.removeAll()
                    let arr = task.result!.sorted(by: {$0["userChatName"].stringValue.lowerInitials() < $1["userChatName"].stringValue.lowerInitials() })
                    strongSelf.roomMembers += arr
                }
            }
        }
    }

}
