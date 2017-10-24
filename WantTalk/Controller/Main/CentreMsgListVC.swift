//
//  CentreMsgListVC.swift
//  WantTalk
//
//  Created by 李依 on 2017/10/12.
//  Copyright © 2017年 李依. All rights reserved.
//

import Cocoa
import RxSwift
import Alamofire
import RealmSwift
import XMPPFramework

/**
 *  消息列表控制器
 */

// 通知：从好友列表进入聊天页面
let IMNotificationMesPushToChatVC: NSNotification.Name = NSNotification.Name(rawValue: "IMNotificationMesPushToChatVC")

// 通知：从群聊列表进入聊天页面
let IMNotificationMesPushToGroupChatVC: NSNotification.Name = NSNotification.Name(rawValue: "IMNotificationMesPushToGroupChatVC")

// 通知：从好友搜索列表进入聊天页面
let IMNotificationSearchPushToChatVC: NSNotification.Name = NSNotification.Name(rawValue: "IMNotificationSearchPushToChatVC")

// 通知：开始接收消息
let IMNotificationWillReceiveMsg: NSNotification.Name = NSNotification.Name(rawValue: "IMNotificationWillReceiveMsg")

// 通知：结束接收消息
let IMNotificationDidReceiveMsg: NSNotification.Name = NSNotification.Name(rawValue: "IMNotificationDidReceiveMsg")

typealias unReadBlock = (_ num: String)->Void

//var msg_unReadLabel: UILabel = {
//    let unRead = UILabel.im_labelWithFontSize(size: 16.0, textColor: UIColor.white, backgroundColor: UIColor(colorNamed: IMColor.unReadRed), numberOfLines: 1)
//    unRead?.isHidden = true
//
//    unRead?.font = UIFont(name: "Arial", size: 11)
//    unRead?.layer.cornerRadius = 10.0
//    unRead?.adjustsFontSizeToFitWidth = true
//    unRead?.textAlignment = .center
//    unRead?.layer.masksToBounds = true
//    return unRead!
//}()


class CentreMsgListVC: NSViewController ,NSTableViewDelegate,NSTableViewDataSource,IMMessagListDelegate{
    var sessionManager: IMSessionManager?
    
    var messageManager: IMMessageManager?
    private var token : NotificationToken?  //realm通知
    private var friend: NotificationToken? //好友备注名更改通知
    
    
    var disposeBag = DisposeBag()
    
    var messageList = [IMMessageList2]() // 消息列表数组
    
