//
//  AboutViewController.m
//  VBell
//
//  Created by Jose Zhu on 16/4/7.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    self.title = NSLocalizedString(@"About", nil);
    self.navigationController.navigationBar.translucent = NO;
    //创建一个UIButton
    UIButton *leftMenuButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    //设置UIButton的图像
    [leftMenuButton setImage:[UIImage imageNamed:@"goback.png"] forState:UIControlStateNormal];
    //给UIButton绑定一个方法，在这个方法中进行popViewControllerAnimated
    [leftMenuButton addTarget:self action:@selector(backToLastController) forControlEvents:UIControlEventTouchUpInside];
    //然后通过系统给的自定义BarButtonItem的方法创建BarButtonItem
    UIBarButtonItem *leftMenu = [[UIBarButtonItem alloc]initWithCustomView:leftMenuButton];
    self.navigationItem.leftBarButtonItem = leftMenu;
    
    //1.
    UIView *firstView = [[UIView alloc]initWithFrame:CGRectMake(0, 30, self.view.bounds.size.width, 70)];
    [self.view addSubview:firstView];
    [self createView:firstView setTitle:@"VBell" setDetail:@"Advanced VoIP/Cloud PBX Solution" isLastView:NO];
    //2.
    UIView *secondView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(firstView.bounds) + 50, self.view.bounds.size.width, 70)];
    [self.view addSubview:secondView];
    [self createView:secondView setTitle:@"Application version" setDetail:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] isLastView:NO];
    //3.
    UIView *thirdView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(firstView.bounds) + 100, self.view.bounds.size.width, 70)];
    [self.view addSubview:thirdView];
    [self createView:thirdView setTitle:@"" setDetail:@"Akuvox®2016" isLastView:YES];
    
}

//传一个uiview，将下面的内容添加到uiview中，第一个参数代表第一行显示内容，第二个表示第二行，第三个参数表示这个uiview是否是最后添加的uiview，如果是最后一个则不再绘制底部的线
- (void) createView:(UIView *)view setTitle:(NSString *)title setDetail:(NSString *)detail isLastView:(BOOL)lastView
{
    UILabel *labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    labelTitle.text = title;//@"Application version";
    labelTitle.textColor = UnifiedColor;
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.font = [UIFont systemFontOfSize:23];
    [view addSubview:labelTitle];
    
    UILabel *labelDetail = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(labelTitle.bounds), self.view.bounds.size.width, 40)];
    labelDetail.text = detail;//@"0.0.1.35";
    labelDetail.textAlignment = NSTextAlignmentCenter;
    labelDetail.font = [UIFont systemFontOfSize:15];
    [view addSubview:labelDetail];
    
    if (!lastView) {
        UIView *LineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(view.bounds), self.view.bounds.size.width, 1)];
        LineView.backgroundColor = [UIColor grayColor];
        [view addSubview:LineView];
    }
}

- (void)backToLastController
{
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
