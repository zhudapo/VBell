//
//  sqlBase.m
//  VBell
//
//  Created by Jose Zhu on 16/4/13.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "VBellsqlBase.h"
#import "FMDB.h"
#import "AudioSettingsModel.h"
#import "VideoSettingsModel.h"
#import "AdvanceSettingModel.h"
#import "AboutModel.h"
#import "userModel.h"
#import "CallHistoryModel.h"
#import "VideoCodecModel.h"
#import "AudioCodecModel.h"
#import "AccountGroupsModel.h"
static VBellsqlBase *shareMyDdataBaseInstance = nil;
@interface VBellsqlBase()
@property(nonatomic,strong) FMDatabase *db;
@end

@implementation VBellsqlBase

- (id)init
{
    if (self = [super init]) {
        [self OpenMydabase];
        [self createAudioSettingInfoTable];
        [self createVideoSettingInfoTable];
        [self createAdvanceSettingInfoTable];
        [self createUserInfoTable];
        [self createCallHistoryInfoTable];
        [self createVideoCodecInfoTable];
        [self createAudioCodecInfoTable];
        [self createModifyAccountInfoTable];
#warning 执行一次
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self insertAudioSettingInfoTab];
            [self insertVideoSettingInfoTab];
            [self insertAdvanceSettingInfoTab];
            [self insertVideoCodecInfoTab];
            [self insertAudioCodecInfoTab];
        });
    }
    return self;
}

+ (VBellsqlBase *)shareMyDdataBase
{
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        shareMyDdataBaseInstance = [[self alloc] init];
    });
    return shareMyDdataBaseInstance;
}

- (void)OpenMydabase
{
    //数据的路径，放在沙盒的cache下面
    NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [cacheDir stringByAppendingPathComponent:DBPATH];
    
    _db = [FMDatabase databaseWithPath:filePath];
    
    BOOL flag = [_db open];
    if (flag) {
        //NSLog(@"数据库打开成功");
    }else{
        NSLog(@"数据库打开失败");
    }
}

#pragma create
- (void)createAudioSettingInfoTable
{
    NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS AudioSettingInfoTab(ID INTEGER PRIMARY KEY AUTOINCREMENT,\
    echo_Canceller INTEGER,\
    cng INTEGER,\
    vad INTEGER,\
    agc_sending INTEGER,\
    agc_receving INTEGER,\
    agc_target INTEGER);";
    
    BOOL result = [_db executeUpdate:sqlCreateTable];
    if (result) {
        //NSLog(@"创表成功");
    }else{
        NSLog(@"创表失败");
    }
}
- (void)createVideoSettingInfoTable
{
    NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS VideoSettingInfoTab(ID INTEGER PRIMARY KEY AUTOINCREMENT,\
    video_Preview INTEGER,\
    video_Resolution TEXT,\
    caching TEXT,\
    nack INTEGER,\
    tmmbr INTEGER,\
    color_Enhancement INTEGER,\
    image_Quality TEXT);";
    
    BOOL result = [_db executeUpdate:sqlCreateTable];
    if (result) {
        //NSLog(@"创表成功");
    }else{
        NSLog(@"创表失败");
    }
}
- (void)createAdvanceSettingInfoTable
{
    NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS AdvanceSettingInfoTab(ID INTEGER PRIMARY KEY AUTOINCREMENT,\
    log_Level TEXT);";
    BOOL result = [_db executeUpdate:sqlCreateTable];
    if (result) {
        //NSLog(@"创表成功");
    }else{
        NSLog(@"创表失败");
    }
}
- (void)createCallHistoryInfoTable
{
    NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS CallHistoryInfoTab(ID INTEGER PRIMARY KEY AUTOINCREMENT,\
    userName INTEGER,\
    time TEXT,\
    phoneNumber TEXT,\
    callUUid INTEGER,\
    calldictionary int,\
    calltype int);";
    
    BOOL result = [_db executeUpdate:sqlCreateTable];
    if (result) {
        //NSLog(@"创表成功");
    }else{
        NSLog(@"创表失败");
    }
}
- (void)createUserInfoTable
{
    NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS UserInfoTab(phoneNumber TEXT PRIMARY KEY,\
    userName TEXT,\
    account TEXT,\
    unlock INT,\
    dtmf TEXT,\
    video_Preview INT,\
    rtspAddress TEXT);";

    BOOL result = [_db executeUpdate:sqlCreateTable];
    if (result) {
        //NSLog(@"创表成功");
    }else{
        NSLog(@"创表失败");
    }
}
- (void)createVideoCodecInfoTable
{
    NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS VideoCodecInfoTab(ID INTEGER PRIMARY KEY AUTOINCREMENT,\
    enable INTEGER,\
    name TEXT,\
    solution TEXT,\
    bitrate TEXT,\
    payload INT);";
    BOOL result = [_db executeUpdate:sqlCreateTable];
    if (result) {
        //NSLog(@"创表成功");
    }else{
        NSLog(@"创表失败");
    }
}
- (void)createAudioCodecInfoTable
{
    NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS AudioCodecInfoTab(ID INTEGER PRIMARY KEY AUTOINCREMENT,\
    enable INTEGER,\
    name TEXT,\
    payload INT);";
    BOOL result = [_db executeUpdate:sqlCreateTable];
    if (result) {
        //NSLog(@"创表成功");
    }else{
        NSLog(@"创表失败");
    }

}
- (void)createModifyAccountInfoTable
{
    NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS ModifyAccountInfoTab(userName TEXT PRIMARY KEY,\
    registerName TEXT,\
    passWord TEXT,\
    displayName TEXT,\
    serverURL TEXT,\
    serverPort TEXT,\
    proxyServerPort TEXT,\
    proxyServerURL TEXT);";
    BOOL result = [_db executeUpdate:sqlCreateTable];
    if (result) {
        //NSLog(@"创表成功");
    }else{
        NSLog(@"创表失败");
    }
}
- (void)createUserRegisterState
{
    NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS UserRegisterStateoTab(ID INTEGER PRIMARY KEY AUTOINCREMENT,\
    registerName TEXT,\
    registerState TEXT);";
    BOOL result = [_db executeUpdate:sqlCreateTable];
    if (result) {
        //NSLog(@"创表成功");
    }else{
        NSLog(@"创表失败");
    }
}

