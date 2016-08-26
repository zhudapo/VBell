//
//  VideoSettingsModel.h
//  VBell
//
//  Created by Jose Zhu on 16/4/13.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoSettingsModel : NSObject
@property (nonatomic, assign) int video_Preview;
@property (nonatomic , strong) NSString *video_Resolution;
@property (nonatomic , strong) NSString *caching;
@property (nonatomic, assign) int nACK;
@property (nonatomic, assign) int tMMBR;
@property (nonatomic, assign) int color_Enhancement;
@property (nonatomic , strong) NSString *image_Quality;
@end
