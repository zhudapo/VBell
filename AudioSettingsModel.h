//
//  AudioSettingsModel.h
//  VBell
//
//  Created by Jose Zhu on 16/4/13.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioSettingsModel : NSObject
@property (nonatomic, assign) int echoCanceller;
@property (nonatomic, assign) int cNG;
@property (nonatomic, assign) int vAD;
@property (nonatomic, assign) int aGC_sending;
@property (nonatomic, assign) int aGC_receving;
@property (nonatomic, assign) int aGC_target;
@end