    var str: String = "friends"
    var updateMessgaeQueue: DispatchQueue?  // 串号队列，里面的线程串号执行
    var unReadCharHandler: unReadBlock?
    var unReadGroupHandler: unReadBlock?
    //    var titleView: IMMessageTitleView?
    //    var titleView2: IMChatTitleView!
    var timer: Timer?
    var didConnect = true  //登录之后进行提示收取中。。
    @IBOutlet weak var tableView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
            //       self.titleView2 = IMChatTitleView(frame: CGRect(x: 0, y: 0, width: 250.Sw(), height: 50))
        //        self.titleView2.titleLabel.text = "消息"
        //        self.navigationItem.titleView = self.titleView2
        //
        //        self.titleView = IMMessageTitleView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
        //
        IMXMPPManager.sharedXmppManager.receiveHandler = { [weak self](type: String) in
            guard let strongSelf = self else{
                return
            }
            if type == "0"{
                strongSelf.didConnect = true
            }
            if type == "1" && strongSelf.didConnect == true{
                strongSelf.timer?.invalidate()
                strongSelf.timer = nil
                //                strongSelf.navigationItem.titleView = strongSelf.titleView
                //                strongSelf.titleView?.start()
                strongSelf.timer = Timer.scheduledTimer(timeInterval: 1, target: strongSelf, selector: #selector(strongSelf.stopReceiveMsg), userInfo: nil, repeats: false)
            }
        }
        
        /*
         IMXMPPManager.sharedXmppManager.invitationHandler = {[weak self] in
         guard let strongSelf = self else{return}
         // 点击添加新朋友事件
         let rootVC = strongSelf.tabBarController as? IMRootViewController
         rootVC?.selectedIndex = 1
         let contanctVC = rootVC?.contanctNav
         contanctVC?.navigationController?.popToRootViewController(animated: false)
         let viewController = IMNewFriendViewController()
         viewController.updateTipViewHandler = { () in
         contanctVC?.newFriendView!.tipView!.isHidden = true
         UserDefaults.standard.set(false, forKey: "\(kShowNewFriendTip)\(IMXMPPManager.sharedXmppManager.username!)")
         }
         viewController.hidesBottomBarWhenPushed = true
         _ = strongSelf.navigationController?.popViewController(animated: false)
         DispatchQueue.main.async {
         contanctVC?.navigationController?.pushViewController(viewController, animated: true)
         }
         }
         */
        
        self.sessionManager = IMSessionManager.sharedSessionManager
        self.messageManager = IMMessageManager.sharedMessageManager
        
        self.updateMessgaeQueue = DispatchQueue(label: "QueueUpdateMessgae")
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView.register(NSNib(nibNamed:"MainCell",bundle:nil),forIdentifier:"MainCell")
        self.tableView.selectionHighlightStyle = .regular
        IMXMPPManager.sharedXmppManager.messageListDelegate = self
        
        // 通知：从好友列表进入聊天页面
        NotificationCenter.default.addObserver(forName: IMNotificationMesPushToChatVC, object: nil, queue: nil) { [weak self](notification) in
            guard let strongSelf = self else { return }
            
            let model = notification.userInfo!["model"] as! IMFriend2
            
            //            strongSelf.tabBarController?.selectedIndex = 0
            
            var row = -1
            for (index, item) in strongSelf.messageList.enumerated() {
                if (model.userId!+"@coop"+"+"+strongSelf.sessionManager!.username!+"@coop") == item.userId! {
                    row = index
                    break
                }
            }
            
            if row >= 0 {
                //                strongSelf.tableView(strongSelf.tableView!, didSelectRowAt: IndexPath(row: row, section: 0))
            } else {
                //                let chatController: IMChatViewController = IMChatViewController()
                //                let id = "\(model.userId!)@coop+\(IMSessionManager.sharedSessionManager.username!)@coop"
                //                chatController.friend = model
                //                chatController.title = model.nickName
                //                chatController.id = id
                //                chatController.nickName = model.nickName
                //                chatController.hidesBottomBarWhenPushed = true
                //                strongSelf.navigationController?.pushViewController(chatController, animated: true)
            }
        }
        
        // 通知：从搜索列表进入聊天页面
        NotificationCenter.default.addObserver(forName: IMNotificationSearchPushToChatVC, object: nil, queue: nil) { [weak self](notification) in
            guard let strongSelf = self else { return }
            let model: IMFriend2 = notification.userInfo!["model"] as! IMFriend2
            //            strongSelf.tabBarController!.selectedIndex = 0
            var row = -1
            for (index, item) in strongSelf.messageList.enumerated() {
                if (model.userId!+"@coop"+"+"+strongSelf.sessionManager!.username!+"@coop") == item.userId! {
                    row = index
                    break
                }
            }
            
            if row >= 0 {
                //                strongSelf.tableView(strongSelf.tableView!, didSelectRowAt: IndexPath(row: row, section: 0))
            } else {
                //                let chatController: IMChatViewController = IMChatViewController()
                //                let id = "\(model.jidId!)+\(IMSessionManager.sharedSessionManager.username!)@coop"
                //                chatController.friend = model
                //                chatController.id = id
                //                chatController.nickName = model.nickName!
                //                chatController.hidesBottomBarWhenPushed = true
                //                strongSelf.navigationController?.pushViewController(chatController, animated: true)
                
            }
        }
        
        //网络监测
        let applegate = NSApplication.shared().delegate as! AppDelegate
        applegate.netWorkManager?.listener = { [weak self] status in
            guard let strongSelf = self else { return }
            switch status {
            case .reachable(.ethernetOrWiFi):
                
                print("IMXMPPManager.sharedXmppManager.xmppStream!.myPresence = \(IMXMPPManager.sharedXmppManager.xmppStream!.myPresence)")
                print("IMXMPPManager.sharedXmppManager.xmppStream!.myPresence.type()=\(IMXMPPManager.sharedXmppManager.xmppStream!.myPresence.type())")
                if IMXMPPManager.sharedXmppManager.xmppStream!.myPresence == nil || IMXMPPManager.sharedXmppManager.xmppStream!.myPresence.type() == "unavailable"{
                    if IMXMPPManager.sharedXmppManager.connect(){
                        print("connected")
                    }
                }
                strongSelf.tableView!.reloadData()
            case.reachable(.wwan):
                if IMXMPPManager.sharedXmppManager.xmppStream!.myPresence == nil || IMXMPPManager.sharedXmppManager.xmppStream!.myPresence.type() == "unavailable"{
                    if IMXMPPManager.sharedXmppManager.connect(){
                        print("connected")
                    }
                }
                strongSelf.tableView!.reloadData()
            default:
                print("网络异常")
            }
        }
        
        applegate.netWorkManager?.startListening()
        
        //messageList 通知
        let predicate = NSPredicate(format: "userId CONTAINS '+\(self.sessionManager!.username!)@coop'")
        let messageList  = IMRealmUtil.findObjects(predicate: predicate, object: IMMessageList2.self)
        self.messageList = messageList.sorted(by: ["date"]).reversed().map({return $0 as! IMMessageList2})
        NotificationCenter.default.post(name: IMUserChatDetail, object: self.messageList[0])

        
        self.token = messageList.addNotificationBlock({ [weak self](changes: RealmCollectionChange<Results<Object>>) in
            guard let strongSelf = self else{
                return
            }
            switch changes {
            case .initial:
                // Results 现在已经填充完毕，可以不需要阻塞 UI 就可以被访问
                strongSelf.tableView?.reloadData()
                break
            case .update(_, _,  _,  _):
                let unReadInt = IMMessageManager.sharedMessageManager.getUnReadNum(id: IMSessionManager.sharedSessionManager.username!)
                let messageList  = IMRealmUtil.findObjects(predicate: predicate, object: IMMessageList2.self)
                strongSelf.messageList = messageList.sorted(by: ["date"]).reversed().map({return $0 as! IMMessageList2})
                
                let unRead = unReadInt <= 0 ? "0" : "\(unReadInt)"
                //                strongSelf.tabBarItem.badgeValue = unRead
                NotificationCenter.default.post(name: IMNotificationTabBarItemUnreadMessage, object: nil, userInfo: ["unReadMesNum": unRead])
                strongSelf.tableView?.reloadData()
                break
            case .error(let error):
                // 如果在后台工作线程中打开 Realm 文件，则会发生错误
                fatalError("\(error)")
                break
            }
        })
        
        let group = IMRealmUtil.findObjects(predicate: nil, object: IMFriend2.self)
        self.friend = group.addNotificationBlock { (changes) in
            switch changes {
            case .initial:
                break
            case .update(_, _,  _,  _):
                // Query results have changed, so apply them to the UITableView
                self.tableView?.reloadData()
                break
            case .error(let error):
                // 如果在后台工作线程中打开 Realm 文件，则会发生错误
                fatalError("\(error)")
                break
            }
        }
        
        
        NotificationCenter.default.addObserver(forName: IMNotificationTabBarItemUnreadMessage, object: nil, queue: nil) { [weak self](notification) in
            //            guard let strongSelf = self else{return}
            let num = (notification.userInfo!["unReadMesNum"] as! String)
            if let n = Int(num){
                if n > 99{
                    
                }else{
                    
                }
            }
        }
        
        
        let unReadInt = IMMessageManager.sharedMessageManager.getUnReadNum(id: IMSessionManager.sharedSessionManager.username!)
        let unRead = unReadInt <= 0 ? "0" : "\(unReadInt)"
        //        self.tabBarItem.badgeValue = unRead //消息栏未读数
        NotificationCenter.default.post(name: IMNotificationTabBarItemUnreadMessage, object: nil, userInfo: ["unReadMesNum": unRead])
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
    }
    
