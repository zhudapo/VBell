//
//  NewUsersViewController.h
//  VBell
//
//  Created by Jose Zhu on 16/4/12.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "userModel.h"

@class NewUsersViewController;

@protocol NewUsersViewControllerDelegate <NSObject>

- (void)moreViewController:(NewUsersViewController *)controller addUserModel:(userModel *)userModel andIndex:(NSUInteger)index;

@end

@interface NewUsersViewController : UIViewController
@property (nonatomic, retain) UIWebView *myWebView;
@property (nonatomic, retain) id dataObject;
@property (nonatomic, retain) id dataObjectModel;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) BOOL isNetworkStatusCanUse;



@property (nonatomic, weak) id<NewUsersViewControllerDelegate> delegate;
@end