#pragma insert
- (void)insertUserRegisterStateoTab:(NSString *)registerName registerState:(NSString *)registerState
{
    NSString *insertUserRegisterStateoTabStr = [NSString stringWithFormat:@"INSERT INTO UserRegisterStateoTab (registerName, registerState) VALUES ('%@', '%@')",registerName,registerState];
    
    [self.db executeUpdate:insertUserRegisterStateoTabStr];
}

- (void)insertAudioSettingInfoTab
{
    if ([self getAudioSettingInfo].count>0) {
        return;
    }
    [self.db executeUpdate:@"INSERT INTO AudioSettingInfoTab (echo_Canceller, cng, vad, agc_sending, agc_receving, agc_target) VALUES (1, 1, 1, 1, 1, 3);"];
}

- (void)insertVideoSettingInfoTab
{
    if ([self getVideoSettingInfo].count>0) {
        return;
    }
    [self.db executeUpdate:@"INSERT INTO VideoSettingInfoTab (video_Preview, video_Resolution, caching, nack, tmmbr, color_Enhancement, image_Quality) VALUES(1, ?, ?, 1, 1, 1, ?)", @"4CIF                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      ",@"300",@"Middle"];
}

- (void)insertAdvanceSettingInfoTab
{
    if ([self getAdvanceSettingInfo].count>0) {
        return;
    }
    [self.db executeUpdate:@"INSERT INTO AdvanceSettingInfoTab (log_Level) VALUES (?)",@"3"];
}

- (void)insertVideoCodecInfoTab
{
    if ([self getVideoCodecInfo].count>0) {
        return;
    }
    [self.db executeUpdate:@"INSERT INTO VideoCodecInfoTab (enable, name, solution, bitrate, payload) VALUES(1, ?, ?, ?, 104)", @"H264                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                ",@"4CIF",@"2048"];
}

- (void)insertAudioCodecInfoTab
{
    if ([self getAudioCodecInfo].count>0) {
        return;
    }
    [self.db executeUpdate:@"INSERT INTO AudioCodecInfoTab (enable, name, payload) VALUES (1, ?, 0)",@"PCMU"];
    [self.db executeUpdate:@"INSERT INTO AudioCodecInfoTab (enable, name, payload) VALUES (1, ?, 8)",@"PCMA"];
    [self.db executeUpdate:@"INSERT INTO AudioCodecInfoTab (enable, name, payload) VALUES (1, ?, 18)",@"G729"];
    [self.db executeUpdate:@"INSERT INTO AudioCodecInfoTab (enable, name, payload) VALUES (1, ?, 9)",@"G722"];
}

