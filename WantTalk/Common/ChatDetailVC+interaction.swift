//
//  ChatDetailVC+interaction.swift
//  WantTalk
//
//  Created by 李依 on 2017/10/18.
//  Copyright © 2017年 李依. All rights reserved.
//

import Cocoa
import Photos
//import MobileCoreServices
import Cent
import QuickLook
//import KSPhotoBrowser

import RealmSwift

extension RightChatDetailVC {
    
    
    
    func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
        if replacementString == "\n"{
                        // 点击发送文字，包含表情
                        self.chatSendText()
                        return false
                    }
                    return true

    }

//    
//    func textViewDidChange(_ textView: UITextView) {
//        let contentHeight = textView.contentSize.height
//        guard contentHeight < kChatActionBarTextViewMaxHeight else {
//            return
//        }
//        
//        self.chatActionBarView.inputTextViewCurrentHeight = contentHeight + 17
//        self.controlExpandableInputView(showExpandable: true)
//    }
//  
    
//    beginE
    
    
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        // 设置键盘类型，响应 UIKeyboardWillShowNotification 事件
//        self.chatActionBarView.inputTextViewCallkeyboard()
//        
//        // 使 UITextView 滚到末尾的区域
//        UIView.setAnimationsEnabled(false)
//        let range = NSMakeRange(textView.text.characters.count - 1, 1)
//        textView.scrollRangeToVisible(range)
//        UIView.setAnimationsEnabled(true)
//        return true
//    }
    
}

/*
// MARK: - @protocol ChatEmotionInputViewDelegate
// 表情点击完毕后
extension RightChatDetailVC: ChatEmotionInputViewDelegate {
    //点击表情
    func chatEmoticonInputViewDidTapCell(cell: IMChatEmotionsCell) {
        var string = self.chatActionBarView.inputTextView.text
        string = string!.appending(cell.emotionModel!.text)
        self.chatActionBarView.inputTextView.text = string
        self.textViewDidChange(self.chatActionBarView.inputTextView)
    }
    
    //点击撤退删除
    func chatEmoticonInputViewDidTapBackspace(cell: IMChatEmotionsCell) {
        self.chatActionBarView.inputTextView.deleteBackward()
    }
    
    //点击发送文字，包含表情
    func chatEmoticonInputViewDidTapSend() {
        self.chatSendText()
    }
}
 */

extension RightChatDetailVC/*: ChatShareMoreViewDelegate */{
    /**
     选择相册
     */
    /*
    func chatShareMoreViewPhotoTaped() {
        self.ts_presentImagePickerController(
            maxNumberOfSelections: 1,
            select: { (asset: PHAsset) -> Void in
                print("Selected: \(asset)")
        }, deselect: { (asset: PHAsset) -> Void in
            print("Deselected: \(asset)")
        }, cancel: { (assets: [PHAsset]) -> Void in
            print("Cancel: \(assets)")
        }, finish: {[weak self] (assets: [PHAsset]) -> Void in
            print("Finish: \(assets.get(index: 0))")
            guard let strongSelf = self else { return }
            for (index,_) in assets.enumerated() {
                if let image = assets.get(index: index).getNSImage() {
                    strongSelf.resizeAndSendImage(image)
                }
            }
            
            }, completion: { () -> Void in
                print("completion")
        })
    }
    
    /**
     选择相机
     */
    func chatShareMoreViewCameraTaped() {
        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if authStatus == .notDetermined {
            self.checkCameraPermission()
        } else if authStatus == .restricted || authStatus == .denied {
            IMAlertView_show("无法访问您的相机", message: "请到设置 -> 隐私 -> 相机 ，打开访问权限" )
            
        } else if authStatus == .authorized {
            self.openCamera()
        }
    }
    
