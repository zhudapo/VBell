//
//  ModifyDeviceViewController.h
//  VBell
//
//  Created by Jose Zhu on 16/4/19.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "userModel.h"

@class ModifyDeviceViewController;

@protocol ModifyDeviceViewControllerDelegate <NSObject>

- (void)changeDeviceInfoRTSPStatus:(BOOL)changeStatusOrNot andShowRtspLable:(NSString *)RTSPlabel;

@end

typedef void (^ModifyCallBack)(NSString *userName,NSString *number,NSString *rtspAddress,NSUInteger index);

@interface ModifyDeviceViewController : UIViewController
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *number;

@property (nonatomic , assign) NSUInteger index;
@property (nonatomic, strong) NSString *accountName;

//@property (nonatomic, weak) id<ModifyDeviceViewControllerDelegate> delegate;
@property (nonatomic, strong) ModifyCallBack callback;

@property (nonatomic, weak)id<ModifyDeviceViewControllerDelegate> delegate;
@end
