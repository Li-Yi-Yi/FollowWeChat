//
//  AESHelper.h
//  Journey
//
//  Created by Yen on 2015/10/16.
//
//

#import <Foundation/Foundation.h>

@interface AESHelper : NSObject

//加密  登录密码
+ (NSString*) AES128Encrypt:(NSString *)plainText  withKey:(NSString*)key;
//解密  登录密码
+ (NSString*) AES128Decrypt:(NSString *)encryptText  withKey:(NSString*)key;

//加密xmpp
+ (NSString*) AES128EncryptXmpp:(NSString *)plainText  withKey:(NSString*)key;
    
//解密xmpp
+ (NSString*) AES128DecryptXmpp:(NSString *)encryptText  withKey:(NSString*)key;

@end