    override func viewDidAppear() {
        super.viewWillAppear()
        
        //检查最新版本
        IMObjectManager.sharedObjectManager.taskToCheckVersion(userId: self.sessionManager!.username!, envType: "prd").continueWith { [weak self](task) in
            //            guard let strongSelf = self else { return }
            if task.error == nil {
                let localVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
                if localVersion != task.result!.version {
                    //                    strongSelf.taskToShowNewVersion(confirmClosure: { (alert) in
                    //                        if UIApplication.shared.openURL(URL(string: task.result!.downLoadURL!)!){
                    //                            log.debug("打开更新URL")
                    //                        }
                    //                    }, cancelClosure: nil)
                }
            }
        }
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
    }
    
    func stopReceiveMsg(){
        //        self.navigationItem.titleView = nil
        //        self.navigationItem.titleView = self.titleView2
        //        self.titleView?.stop()
        self.timer?.invalidate()
        self.timer = nil
        self.didConnect = false
    }
    
    //    // 退出
    //    func logout(sender: UIBarButtonItem) {
    //        IMProgressHUD.im_showWithStatus(string: nil)
    //        IMObjectManager.sharedObjectManager.taskToLogout(userID: IMSessionManager.sharedSessionManager.username!, token: IMTokenManager.sharedTokenManager.token!).continueWith { (task) in
    //            IMProgressHUD.im_dismiss()
    //            IMSessionManager.sharedSessionManager.logout()
    //        }
    //    }
    
