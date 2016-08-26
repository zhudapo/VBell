//
//  CallHistoryModel.h
//  VBell
//
//  Created by Jose Zhu on 16/4/14.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CallHistoryModel : NSObject

/**
 呼叫对象名
 */
@property (nonatomic , strong) NSString *userName;
/**
 呼叫时间
 */
@property (nonatomic , strong) NSString *time;
/**
 呼叫号码
 */
@property (nonatomic , strong) NSString *phoneNumber;
/**
 呼叫类型
 */
@property (nonatomic, assign) int callDictionary;
/**
 呼叫方式
 */
@property (nonatomic, assign) int callType;

@property(nonatomic)BOOL mIsSelected;
@property(nonatomic)BOOL mIsReadyDel;

//@property (nonatomic, strong) NSString *hasVideo;
//
//@property (nonatomic, strong) NSString *endTime;
//
//@property (nonatomic, strong) NSString *historyType;
//
//@property (nonatomic, strong) NSString *contact;
//@property (nonatomic, strong) NSString *localContact;
//@property (nonatomic, strong) NSString *recordid;
//@property (nonatomic, strong) NSString *callUUid;
//@property (nonatomic, strong) NSString *startTime;
//@property (nonatomic, strong) NSString *createTime;

@end
