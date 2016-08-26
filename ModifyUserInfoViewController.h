//
//  ModifyUserInfoViewController.h
//  VBell
//
//  Created by Jose Zhu on 16/4/11.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ModifyUserInfoViewController;

//@protocol ModifyUserInfoViewControllerDelegate <NSObject>
//
//- (void)modifyUserInfoController:(ModifyUserInfoViewController *)controller userName:(NSString *)userName;
//
//@end

@interface ModifyUserInfoViewController : UIViewController
@property (nonatomic, strong) NSString *userNameTitle;
@property(nonatomic)BOOL mIslogin;
//@property (nonatomic, weak) id<ModifyUserInfoViewControllerDelegate> delegate;
@end
