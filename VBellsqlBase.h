//
//  VBellsqlBase.h
//  VBell
//
//  Created by Jose Zhu on 16/4/13.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioCodecModel.h"
#define DBPATH @"easiio.db"


@interface VBellsqlBase : NSObject

+ (VBellsqlBase *)shareMyDdataBase;
- (NSArray *)getAudioSettingInfo;
- (NSArray *)getVideoSettingInfo;
- (NSArray *)getAdvanceSettingInfo;
- (NSArray *)getVideoCodecInfo;
- (NSArray *)getAudioCodecInfo;
- (NSMutableArray *)getCallingHistoryDictionary:(int)dictionary;
- (NSMutableArray *)getCallingHistoryDictionary:(int)dictionary andCallNumber:(NSString *)number;
- (NSMutableArray *)getUserInfo;
- (NSMutableArray *)getUserInfoNameWithNumber:(NSString *)phoneNumber;
- (NSArray *)getModifyAccountTabInfo;
- (void)insertUserRegisterStateoTab:(NSString *)registerName registerState:(NSString *)registerState;
- (BOOL)insertUserInfoTabNumber:(NSString *)phoneNumber name:(NSString *)userName rtspAddress:(NSString *)rtspaddress unlock:(int)unlock dtmf:(NSString *)dtmf video_preview:(int)video_preview;
- (void)insertCallingHistoryTabNumber:(NSString *)phoneNumber name:(NSString *)userName Calltime:(NSString *)time callType:(int)callType callDictionary:(int)callDictionary;
- (BOOL)insertAccountUserInfoTabRegister:(NSString *)registerName userName:(NSString *)username password:(NSString *)password displayName:(NSString *)displayName serverURL:(NSString *)serverURL serverPort:(NSString *)serverPort poxyServerURL:(NSString *)poxyserverURL poxyServerPort:(NSString *)poxyServerPort;
- (BOOL)insertAudioCodecInfoTab:(AudioCodecModel *)model;
- (BOOL)updateAudioEchoCanceller:(int)echo_Canceller cng:(int)cng vad:(int)vad agc_sending:(int)agc_sending agc_receving:(int)agc_receving agc_target:(int)field;
- (BOOL)updateVideoPreview:(int)video_preView video_Resolution:(NSString *)video_Resolution caching:(NSString *)caching nack:(int)nack tmmbr:(int)tmmbr color_Enhancement:(int)color_enhancement image_Quality:(NSString *)image_quality;
- (BOOL)updateAdvanceLog_level:(NSString *)log_level;
- (BOOL)updateDeviceName:(NSString *)userName oldNumber:(NSString *)oldNumber rtspAddress:(NSString *)rtspAddress newNumber:(NSString *)newNumber unlock:(int)unlock dtmf:(NSString *)dtmf video_preview:(int)video_preview;
- (BOOL)updateVideoCodecEable:(int)enable andname:(NSString *)name andsolution:(NSString *)solution andbitrate:(NSString *)bitrate andpayload:(int)payload;
- (BOOL)updateCallHistoryInfoTab:(NSString *)userName oldNumber:(NSString *)oldNumber newNumber:(NSString *)newNumber;
- (BOOL)updateCallHistorycallDictionary:(int)callDictionary andCallType:(int)callType callTime:(NSString *)callTime;
- (BOOL)updateUserRegisterState:(NSString *)registerName registerState:(NSString *)registerState;
- (BOOL)deleteUserInfoUsingPhoneNumber:(NSString *)phoneNumber;
- (BOOL)deleteCallHistoryWithTime:(NSArray *)callTime;
- (BOOL)deleteAudioCodecInfoTab;
- (BOOL)deleteOneCallHistoryWithTime:(NSString *)callTime;
@end
