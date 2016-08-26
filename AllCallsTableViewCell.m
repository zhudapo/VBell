//
//  AllCallsTableViewCell.m
//  VBell
//
//  Created by Jose Zhu on 16/4/12.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "AllCallsTableViewCell.h"
#import "CallHistoryModel.h"

@interface AllCallsTableViewCell()

@property (nonatomic , strong) UIButton *callDirection;
@property (nonatomic , strong) UIButton *callType;
@property (nonatomic , strong) UILabel *callName;
@property (nonatomic , strong) UILabel *callNumber;
@property (nonatomic , strong) UILabel *callTime;
@property(nonatomic,strong)UIImageView *mSelectView;

@end


@implementation AllCallsTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _callDirection = [[UIButton alloc] init];
        //[_callDirection setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [self.contentView addSubview:_callDirection];
        
        _callType = [[UIButton alloc] init];
        //[_callType setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [self.contentView addSubview:_callType];
        
        _callName = [[UILabel alloc]init];
        //_callName.textColor = [UIColor orangeColor];
        //_callName.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:_callName];
        
        _callNumber = [[UILabel alloc]init];
//        _callNumber.backgroundColor = [UIColor blueColor];
        
        [self.contentView addSubview:_callNumber];
        
        _callTime = [[UILabel alloc]init];
//        _callTime.backgroundColor = [UIColor orangeColor];
        
        [self.contentView addSubview:_callTime];
        
        _mSelectView = [[UIImageView alloc]initWithFrame:CGRectMake(self.bounds.size.width - 50, 10, 34, 34)];
        _mSelectView.backgroundColor = [UIColor clearColor];
        //[_mSelectView setImage:[UIImage imageNamed:@"icon_check_file_out.png"]];
        [self.contentView addSubview:_mSelectView];
    }
    return self;
}

- (void)setContent
{

    _callName.text = @"01";
    _callNumber.text = @"192.168.10.48";
    _callTime.text = @"Just now";//[self setupTime:@"Just now"];
    _callNumber.font = [UIFont systemFontOfSize:15];
    _callTime.font = [UIFont systemFontOfSize:15];
    [_callDirection setImage:[UIImage imageNamed:@"Incoming-1.png"] forState:UIControlStateNormal];
    [_callType setImage:[UIImage imageNamed:@"Video Settings.png"] forState:UIControlStateNormal];
    
//    [_mSelectView removeFromSuperview];
//    if (model.mIsReadyDel) {
//        [self.contentView addSubview:_mSelectView];
//        if (model.mIsSelected) {
//            [_mSelectView setImage:[UIImage imageNamed:@"icon_check_file.png"]];
//        } else {
//            [_mSelectView setImage:[UIImage imageNamed:@"icon_check_file_out.png"]];
//        }
//    }
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    _callDirection.frame = CGRectMake(20, 10, 20, 20);
    _callName.frame = CGRectMake(50, 11, 160, 20);
    
    _callType.frame = CGRectMake(20, 40, 20, 20);
    _callNumber.frame = CGRectMake(50, 40, 120, 20);
    _callTime.frame = CGRectMake(170, 40, 150, 20);
}


- (void)setContent:(CallHistoryModel *)model
{
    _callName.text = model.userName;
    _callNumber.text = model.phoneNumber;
    _callTime.text = [self setupTime:model.time];
    _callNumber.font = [UIFont systemFontOfSize:15];
    _callTime.font = [UIFont systemFontOfSize:15];
    _callName.textColor = [UIColor blackColor];
    _callNumber.textColor = [UIColor blackColor];
    _callTime.textColor = [UIColor blackColor];
    if (model.callType == 0) {
        [_callType setImage:[UIImage imageNamed:@"Audio Settings.png"] forState:UIControlStateNormal];
    }else{
        [_callType setImage:[UIImage imageNamed:@"Video Settings.png"] forState:UIControlStateNormal];
    }
    if (model.callDictionary == 0) {//0 未接//未接来电
        [_callDirection setImage:[UIImage imageNamed:@"Incoming-2.png"] forState:UIControlStateNormal];
        _callName.textColor = [UIColor orangeColor];
        _callNumber.textColor = [UIColor orangeColor];
        _callTime.textColor = [UIColor orangeColor];
    }else if (model.callDictionary == 1){//呼出
        [_callDirection setImage:[UIImage imageNamed:@"Outgoing.png"] forState:UIControlStateNormal];
    }else{//接通
        [_callDirection setImage:[UIImage imageNamed:@"Incoming-1.png"] forState:UIControlStateNormal];
    }
    
    
    
    [_mSelectView removeFromSuperview];
    if (model.mIsReadyDel) {
        [self.contentView addSubview:_mSelectView];
        if (model.mIsSelected) {
            [_mSelectView setImage:[UIImage imageNamed:@"icon_check_file.png"]];
        } else {
            [_mSelectView setImage:[UIImage imageNamed:@"icon_check_file_out.png"]];
        }
    }
}

//判断显示时间的格式
- (NSString *)setupTime:(NSString *)time
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    // 设置locale
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    // 记录时间
    NSDate *createDate = [fmt dateFromString:time];
    // 当前时间
    NSDate *now = [NSDate date];

    // 日历对象（方便比较两个日期之间的差距）
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // NSCalendarUnit枚举代表想获得哪些差值
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    // 计算两个日期之间的差值
    NSDateComponents *cmps = [calendar components:unit fromDate:createDate toDate:now options:0];
    
    if ([createDate isYesterday]) { // 昨天
        fmt.dateFormat = @"HH:mm:ss";
        NSString *str = [fmt stringFromDate:createDate];
        NSString *yesterday = [@"Yesterday " stringByAppendingString:str];
        return yesterday;
    } else if ([createDate isToday]) { // 今天
        if (cmps.hour >= 1) {
            fmt.dateFormat = @"HH:mm:ss";
            NSString *str = [fmt stringFromDate:createDate];
            NSString *today = [@"Today " stringByAppendingString:str];
            return today;
        } else if (cmps.minute >= 1) {
            return [NSString stringWithFormat:@"%d Minutes age", (int)cmps.minute];
        } else {
            return @"Just Now";
        }
    } else {
        fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        return [fmt stringFromDate:createDate];
    }
}


@end
