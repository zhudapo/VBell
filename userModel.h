//
//  userModel.h
//  VBell
//
//  Created by Jose Zhu on 16/4/14.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface userModel : NSObject
/**
 呼叫对象名
 */
@property (nonatomic , strong) NSString *userName;
/**
 呼叫电话
 */
@property (nonatomic , strong) NSString *number;
/**
 对象所属的组别
 */
@property (nonatomic , strong) NSString *account;
/**
 对象的地址
 */
@property (nonatomic , strong) NSString *rtspAddress;
/**
 Unlock
 */
@property (nonatomic , assign) int unLock;

/**
 DTMF
 */
@property (nonatomic , strong) NSString *DTMF;

/**
 Video Preview
 */
@property (nonatomic , assign) int videoPreview;

/**
 RTSP incoming
 */
@property (nonatomic , assign) int rtspInComing;

/**
 RTSP incoming
 */
@property (nonatomic , assign) int rtspEnable;

/**
 RTSP incoming
 */
@property (nonatomic , assign) int audioEnable;

/**
 RTSP incoming
 */
@property (nonatomic , assign) int videoEnable;
/**
 在线状态
 */
@property (nonatomic , assign) BOOL *UISwitchStatus;


@end