- (BOOL)insertAudioCodecInfoTab:(AudioCodecModel *)model
{
    NSString *insertAudioCodecInfoTabStr = [NSString stringWithFormat:@"INSERT INTO AudioCodecInfoTab (enable, name, payload) VALUES (%d, '%@', '%d')",model.enable,model.name,model.payload];
    
    return [self.db executeUpdate:insertAudioCodecInfoTabStr];
}


- (BOOL)insertUserInfoTabNumber:(NSString *)phoneNumber name:(NSString *)userName rtspAddress:(NSString *)rtspaddress unlock:(int)unlock dtmf:(NSString *)dtmf video_preview:(int)video_preview
{
   return  [self.db executeUpdate:@"INSERT INTO UserInfoTab (phoneNumber, userName, account,unlock,dtmf,video_preview, rtspAddress) VALUES (?, ?, 1,?,?,?, ?)",phoneNumber,userName,unlock,dtmf,video_preview,rtspaddress];
}

- (void)insertCallingHistoryTabNumber:(NSString *)phoneNumber name:(NSString *)userName Calltime:(NSString *)time callType:(int)callType callDictionary:(int)callDictionary
{
    NSString *insertCallingHistoryTabNumberStr = [NSString stringWithFormat:@"INSERT INTO CallHistoryInfoTab (phoneNumber, userName, time, calldictionary, calltype) VALUES ('%@', '%@', '%@', %d, %d)",phoneNumber,userName,time,callDictionary,callType];
    
    [self.db executeUpdate:insertCallingHistoryTabNumberStr];
}

- (BOOL)insertAccountUserInfoTabRegister:(NSString *)registerName userName:(NSString *)username password:(NSString *)password displayName:(NSString *)displayName serverURL:(NSString *)serverURL serverPort:(NSString *)serverPort poxyServerURL:(NSString *)poxyserverURL poxyServerPort:(NSString *)poxyServerPort
{
   return [self.db executeUpdate:@"INSERT INTO ModifyAccountInfoTab (registerName,userName,passWord,displayName,serverURL,serverPort,proxyServerURL,proxyServerPort) VALUES (?,?,?,?,?,?,?,?)"];
}
#pragma get
- (NSArray *)getAudioSettingInfo
{
    // 1.执行查询语句
    FMResultSet *resultSet = [self.db executeQuery:@"SELECT * FROM AudioSettingInfoTab "];
    NSMutableArray *reary = [NSMutableArray array];
    // 2.遍历结果
    while ([resultSet next]) {
        AudioSettingsModel *model = [[AudioSettingsModel alloc]init];
        model.echoCanceller = [resultSet intForColumn:@"echo_Canceller"];
        model.cNG = [resultSet intForColumn:@"cng"];
        model.vAD  = [resultSet intForColumn:@"vad"];
        model.aGC_sending  = [resultSet intForColumn:@"agc_sending"];
        model.aGC_receving  = [resultSet intForColumn:@"agc_receving"];
        model.aGC_target  = [resultSet intForColumn:@"agc_target"];
        [reary addObject:model];
    }
    return reary;
}

- (NSArray *)getVideoSettingInfo
{
    // 1.执行查询语句
    FMResultSet *resultSet = [self.db executeQuery:@"SELECT * FROM VideoSettingInfoTab"];
    NSMutableArray *reary = [NSMutableArray array];
    // 2.遍历结果
    while ([resultSet next]) {
        VideoSettingsModel *model = [[VideoSettingsModel alloc]init];
        model.video_Preview = [resultSet intForColumn:@"video_Preview"];
        model.video_Resolution = [resultSet stringForColumn:@"video_Resolution"];
        model.caching = [resultSet stringForColumn:@"caching"];
        model.nACK = [resultSet intForColumn:@"nack"];
        model.tMMBR = [resultSet intForColumn:@"tmmbr"];
        model.color_Enhancement  = [resultSet intForColumn:@"color_Enhancement"];
        model.image_Quality  = [resultSet stringForColumn:@"image_Quality"];
        [reary addObject:model];
    }
    return reary;

}

- (NSArray *)getAdvanceSettingInfo
{
    // 1.执行查询语句
    FMResultSet *resultSet = [self.db executeQuery:@"SELECT * FROM AdvanceSettingInfoTab"];
    NSMutableArray *reary = [NSMutableArray array];
    // 2.遍历结果
    while ([resultSet next]) {
        AdvanceSettingModel *model = [[AdvanceSettingModel alloc]init];
        model.log_Level = [resultSet stringForColumn:@"log_Level"];
        [reary addObject:model];
    }
    return reary;
    
}

