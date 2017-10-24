//
//  RightChatDetailVC.swift
//  WantTalk
//
//  Created by 李依 on 2017/10/12.
//  Copyright © 2017年 李依. All rights reserved.
//

import Cocoa
import SnapKit
import RxSwift
import Alamofire
//import BSImagePicker
import Kingfisher

import RealmSwift
import Realm

let IMUserChatDetail: NSNotification.Name = NSNotification.Name(rawValue: "IMUserChatDetail")//获取当前聊天者的信息

class RightChatDetailVC: NSViewController,IMMessageDelegate,NSTableViewDelegate,NSTableViewDataSource ,NSTextViewDelegate{
    
    
    private let netWorkManager = NetworkReachabilityManager()!
    private var charToken: NotificationToken? //聊天列表通知
    private var friendToken: NotificationToken? //修改好友通知
    var id: String!
    var nickName: String!
    var friend: IMFriend2?
    var roomModel: IMRoom?
    var sendModel: IMChat?
    var draft: String? //草稿
//    var chatActionBarView: IMChatActionBarView! // actionBar
    var actionBarPaddingBottomConstranit: Constraint? // action bar 的 bottom Constraint
    var keyboardHeightConstraint: NSLayoutConstraint? // 键盘的高度 Constraint
//    var emotionInputView: IMChatEmotionInputView! //表情键盘
//    var imagePicker: NSImagePickerController!   //照相机
//    var shareMoreView: IMChatShareMoreView!  //分享view
    
    var images = [NSImage]()//临时存放图片的数组
    
    let disposeBag = DisposeBag()
    var itemDataSource = [IMChat]()
    var isReloading: Bool = false //UITableView 是否正在加载数据，如果是，把当前发生的消息缓存起来后再进行发送
    
    var isEndRefreshing: Bool = true
    var isFirstIn: Bool = false
    var isGroupChat: Bool = false
    var isCurrent: Bool = true
    
    let imageQueue = DispatchQueue(label: "com.imageSend.com", qos: .default)
    
    var indexPathAndGroup: (IMFriend2, IndexPath?)?
    var IMoidModel: IMOidModel? //文件转换随机码
    var filePath: String! //文件存储沙盒路径
    
    //用户长按图片或者文件时删除文件操作的临时模型数据
    var imChatModelInCell: IMChat!
    var imChatModelInText: IMChat?   //用户长按文字时删除、复制操作的临时模型数据
    
    var indePathCurrent: IndexPath!
    
//    var titleView: IMChatTitleView!
    
//    var rootVC: IMRootViewController?

    
    @IBOutlet weak var chatDetailTV: NSTableView!
    @IBOutlet weak var sendMsgTF: NSTextView!
    @IBOutlet weak var sendMsgSV: NSScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isFirstIn = true

        IMXMPPManager.sharedXmppManager.messageDelegate = self

        
        chatDetailTV.delegate = self
        chatDetailTV.dataSource = self
        chatDetailTV.backgroundColor = NSColor().colorWithHexCode(code: "#f7f7f8")
        chatDetailTV.isEnabled = false
        sendMsgTF.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(refreshChatDetailTV(sender:)), name: IMUserChatDetail, object: nil)//接收到点击消息列表的事件

        
        // Do view setup here.
        //获取当前用户的聊天详情
        /*
        NotificationCenter.default.addObserver(forName: IMUserChatDetail, object: nil, queue: nil) { [weak self](notification) in
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
 */
    }
    
    
    func refreshChatDetailTV(sender:Notification){

        let messageList = sender.object as! IMMessageList2
        self.id = messageList.userId
        self.nickName = messageList.nickName
        let friend = IMFriendsManager.sharedFriendManager.findFriendBy(id: messageList.userId!.components(separatedBy: "@coop").first!)
        if friend != nil{
            self.friend = friend
        }
        self.draft = messageList.draft

        self.itemDataSource = IMMessageManager.sharedMessageManager.getLocalOffLineMessage(friendId: self.id).sorted(by: ["date"]).map({ return $0})
        netWorkManager.listener = { [weak self ] status in
            guard let strongSelf = self else { return }
            switch status {
            case .reachable(.ethernetOrWiFi):
                self?.chatDetailTV.reloadData()
            case .reachable(.wwan):
                self?.chatDetailTV.reloadData()
            default:
                print("网络错误")
            }
        }
        netWorkManager.startListening()
        
        let chatpPredicate = NSPredicate(format: "userId = %@", self.id!)
        let chats = IMRealmUtil.findObjects(predicate: chatpPredicate, object: IMChat.self)
        self.charToken = chats.addNotificationBlock({ [weak self](changes) in//自带监听数据库改变
            guard let strongSelf = self else{return}
            switch changes {
            case .initial:
                break
            case .update(let chats, let deletions, let insertions, _):
                strongSelf.itemDataSource = chats.sorted(by: ["date"]).map({ return $0 as! IMChat})
                if insertions.first != nil && deletions.first == nil{  //插入操作
                    let rows = insertions.map({ IndexSet(IndexSet(integer: $0))})
//                    if strongSelf.itemDataSource.last!.fromMe{
//                        self?.chatDetailTV.insertRows(at: [rows], withAnimation: .slideRight)
//                        //                        self?.chatDetailTV.insertRows(at: rows, withAnimation: .right)
//                    }else{
//                        //                        self?.chatDetailTV.insertRows(at: rows, with: .left)
//                    }
//                    //                    self?.chatDetailTV.scrollToRow(at: rows[0], at: .none, animated: true)
//                }else{
                    self?.chatDetailTV.reloadData()
                }
                break
            case .error(let error):
                log.error("\(error)")
                fatalError("\(error)")
                break
            }
        })
        
        if let f = self.friend{
            let predicate = NSPredicate(format: "userId = %@", f.userId!)
            let friends = IMRealmUtil.findObjects(predicate: predicate, object: IMFriend2.self)
            self.friendToken = friends.addNotificationBlock({ [weak self](changes) in
                guard let strongSelf = self else{return}
                switch changes {
                case .initial:
                    // Results 现在已经填充完毕，可以不需要阻塞 UI 就可以被访问
                    self?.chatDetailTV.reloadData()
                    break
                case .update(let friend, _, _, let modifications):
                    if let index = modifications.first {
                        strongSelf.friend = (friend[index] as! IMFriend2)
                    }
                    break
                case .error(let error):
                    log.error("\(error)")
                    fatalError("\(error)")
                    break
                }
            })
        }
        

        
    }
    
    
    // MARK: UITableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.itemDataSource.count
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        if self.itemDataSource.count == 0{
            return 45
        }
