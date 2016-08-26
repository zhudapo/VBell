//
//  VideoCodecModel.h
//  VBell
//
//  Created by Jose Zhu on 16/4/25.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoCodecModel : NSObject
@property (nonatomic, assign) int enable;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *solution;
@property (nonatomic, strong) NSString *bitrate;
@property (nonatomic, assign) int payload;
@end