- (NSArray *)getVideoCodecInfo
{
    // 1.执行查询语句
    FMResultSet *resultSet = [self.db executeQuery:@"SELECT * FROM VideoCodecInfoTab"];
    NSMutableArray *reary = [NSMutableArray array];
    // 2.遍历结果
    while ([resultSet next]) {
        VideoCodecModel *model = [[VideoCodecModel alloc]init];
        model.enable = [resultSet intForColumn:@"enable"];
        model.name = [resultSet stringForColumn:@"name"];
        model.solution  = [resultSet stringForColumn:@"solution"];
        model.bitrate  = [resultSet stringForColumn:@"bitrate"];
        model.payload  = [resultSet intForColumn:@"payload"];
        [reary addObject:model];
    }
    return reary;
    
}

- (NSMutableArray *)getAudioCodecInfo
{
    // 1.执行查询语句
    FMResultSet *resultSet = [self.db executeQuery:@"SELECT * FROM AudioCodecInfoTab"];
    NSMutableArray *reary = [NSMutableArray array];
    // 2.遍历结果
    while ([resultSet next]) {
        AudioCodecModel *model = [[AudioCodecModel alloc]init];
        model.enable = [resultSet intForColumn:@"enable"];
        model.name = [resultSet stringForColumn:@"name"];
        model.payload  = [resultSet intForColumn:@"payload"];
        [reary addObject:model];
    }
    return reary;
}

- (NSMutableArray *)getUserInfo
{
    // 1.执行查询语句
    FMResultSet *resultSet = [self.db executeQuery:@"SELECT * FROM UserInfoTab "];
    NSMutableArray *reary = [NSMutableArray array];
    // 2.遍历结果
    while ([resultSet next]) {
        userModel *model = [[userModel alloc]init];
        model.number = [resultSet stringForColumn:@"phoneNumber"];
        model.userName = [resultSet stringForColumn:@"userName"];
        model.account = [resultSet stringForColumn:@"account"];
        model.unLock = [resultSet intForColumn:@"unlock"];
        model.DTMF = [resultSet stringForColumn:@"dtmf"];
        model.videoPreview = [resultSet intForColumn:@"video_preview"];
        model.rtspAddress  = [resultSet stringForColumn:@"rtspAddress"];
        [reary addObject:model];
    }
    return reary;
}

- (NSMutableArray *)getUserInfoNameWithNumber:(NSString *)phoneNumber
{
    // 1.执行查询语句
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM UserInfoTab where phoneNumber = '%@'",phoneNumber];
    NSLog(@"this is getUserInfoNameWithNumber:(NSString *)phoneNumber:%@",sql);
    FMResultSet *resultSet = [self.db executeQuery:sql];
    NSMutableArray *reary = [NSMutableArray array];
    // 2.遍历结果
    while ([resultSet next]) {
        userModel *model = [[userModel alloc]init];
        model.number = [resultSet stringForColumn:@"phoneNumber"];
        model.userName = [resultSet stringForColumn:@"userName"];
        model.account = [resultSet stringForColumn:@"account"];
        model.unLock = [resultSet intForColumn:@"unlock"];
        model.DTMF = [resultSet stringForColumn:@"dtmf"];
        model.videoPreview = [resultSet intForColumn:@"video_preview"];
        model.rtspAddress  = [resultSet stringForColumn:@"rtspAddress"];
        [reary addObject:model];
    }
    return reary;
}

- (NSMutableArray *)getCallingHistoryDictionary:(int)dictionary
{
    // 1.执行查询语句
    NSString *getSql = nil;
    if (dictionary == 0) {
        getSql = [NSString stringWithFormat:@"SELECT * FROM CallHistoryInfoTab order by id desc"];
    }else{
        getSql = [NSString stringWithFormat:@"SELECT * FROM CallHistoryInfoTab where calldictionary = '%d' order by id desc",dictionary];
    }
    FMResultSet *resultSet = [_db executeQuery:getSql];
    NSMutableArray *reary = [NSMutableArray array];
    // 2.遍历结果
    while ([resultSet next]) {
        CallHistoryModel *model = [[CallHistoryModel alloc]init];
        model.phoneNumber = [resultSet stringForColumn:@"phoneNumber"];
        model.userName = [resultSet stringForColumn:@"userName"];
        model.time = [resultSet stringForColumn:@"time"];
        model.callDictionary  = [resultSet intForColumn:@"calldictionary"];
        model.callType  = [resultSet intForColumn:@"calltype"];
        [reary addObject:model];
    }
    return reary;
}

