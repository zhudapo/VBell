//
//  AudioCodecModel.h
//  VBell
//
//  Created by Jose Zhu on 16/4/25.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioCodecModel : NSObject
@property (nonatomic, assign) int enable;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int payload;
@end
