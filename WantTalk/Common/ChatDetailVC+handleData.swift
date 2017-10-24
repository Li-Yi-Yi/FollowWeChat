//
//  ChatDetailVC+handleData.swift
//  WantTalk
//
//  Created by 李依 on 2017/10/18.
//  Copyright © 2017年 李依. All rights reserved.
//

import Cocoa
import SwiftyJSON


extension RightChatDetailVC {
    /**
     *  发送文字
     */
    func chatSendText() {
        
        dispatch_async_safely_to_main_queue { [weak self] in
            guard let strongSelf = self else {return}
            let textView = self?.sendMsgTF
            //            guard textView.text.characters.count < 1000 else {
            //                IMProgressHUD.im_showWarningWithStatus(string: "超出字数限制")
            //                return
            //            }
            let text = textView?.string?.trimmingCharacters(in: NSCharacterSet.whitespaces)
            if text?.characters.count == 0 {
//                IMProgressHUD.im_showWarningWithStatus(string: "不能发空白消息")
                return
            }
            
            let string = self?.sendMsgTF.string
            
            // 判斷是否為群聊
            let model: IMChat
            
            if !strongSelf.isGroupChat {
                model = IMChat(text: string!, receivedId: strongSelf.id.components(separatedBy: "+").first())
            } else {
                model = IMChat(text: string!, receivedId: strongSelf.roomModel?.roomJid?.bare())
            }
            
            model.nickName = IMXMPPManager.sharedXmppManager.userChineseName
            model.date = model.getCurrentDate()
            
            // 判断自己是否在线，无在线提示连接网络
            if IMXMPPManager.sharedXmppManager.xmppStream!.myPresence == nil {
//                IMProgressHUD.im_showWarningWithStatus(string: "发送失败，请检查网络状态")
                return
            }
            
            if IMXMPPManager.sharedXmppManager.xmppStream!.myPresence.type() == "unavailable" {
//                IMProgressHUD.im_showWarningWithStatus(string: "发送失败，检查网络状态")
                return
            }
            // 判斷是否為群聊
            
            let userId = model.fromMe ? model.chatReceivedId :model.chatSendId
            let myId =  model.fromMe ? model.chatSendId :model.chatReceivedId
            let id = "\(myId!)+\(userId!)"
            
            if !strongSelf.isGroupChat {
                IMXMPPManager.sharedXmppManager.sendMessage(chatModel: model)
                IMMessageManager.sharedMessageManager.addOffLineMessage(message: model, isOwn: true)
                log.info("单聊发送【文字】 接收人: \(model.chatReceivedId!) 消息时间: \(model.date!)")
            } else {
                IMXMPPManager.sharedXmppManager.sendRoomMessage(chatModel: model)
                let roomName = model.chatReceivedId?.components(separatedBy: "@conference.coop")[0]
                IMMessageManager.sharedMessageManager.addOffLineMessage(message: model, isOwn: true,roomName: roomName)
                
                log.info("群聊发送 【文字】 接收人: \(model.chatReceivedId!) 消息时间: \(model.date!)")
            }
            //修改草稿为空
            IMMessageManager.sharedMessageManager.updateDraft(content: "", id: id)
            textView?.string = "" // 发送完毕后清空
            self?.chatDetailTV.scrollBottomToLastRow()
//            textView?.content
            
//            strongSelf.textViewDidChange(strongSelf.chatActionBarView.inputTextView)
        }
    }

    
}