- (NSMutableArray *)getCallingHistoryDictionary:(int)dictionary andCallNumber:(NSString *)number
{
    // 1.执行查询语句
    NSString *getSql = nil;
    if (dictionary == 0) {
        getSql = [NSString stringWithFormat:@"SELECT * FROM CallHistoryInfoTab where phoneNumber = '%@' order by id desc",number];
    }else{
        getSql = [NSString stringWithFormat:@"SELECT * FROM CallHistoryInfoTab where calldictionary = '%d' and phoneNumber = '%@' order by id desc",dictionary,number];
    }
    FMResultSet *resultSet = [_db executeQuery:getSql];
    NSMutableArray *reary = [NSMutableArray array];
    // 2.遍历结果
    while ([resultSet next]) {
        CallHistoryModel *model = [[CallHistoryModel alloc]init];
        model.phoneNumber = [resultSet stringForColumn:@"phoneNumber"];
        model.userName = [resultSet stringForColumn:@"userName"];
        model.time = [resultSet stringForColumn:@"time"];
        model.callDictionary  = [resultSet intForColumn:@"calldictionary"];
        model.callType  = [resultSet intForColumn:@"calltype"];
        [reary addObject:model];
    }
    return reary;
}

- (NSArray *)getModifyAccountTabInfo
{
    // 1.执行查询语句
    FMResultSet *resultSet = [self.db executeQuery:@"SELECT * FROM ModifyAccountInfoTab "];
    NSMutableArray *reary = [NSMutableArray array];
    // 2.遍历结果
    while ([resultSet next]) {
        AccountGroupsModel *model = [[AccountGroupsModel alloc]init];
        model.userName = [resultSet stringForColumn:@"userName"];
        [reary addObject:model];
    }
    return reary;
}

#pragma update
- (BOOL)updateAudioEchoCanceller:(int)echo_Canceller cng:(int)cng vad:(int)vad agc_sending:(int)agc_sending agc_receving:(int)agc_receving agc_target:(int)field
{
    BOOL res;
    if ([_db open]) {
        NSString *updateSql = [NSString stringWithFormat:@"update AudioSettingInfoTab set echo_Canceller = '%d', cng='%d', vad='%d', agc_sending='%d', agc_receving='%d', agc_target ='%d'",echo_Canceller,cng,vad,agc_sending,agc_receving,field];
        res = [_db executeUpdate:updateSql];
        if (!res) {
            NSLog(@"error when insert db table");
        } else {
            //NSLog(@"success to insert db table");
        }
    }
    return res;
}

- (BOOL)updateVideoPreview:(int)video_preView video_Resolution:(NSString *)video_Resolution caching:(NSString *)caching nack:(int)nack tmmbr:(int)tmmbr color_Enhancement:(int)color_enhancement image_Quality:(NSString *)image_quality
{
    BOOL res;
    if ([_db open]) {
        NSString *updateSql = [NSString stringWithFormat:@"update VideoSettingInfoTab set video_Preview='%d', video_Resolution='%@',caching='%@', nack='%d',tmmbr='%d',color_Enhancement='%d',image_Quality='%@'",video_preView, video_Resolution, caching, nack, tmmbr, color_enhancement, image_quality];
        res = [_db executeUpdate:updateSql];
        
        if (!res) {
            NSLog(@"error when insert db table");
        } else {
            //NSLog(@"success to insert db table");
        }
    }
    return res;
}

- (BOOL)updateAdvanceLog_level:(NSString *)log_level
{
    BOOL res;
    if ([_db open]) {
        NSString *updateSql = [NSString stringWithFormat:@"update AdvanceSettingInfoTab set log_Level='%@'",log_level];
        res = [_db executeUpdate:updateSql];
        if (!res) {
            NSLog(@"error when insert db table");
        } else {
            //NSLog(@"success to insert db table");
        }
    }
    return res;
}

- (BOOL)updateVideoCodecEable:(int)enable andname:(NSString *)name andsolution:(NSString *)solution andbitrate:(NSString *)bitrate andpayload:(int)payload
{
    BOOL res;
    if ([_db open]) {
        NSString *updateSql = [NSString stringWithFormat:@"update VideoCodecInfoTab set enable='%d',name='%@',solution='%@',bitrate='%@',payload='%d'",enable,name,solution,bitrate,payload];
        res = [_db executeUpdate:updateSql];
        if (!res) {
            NSLog(@"error when insert db table");
        } else {
//            NSLog(@"success to insert db table");
        }
    }
    return res;
}

