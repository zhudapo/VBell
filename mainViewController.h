//
//  mainViewController.h
//  VBell
//
//  Created by Jose Zhu on 16/4/6.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^CallBack)(NSString *makeCallNumber);

@interface mainViewController : UIViewController<UIPageViewControllerDataSource>
@property (strong, nonatomic) UIPageViewController *pageController;
@property (nonatomic, strong) NSMutableArray *arrayModel;
@property (nonatomic, strong) NSMutableArray *doubleArrayModel;
@property (nonatomic, strong) NSMutableDictionary *doubleDicModel;
@property (nonatomic, strong) CallBack callback;
@end