    func checkCameraPermission () {
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: {granted in
            if !granted {
                IMAlertView_show("无法访问您的相机", message: "请到设置 -> 隐私 -> 相机 ，打开访问权限" )
            }
        })
    }
    
    func openCamera() {
        self.imagePicker =  NSImagePickerController()
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .camera
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    */
    
    //处理图片，并且发送图片消息
    func resizeAndSendImage(_ theImage: NSImage,resend: Bool = false) {
        var originalImage: NSImage!
        
        if resend{
            //重新发送图片图片已经压缩，不用压缩
            originalImage = theImage
        }else{
            //图片上传压缩
//            let compressImage = theImage.wxCompress()//mac上没有这个方法
            originalImage = NSImage.ts_fixImageOrientation(theImage)
        }
        
        let storeKey = "send_image"+String(format: "%f", Date().timeIntervalSince1970 * 1000)
        
        let imageModel: IMChat
        var localThumbnailImagePath: String = ""
        var chatSendId = ""
        var receiverId = ""
        var userId = ""
        var date = ""
        
        if self.isGroupChat == true{
            imageModel = IMChat(imageUrl: "", receivedId: self.roomModel?.roomJidString, imageHeight: originalImage.size.height, imageWidth: originalImage.size.width, photoName: storeKey,image: originalImage)
            imageModel.nickName = IMXMPPManager.sharedXmppManager.userChineseName
            imageModel.date = imageModel.getCurrentDate()
            chatSendId = imageModel.chatSendId!
            receiverId = imageModel.chatReceivedId!
            let send = imageModel.chatReceivedId
            let myId = imageModel.chatSendId
            userId = "\(send!)+\(myId!)"
            date = imageModel.date!
            localThumbnailImagePath  = imageModel.localThumbnailImagePath!
            imageModel.messageSendType = 0
            self.sendModel = imageModel
            
            DispatchQueue.main.async {
                IMMessageManager.sharedMessageManager.addOffLineMessage(message: imageModel, isOwn: true,roomName: self.roomModel?.roomJidString?.components(separatedBy: "@conference.coop")[0])
                
            }
            
        }else{
            imageModel = IMChat(imageUrl: "", receivedId: self.id.components(separatedBy: "+").first(), imageHeight: originalImage.size.height, imageWidth: originalImage.size.width, photoName: storeKey,image: originalImage)
            imageModel.date = imageModel.getCurrentDate()
            chatSendId = imageModel.chatSendId!
            receiverId = imageModel.chatReceivedId!
            let send = imageModel.chatReceivedId
            let myId = imageModel.chatSendId
            userId = "\(send!)+\(myId!)"
            localThumbnailImagePath  = imageModel.localThumbnailImagePath!
            date = imageModel.date!
            imageModel.messageSendType = 0
            self.sendModel = imageModel
            DispatchQueue.main.async {
                IMMessageManager.sharedMessageManager.addOffLineMessage(message: imageModel, isOwn: true)
            }
            
        }
        
        ImageFilesManager.storeImage(originalImage, key: storeKey, completionHandler: { [weak self] in
            guard let strongSelf = self else { return }
            
            let myChatSendId = imageModel.chatSendId?.components(separatedBy: "@A").first!
            let myReceiverId = strongSelf.isGroupChat != true ? imageModel.chatReceivedId?.components(separatedBy: "@").first! : ""
            
            IMObjectManager.sharedObjectManager.getFileByOid(senderId: myChatSendId!, receiverId: myReceiverId!, fileName: storeKey).continueWith { [weak self](task) in
                guard let strongSelf = self else { return }
                
                
                if task.error != nil {
                    print("转换失败")
                    DispatchQueue.main.async {
                        let predicate = NSPredicate(format: "userId = %@ AND date = %@  AND photoName = %@", userId, date,storeKey)
                        IMMessageManager.sharedMessageManager.updateSendImageType(type: 2, predicate: predicate)
                        log.debug("文件转换oid失败")
//                        IMProgressHUD.im_showWarningWithStatus(string: "上传图片失败，请检查网络")
                    }
                    return
                } else {
                    guard let _ = task.result?.oid else{
                        let predicate = NSPredicate(format: "userId = %@ AND date = %@  AND photoName = %@", userId, date,storeKey)
                        IMMessageManager.sharedMessageManager.updateSendImageType(type: 2, predicate: predicate)
                        log.debug("文件转换oid返回为空")
//                        IMProgressHUD.im_showWarningWithStatus(string: "服务器oid返回错误")
                        return
                    }
                    strongSelf.imageQueue.async(flags: .barrier) {
                        
                        //文件名字转换成Oid之后 上传FTP服务器
                        strongSelf.imageQueue.suspend()
                        let ftpStatusTure = IMUpLoadFileManager.sharedFileManager.checkFtpStatus()
                        let isDonwFile = IMUpLoadFileManager.sharedFileManager.uploadFile(fileName: task.result!.oid!, filePath: localThumbnailImagePath)
                        strongSelf.imageQueue.resume()
                        
                        guard ftpStatusTure == true && isDonwFile == true else{
                            
                            let str = ftpStatusTure ? "" : "ftp连接失败 ===>"
                            let str2 = isDonwFile ? "" : "下载图片失败 (上传图片)"
                            log.debug("\(str)\(str2)")
                            print("\(ftpStatusTure) \(isDonwFile)")
                            DispatchQueue.main.async {
                                let predicate = NSPredicate(format: "userId = %@ AND date = %@  AND photoName = %@", userId, date,storeKey)
                                
                                IMMessageManager.sharedMessageManager.updateSendImageType(type: 2, predicate: predicate)
                                let fileManager = FileManager.default
                                if fileManager.fileExists(atPath: localThumbnailImagePath) {
                                    try! fileManager.removeItem(atPath: localThumbnailImagePath)
                                }
//                                IMProgressHUD.im_showWarningWithStatus(string: "上传图片失败")
                            }
                            return
                        }
                        
                        
                        log.info("发送图片成功  \(date), 是否为群聊: \(strongSelf.isGroupChat ? "群聊": "单聊"), 接收人 : \(receiverId)，oid = \(task.result?.oid! ?? "")")
                        
                        if IMXMPPManager.sharedXmppManager.xmppStream!.myPresence != nil && IMXMPPManager.sharedXmppManager.xmppStream!.myPresence.type() != "unavailable" {
                            // 判斷是否為群聊
                            if strongSelf.isGroupChat == true {
                                IMXMPPManager.sharedXmppManager.sendRoomFile(chatReceivedId: receiverId, fileName: storeKey, oid: task.result!.oid!,filepath: storeKey)
                            }else{
                                IMXMPPManager.sharedXmppManager.sendFileMessage(chatReceivedId: receiverId, chatSendId: chatSendId, fileName: storeKey, oid: task.result!.oid!,filepath: storeKey)
                            }
                        }
                        DispatchQueue.main.async {
                            let predicate = NSPredicate(format: "userId = %@ AND date = %@ AND photoName = %@", userId, date,storeKey)
                            IMMessageManager.sharedMessageManager.updateSendImageType(type: 1, predicate: predicate)
                        }
                        
                        let fileManager = FileManager.default
                        
                        //删除存放在沙盒中的缓存文件
                        //我接收的
                        if fileManager.fileExists(atPath: localThumbnailImagePath) {
                            try! fileManager.removeItem(atPath: localThumbnailImagePath)
                        }
                        
                        DispatchQueue.main.async {
                            strongSelf.IMoidModel = task.result
                            do {
                                let realm = try Realm()
                                try realm.write {
                                    imageModel.imageOid = task.result?.oid!
                                }
                            }catch{
                                log.error("发送图片oid转换 update失败")
                            }
                        }
                        
                    }
                }
            }
        })
    }
    
    func reLoadingImage(_ imageOid: String, imagePath: String, row: Int){//重新下载图片
        let chatModel = self.itemDataSource[row]
        let realm = try! Realm()
        let image = NSColor.white.getImageBy(rect: CGRect(x: 0, y: 0, width: self.view.frame.size.width/2, height: self.view.frame.size.height/2))
        do{
            try realm.write {
                
                chatModel.imageData = image?.png! as! NSData
//                NSImagePNGRepresentation(image!)! as NSData
                chatModel.imageWidth = String.init(format: "%.2f",image!.size.width)
                chatModel.imageHeight = String.init(format: "%.2f",image!.size.height)
                chatModel.messageDownType = Int(MessageDownType.Loading.rawValue)
            }
        }catch{
            log.error("重新下载图片转圈状态")
        }
        self.imageQueue.async(flags: .barrier) {
            self.imageQueue.suspend()
            let ftpStatusIsTrue = IMUpLoadFileManager.sharedFileManager.checkFtpStatus()
            //检查文件是否下载完成
            
            let isDonwFile = IMUpLoadFileManager.sharedFileManager.downLoadFileForName(fileName: imageOid,localFilePath:imagePath)
            //线程释放
            self.imageQueue.resume()
            
            DispatchQueue.main.async {
                
                if isDonwFile == true && ftpStatusIsTrue == true {
                    
                    log.info("重新下载图片成功  \(chatModel.date!), 是否为群聊: \(self.isGroupChat ? "群聊": "单聊"), 接收人 : \(chatModel.chatSendId!)")
                    
                    let image = NSImage(contentsOfFile: imagePath)!
                    
                    do{
                        let realm = try Realm()
                        try realm.write {
                            chatModel.imageData = image.png! as NSData
                                
                                
//                                NSImagePNGRepresentation(image)! as NSData
                            chatModel.imageWidth = String.init(format: "%.2f",image.size.width)
                            chatModel.imageHeight = String.init(format: "%.2f",image.size.height)
                            chatModel.messageDownType = Int(MessageDownType.Success.rawValue)
                        }
                    }catch{
                        log.error("ftp下载。修改数据库图片")
                    }
                }else{
                    let str = ftpStatusIsTrue ? "" : "ftp连接失败 ====>"
                    let str2 = isDonwFile ? "" : "下载图片失败 (重新下载图片)"
                    log.debug("\(str)\(str2)")
                    
                    do{
                        let realm = try Realm()
                        try realm.write {
                            chatModel.messageDownType = Int(MessageDownType.Failed.rawValue)
                            let image = NSImage(named: "loadImageError")!
                            chatModel.imageWidth = String.init(format: "%.2f",image.size.width)
                            chatModel.imageHeight = String.init(format: "%.2f",image.size.height)
                            chatModel.imageData = image.png! as NSData//NAImage没有NSImagePNGRepresentation方法
//                                NSImagePNGRepresentation(image)! as NSData
                        }
                    }catch{
                        log.error("ftp下载。修改数据库图片")
                    }
                    
                }
                
                
                
                
                if let patch = chatModel.photoName {
                    let fileManager = FileManager.default
                    if fileManager.fileExists(atPath: patch) {
                        try! fileManager.removeItem(atPath: patch)
                    }
                }
            }
        }
    }
    
    
    func reLoadingFile(_ fileOid: String, fileName: String, row: Int){//重新下载文件
        let chatModel = self.itemDataSource[row]
        do{
            let realm = try Realm()
            try realm.write {
                chatModel.messageDownType = Int(MessageDownType.Loading.rawValue)
            }
        }catch{
            log.error("重新下载文件转圈状态")
        }
        
        self.imageQueue.async(flags: .barrier) {
            self.imageQueue.suspend()
            let ftpStatusIsTrue = IMUpLoadFileManager.sharedFileManager.checkFtpStatus()
            //检查文件是否下载完成
            let isDonwFile = IMUpLoadFileManager.sharedFileManager.downLoadFileForName(fileName: fileOid,localFilePath: ImageFilesManager.getImagePathForPhotoName(fileName)!)
            //线程释放
            self.imageQueue.resume()
            
            DispatchQueue.main.async {
                do{
                    if isDonwFile == true && ftpStatusIsTrue == true {
                        let realm = try! Realm()
                        try realm.write {
                            chatModel.messageDownType = Int(MessageDownType.Success.rawValue)
                        }
                    }else{
                        let realm = try Realm()
                        try realm.write {
                            chatModel.messageDownType = Int(MessageDownType.Failed.rawValue)
                        }
                    }
                }catch{
                    log.error("重新下载完成修改状态")
                }
            }
        }
    }
}
/*
// MARK: - @protocol NSImagePickerControllerDelegate
// 拍照完成，进行上传图片，并且发送的请求
extension RightChatDetailVC: UINavigationControllerDelegate, NSImagePickerControllerDelegate {
    func imagePickerController(_ picker: NSImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let mediaType = info[NSImagePickerControllerMediaType] as? NSString else { return }
        if mediaType.isEqual(to: kUTTypeImage as String) {
            guard let image: NSImage = info[NSImagePickerControllerOriginalImage] as? NSImage else { return }
            if picker.sourceType == .camera {
                self.resizeAndSendImage(image)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: NSImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
*/

