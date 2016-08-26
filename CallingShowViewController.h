//
//  CallingShowViewController.h
//  VBell
//
//  Created by Jose Zhu on 16/4/15.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallingShowViewController : UIViewController
@property (nonatomic , strong) NSString *name;
@property (nonatomic , strong) NSString *number;
@property (nonatomic, assign) int g_callid;
@property (nonatomic, assign) int g_accountid;
@end