//        let cell = ChatTextCell()
//        let label = cell.contextL
//        let IV = cell.headIV
//        cell.contextL.stringValue = self.itemDataSource[row].messageContext ?? ""
//        let textHeight = cell.contextL.getHeightWithContent()
        let chatModel = self.itemDataSource[row]
        let type = chatModel.messgaeContentType
        switch type {
        case .Text:

            return 80
           
        case .Image:
            
            return 200
            
        default:
             return 80
        }
        
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let chatModel = self.itemDataSource[row]
        let type = chatModel.messgaeContentType
        switch type {
        case .Text:
        chatDetailTV.register(NSNib(nibNamed:"ChatTextCell",bundle:nil),forIdentifier:"ChatTextCell")

            let cellV = tableView.make(withIdentifier: "ChatTextCell", owner: self) as! ChatTextCell
        cellV.setAvatar(userId: chatModel.chatSendId!)

        cellV.setCellContent(model: chatModel)
        return cellV
     
        case .Image:
            chatDetailTV.register(NSNib(nibNamed:"ChatImageCell",bundle:nil),forIdentifier:"ChatImageCell")

            let cell = tableView.make(withIdentifier: "ChatImageCell", owner: self) as! ChatImageCell
            cell.setAvatar(userId: chatModel.chatSendId!)
            cell.setCellContent(model: chatModel, isGroupChat: false)
            cell.imagefailed = {[weak self] in
                guard let strongSelf = self else {
                    return
                }
                let imageModel = strongSelf.itemDataSource[row]
                let image = NSImage(data: imageModel.imageData as Data)
                if imageModel.fromMe{
                    do {
                        let realm = try Realm()
                        try realm.write {
                            realm.delete(imageModel)
                        }
                    }catch{
                        log.error("重新上传图片单聊--异常")
                    }
                    strongSelf.resizeAndSendImage(image!)
                }else{
                    strongSelf.reLoadingImage(imageModel.imageOid!, imagePath: imageModel.loaclPhotoPath!, row: row)
                }
            }
            return cell
              /*
        case .File:
            let cell = type.chatCell(tableView: tableView, indexPath: indexPath, model: chatModel, viewController: self)! as! IMChatFileCell
            cell.setAvatar(userId: chatModel.chatSendId!)
            cell.filefailed = {[weak self] in
                guard let strongSelf = self else {
                    return
                }
                let model = strongSelf.itemDataSource[indexPath.row]
                strongSelf.reLoadingFile(model.fileOid!, fileName: model.fileName!, row: indexPath.row)
            }
            return cell
   */
        default:
            return NSView()

        }

    }
    
    //MARK:截图文件表情
    @IBAction func onClickScreenshotBtns(_ sender: NSButton) {
        switch sender.tag {
        case 1:
             print("表情")
        case 2:
            print("表情")
        case 3:
            print("表情")
            let imageSize = CGSize(width: 100, height: 100)
//            let windowImage = 
            /*
             NSSize imageSize = NSMakeSize([self frame].size.width, [self frame].size.height);
             
             //CGImageRef windowImage = [self windowImageShot];
             AppDelegate *app = [[NSApplication sharedApplication] delegate];
             NSWindow *mainWindow = app.window;
             CGWindowID windowID = (CGWindowID)[mainWindow windowNumber];
             
             CGWindowImageOption imageOptions = kCGWindowImageNominalResolution;
             CGWindowListOption singleWindowListOptions = kCGWindowListOptionIncludingWindow | kCGWindowListExcludeDesktopElements;
             CGRect imageBounds = CGRectMake(mainWindow.frame.origin.x + self.window.frame.origin.x, NSHeight(mainWindow.screen.frame) - mainWindow.frame.origin.y - NSHeight(self.frame) - self.window.frame.origin.y, NSWidth(self.frame), NSHeight(self.frame));
             CGImageRef windowImage = CGWindowListCreateImage(imageBounds, singleWindowListOptions, windowID, imageOptions);
             
             NSImage *image = [[NSImage alloc] initWithCGImage:windowImage size:imageSize];
             CGImageRelease(windowImage);
             [image setDataRetained:YES];
             [image setCacheMode:NSImageCacheNever];
             */
        default:
            break
        }
        
        
    }
    
    

    
}
