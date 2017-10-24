//
//  IMRxManager.swift
//  IM
//
//  Created by 林海生 on 2017/7/28.
//  Copyright © 2017年 want. All rights reserved.
//

 
import RxSwift
import Kingfisher
import AppKit

class IMRxManager: NSObject {
    static let sharedRxManager: IMRxManager  = { IMRxManager() }()
    
    //根据内外网判断头像
    func observableGender(id userId: String, subject: PublishSubject<NSImage>){
        if IMTokenManager.sharedTokenManager.getInterfaces() {
            if UserDefaults.standard.bool(forKey: "\(IMUserAvatar)\(userId)") {
                if let image = self.headerImagePath(imageName: userId){
                    subject.onNext(image)
                }else{
                    subject.onNext(NSImage(named: "wz")!)
                }
            } else {
                let image = UserDefaults.standard.string(forKey: "\(IMUserGender)\(userId)") == "2" ? NSImage(named: "wn") : NSImage(named: "wz")
                subject.onNext(image!)
                
                let url = "\(IMSessionManager.sharedSessionManager.userAvatarURL!)\(userId)"
                let iamgeView = NSImageView()
                
                
                iamgeView.kf.setImage(with: URL(string: url), placeholder: image, options: [.transition(ImageTransition.none)], progressBlock: nil, completionHandler:{ [weak self](image, error, cacheType, url) in
                    guard let strongSelf = self else { return }
                    if image != nil {
                        subject.onNext(strongSelf.addLocalHeaderImageToFile(headerImage: image!, imageName: userId)!)
                    }else{
                        if  let isWZ = UserDefaults.standard.string(forKey: "\(IMUserGender)\(userId)") {
                            subject.onNext((isWZ == "2" ? NSImage(named: "wn") : NSImage(named: "wz"))!)
                        }else{
                            IMObjectManager.sharedObjectManager.taskToFetchFriendGender(id: userId).continueWith(continuation: { [weak subject](task) in
                                guard let strongSubject = subject else{return}
                                if task.error != nil {
                                    strongSubject.onNext(NSImage(named: "wz")!)
                                }else{
                                    if task.result == "2"{
                                        strongSubject.onNext(NSImage(named: "wn")!)
                                        UserDefaults.standard.set("2", forKey: "\(IMUserGender)\(userId)")
                                    }else if task.result == "1"{
                                        strongSubject.onNext(NSImage(named: "wz")!)
                                        UserDefaults.standard.set("1", forKey: "\(IMUserGender)\(userId)")
                                    }else{
                                        strongSubject.onNext(NSImage(named: "wz")!)
                                        UserDefaults.standard.set("1", forKey: "\(IMUserGender)\(userId)")
                                    }
                                }
                            })
                        }
                    }
                })
            }
        } else {
            if let gender = UserDefaults.standard.string(forKey: "\(IMUserGender)\(userId)") {
                subject.onNext((gender == "2" ? NSImage(named: "wn") : NSImage(named: "wz"))!)
            }else{
                IMObjectManager.sharedObjectManager.taskToFetchFriendGender(id: userId).continueWith(continuation: { [weak subject](task) in
                    guard let strongSubject = subject else{return}
                    if task.error != nil {
                        strongSubject.onNext(NSImage(named: "wz")!)
                    }else{
                        if task.result == "2"{
                            strongSubject.onNext(NSImage(named: "wn")!)
                            UserDefaults.standard.set("2", forKey: "\(IMUserGender)\(userId)")
                        }else if task.result == "1"{
                            strongSubject.onNext(NSImage(named: "wz")!)
                            UserDefaults.standard.set("1", forKey: "\(IMUserGender)\(userId)")
                        }else{
                            strongSubject.onNext(NSImage(named: "wz")!)
                            UserDefaults.standard.set("1", forKey: "\(IMUserGender)\(userId)")
                        }
                    }
                })
            }
        }
    }
    
    // 获取头像路径
    func headerImagePath(imageName: String) -> NSImage? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent("\(imageName).png").path
        if FileManager.default.fileExists(atPath: filePath) {
            return NSImage(contentsOfFile: filePath)
        } else {
            return nil
        }
    }
    
    // 存入本地头像
    func addLocalHeaderImageToFile(headerImage: NSImage, imageName: String) -> NSImage? {
        do {
            var headerImage = headerImage
            if headerImage.size.width > headerImage.size.height{
//                headerImage = NSImage(cgImage: headerImage.cgImage!, scale: 1.0, orientation: NSImageOrientation.upMirrored)
//                cgImage(forProposedRect proposedDestRect: UnsafeMutablePointer<NSRect>?, context referenceContext: NSGraphicsContext?, hints: [String : Any]?) -> CGImage?
                headerImage = NSImage()
                
            }
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("\(imageName).png")
//            let image = headerImage.im_imageToResizeWithSize(size: CGSize(width: 200, height: 200), compressionQuality: 0.5)
//            NSImagePNGRepresentation
            let image = headerImage.im_imageToResizeWithSize(size: CGSize(width: 200, height: 200))
            
            
            if let pngImageData = image?.png {
                try pngImageData.write(to: fileURL, options: .atomic)
                UserDefaults.standard.set(true, forKey: "\(IMUserAvatar)\(imageName)")
            }
            
            return image
        } catch {
            return nil}
    }
    
}