- (BOOL)updateDeviceName:(NSString *)userName oldNumber:(NSString *)oldNumber rtspAddress:(NSString *)rtspAddress newNumber:(NSString *)newNumber unlock:(int)unlock dtmf:(NSString *)dtmf video_preview:(int)video_preview
{
    BOOL res;
    if ([_db open]) {
        NSString *updateSql = [NSString stringWithFormat:@"update UserInfoTab set userName='%@',phoneNumber='%@',rtspAddress='%@', unlock='%d',dtmf='%@',video_preview='%d' where phoneNumber = '%@'",userName,newNumber,rtspAddress,unlock,dtmf,video_preview,oldNumber];
        res = [_db executeUpdate:updateSql];
        if (!res) {
            NSLog(@"error when insert db table");
        } else {
            NSLog(@"success to insert db table");
        }
    }
    return res;
}

- (BOOL)updateCallHistoryInfoTab:(NSString *)userName oldNumber:(NSString *)oldNumber newNumber:(NSString *)newNumber
{
    BOOL res;
    if ([_db open]) {
        NSString *updateSql = [NSString stringWithFormat:@"update CallHistoryInfoTab set userName='%@',phoneNumber='%@' where phoneNumber = '%@'",userName,newNumber,oldNumber];
        res = [_db executeUpdate:updateSql];
        if (!res) {
            NSLog(@"error when insert db table");
        } else {
            NSLog(@"success to insert db table");
        }
    }
    return res;
}

- (BOOL)updateCallHistorycallDictionary:(int)callDictionary andCallType:(int)callType callTime:(NSString *)callTime
{
    BOOL res;
    if ([_db open]) {
        NSString *updateSql = [NSString stringWithFormat:@"update CallHistoryInfoTab set calldictionary='%d',calltype='%d' where time = '%@'",callDictionary,callType,callTime];
        res = [_db executeUpdate:updateSql];
        if (!res) {
            NSLog(@"error when insert db table");
        } else {
            NSLog(@"success to insert db table");
        }
    }
    return res;
}

- (BOOL)updateUserRegisterState:(NSString *)registerName registerState:(NSString *)registerState
{
    BOOL res;
    if ([_db open]) {
        NSString *updateSql = [NSString stringWithFormat:@"update UserRegisterStateoTab set registerState='%@' where registerName = '%@'",registerState,registerName];
        res = [_db executeUpdate:updateSql];
        if (!res) {
            NSLog(@"error when insert db table");
        } else {
            NSLog(@"success to insert db table");
        }
    }
    return res;
}


#pragma -mark delete
- (BOOL)deleteUserInfoUsingPhoneNumber:(NSString *)phoneNumber
{
    BOOL res;
    if ([_db open]) {
        NSString *updateSql = [NSString stringWithFormat:@"delete from UserInfoTab where phoneNumber='%@'",phoneNumber];
        res = [_db executeUpdate:updateSql];
        if (!res) {
            NSLog(@"error when insert db table");
        } else {
            NSLog(@"success to insert db table");
        }
    }
    return res;
}

- (BOOL)deleteCallHistoryWithTime:(NSArray *)callTime
{
    BOOL res;
    if ([_db open]) {
        NSString *updateSql = [NSString stringWithFormat:@"delete from CallHistoryInfoTab where time in %@",callTime];
        res = [_db executeUpdate:updateSql];
        if (!res) {
            NSLog(@"error when insert db table");
        } else {
            NSLog(@"success to insert db table");
        }
    }
    return res;
}

- (BOOL)deleteOneCallHistoryWithTime:(NSString *)callTime
{
    BOOL res;
    if ([_db open]) {
        NSString *updateSql = [NSString stringWithFormat:@"delete from CallHistoryInfoTab where time = '%@'",callTime];
        res = [_db executeUpdate:updateSql];
        if (!res) {
            NSLog(@"error when insert db table");
        } else {
            NSLog(@"success to insert db table");
        }
    }
    return res;
}

- (BOOL)deleteAudioCodecInfoTab
{
    BOOL res;
    if ([_db open]) {
        NSString *updateSql = [NSString stringWithFormat:@"delete from AudioCodecInfoTab"];
        res = [_db executeUpdate:updateSql];
        if (!res) {
            NSLog(@"error when insert db table");
        } else {
            NSLog(@"success to insert db table");
        }
    }
    return res;
}

@end
