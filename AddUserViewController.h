//
//  AddUserViewController.h
//  UIPageViewControllerDemo
//
//  Created by Jose Zhu on 16/4/12.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef void(^CallBack)(NSString *userName,NSString *number,NSString *rtspAddress);

@interface AddUserViewController : UIViewController
@property (nonatomic, strong) NSString *userNameTitle;
@property(nonatomic)BOOL mIslogin;
@property (nonatomic, strong) CallBack callback;
@end
