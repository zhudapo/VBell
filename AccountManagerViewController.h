//
//  AccountManagerViewController.h
//  VBell
//
//  Created by Jose Zhu on 16/4/7.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AccountManagerViewController;

@protocol AccountManagerViewControllerDelegate <NSObject>

- (void)ModifyUserDetail:(AccountManagerViewController *)cell userName:(NSString *)username;

@end


@interface AccountManagerViewController : UIViewController
@property (nonatomic, strong) NSString *registerState;
@property (nonatomic, assign) BOOL UISwitchStatus;
@property (nonatomic, weak) id<AccountManagerViewControllerDelegate> delegate;

@end