    // MARK: UITableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.messageList.count
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        /*
         
         static NSString *ID = @"myCell";
         UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
         
         if (cell == nil) {
         // 实例化单元格
         cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
         }
         
         */
        let cellV = tableView.make(withIdentifier: "MainCell", owner: self) as! MainCell
        let messageList = self.messageList[row]
        cellV.configureWithFriendProfile(friendProfile: messageList)
        
        return cellV
    }
    
    
    
    
    // MARK: NSTableViewDelegate
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        let messageList = self.messageList[row]
        if messageList.isGroupChat == true {
            // 移除含有空白的群名稱
            if messageList.userId!.contains(" ") {
//                IMProgressHUD.im_showWarningWithStatus(string: "无效的群名称")
                IMXMPPManager.sharedXmppManager.resignGroupChat(roomJid: messageList.userId!)
                return true
            }
            // 移除含有大寫的群名稱
            
            for chr in messageList.userId!.characters {
                let string = String(chr)
                if string.lowercased() != string {
//                    IMProgressHUD.im_showWarningWithStatus(string: "无效的群名称")
                    IMXMPPManager.sharedXmppManager.resignGroupChat(roomJid: messageList.userId!)
                    return true
                }
            }
            
            // 進入群聊頁面
            let chatController: GroupChatDetailVC = GroupChatDetailVC()
            chatController.roomModel = IMRoom(jid: XMPPJID(string: messageList.userId!.components(separatedBy: "+").first!))
//            chatController.hidesBottomBarWhenPushed = true
            chatController.draft = messageList.draft
//            self.navigationController?.pushViewController(chatController, animated: true)
        }else{
            // 進入單聊頁面
            let chatController: RightChatDetailVC = RightChatDetailVC()
            chatController.id = messageList.userId
            chatController.nickName = messageList.nickName
            let friend = IMFriendsManager.sharedFriendManager.findFriendBy(id: messageList.userId!.components(separatedBy: "@coop").first!)
            if friend != nil{
                chatController.friend = friend
            }
//            chatController.hidesBottomBarWhenPushed = true
            chatController.draft = messageList.draft
//            self.navigationController?.pushViewController(chatController, animated: true)
            let messageList = self.messageList[row]
            NotificationCenter.default.post(name: IMUserChatDetail, object: messageList)
        }

        
        return true
    }
    
    
    
    open func selectRowIndexes(_ indexes: IndexSet, byExtendingSelection extend: Bool){
        print("点击了cell")
    }
    
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        print("点击了cell")
    }
    
    
    // MARK: UITableViewDelegate
    /*
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
     self.tableView!.deselectRow(at: indexPath, animated: true)
     
     }
     
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     return true
     }
     
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
     let rowAction =  UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: " 删除 ") { [weak self](tableViewRowAction, indexPath) in
     guard let strongSelf = self else { return }
     let list = strongSelf.messageList[indexPath.row]
     IMMessageManager.sharedMessageManager.deleteMessageList(id: list.userId!)
     }
     rowAction.backgroundColor = UIColor.red
     return [rowAction]
     }
     
     // MARK: MessageListDelegate
     func updateMessageListReceived() {
     //        self.updateMessageList()
     }
     
     deinit {
     self.token?.stop()
     self.friend?.stop()
     NotificationCenter.default.removeObserver(self, name: IMNotificationMesPushToChatVC, object: nil)
     }
     */
    
}