//// MARk: -@protocol IMChatCellDelegate
//extension RightChatDetailVC: IMChatCellDelegate {
//    /**
//     *  点击了cell 本身
//     */
//    func cellDidTap(cell: IMChatBaseCell) {
//        
//    }
//    
//    /**
//     *  点击了 cell 中文字的URL
//     */
//    func cellDidTapedLink(cell: IMChatBaseCell, linkString: String) {
//        
//        var urlStr: String?
//        if linkString.contains("https") || linkString.contains("http") {
//            urlStr = linkString
//        } else {
//            urlStr = "http://\(linkString)"
//        }
//        UIApplication.shared.openURL(URL(string: urlStr!)!)
//    }
//    
//    /**
//     *  点击了 中文字的电话
//     */
//    func cellDidTapedPhone(cell: IMChatBaseCell, phoneString: String) {
//        self.taskToOpenTelephone(confirmClosure: { (alertAction) in
//            UIApplication.shared.openURL(URL(string: "tel://\(phoneString)")!)
//        }, phoneNumber: phoneString)
//    }
//    
//    /**
//     点击了 cell 的图片
//     */
//    func cellDidTapedImageView(_ cell: IMChat, _ imageView: NSImageView) {
//        
//        let item: KSPhotoItem
//        let image = NSImage(data: cell.imageData as Data)
//        item = KSPhotoItem(sourceView: imageView, image: image!)
//        
//        let browser = KSPhotoBrowser(photoItems: [item], selectedIndex: 0)
//        browser.delegate = self as KSPhotoBrowserDelegate
//        browser.backgroundStyle = .black
//        browser.dismissalStyle = .slide
//        browser.loadingStyle = .determinate
//        browser .show(from: self)
//        
//    }
//    
//    //长按图片cell
//    func cellDidLongTapGestureImageView(imChatModel: IMChat, cell: TSChatImageCell) {
//        self.imChatModelInCell = imChatModel
//        let menu = UIMenuController.shared
//        let delete = UIMenuItem(title: "删除", action: #selector(deleteCache))
//        menu.menuItems = [delete]
//        menu.setTargetRect(cell.chatImageView!.frame, in: cell)
//        cell.becomeFirstResponder()
//        menu.setMenuVisible(true, animated: true)
//    }
//    
//    //长按文件cell
//    func cellDidLongTapGestureFile(imChatModel: IMChat,cell: IMChatFileCell) {
//        self.imChatModelInCell = imChatModel
//        let menu = UIMenuController.shared
//        let delete = UIMenuItem(title: "删除", action: #selector(deleteCache))
//        menu.menuItems = [delete]
//        menu.setTargetRect(cell.fileContentView!.frame, in: cell)
//        cell.becomeFirstResponder()
//        menu.setMenuVisible(true, animated: true)
//    }
//    
//    
//    
//    //删除tableView数据源里的数据,删除本地缓存的聊天记录,删除沙盒中存放的文件
//    func deleteCache() {
//        var id: String!
//        if self.imChatModelInCell.fromMe {
//            id = ("\(self.imChatModelInCell.chatReceivedId!)+\(self.imChatModelInCell.chatSendId!)")
//        } else {
//            id = ("\(self.imChatModelInCell.chatSendId!)+\(self.imChatModelInCell.chatReceivedId!)")
//        }
//        
//        IMMessageManager.sharedMessageManager.deleteMsg(id: id, chat: self.imChatModelInCell)
//    }
//    
//    override var canBecomeFirstResponder: Bool {
//        return true
//    }
//    
//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        if self.chatActionBarView.inputTextView.isFirstResponder{ //聊天界面输入框不添加按钮
//            return false
//        }
//        if action == #selector(deleteCache) || action == #selector(self.copyText) || action == #selector(self.deleteText) {
//            return true
//        }
//        
//        return false
//    }
//    
//    /*
//     *点击了文件cell
//     */
//    func cellDidTapedFileContentView(_ model: IMChat) {
//        
//        let floatSize = Float(model.fileSize!)
//        if floatSize! > 10 {
//            IMProgressHUD.im_showWarningWithStatus(string: "移动端文件接收限制,请至PC端与对方重新联系")
//            return
//        }
//        
//        let fileBrowerfileVC = IMBrowerFileViewController(model.fileName!)
//        self.navigationController?.pushViewController(fileBrowerfileVC, animated: true)
//    }
//}
//
//
//extension RightChatDetailVC: KSPhotoBrowserDelegate {
//    func ks_photoBrowser(_ browser: KSPhotoBrowser, didSelect item: KSPhotoItem, at index: UInt) {
//        print("selected index\(index)")
//    }
//}


