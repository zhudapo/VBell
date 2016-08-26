//
//  IncomingViewController.h
//  VBell
//
//  Created by Jose Zhu on 16/4/26.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IncomingViewController : UIViewController
@property (nonatomic , strong) NSString *name;
@property (nonatomic , strong) NSString *number;
@property (nonatomic , assign) int *status;
@property (nonatomic, assign) int g_callid;
@property (nonatomic, assign) int g_accountid;
@end
