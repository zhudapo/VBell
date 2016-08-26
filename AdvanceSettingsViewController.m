//
//  AdvanceSettingsViewController.m
//  VBell
//
//  Created by Jose Zhu on 16/4/7.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "AdvanceSettingsViewController.h"
#import "VBellsqlBase.h"
#import "AdvanceSettingModel.h"
#import "MBProgressHUD.h"

#define labelHeight 40
#define marginHeight 10
#define showFrameViewHeight 40
#define showFrameViewLine 1


@interface AdvanceSettingsViewController ()
@property (nonatomic , strong) NSArray *array;
@property (nonatomic , strong) NSArray *LogLevelArray;
@property (nonatomic , strong) NSArray *IPDeviceArray;
@property(nonatomic)BOOL IsShowFrameView;
@property (nonatomic , strong) UIView *showLogFrameView;
@property (nonatomic , strong) UIView *showIPFrameView;
//@property (nonatomic , strong) UIButton *videoPreviewButton;
@property (nonatomic , strong) UIButton *logLevelButton;
//@property (nonatomic , strong) UIButton *IPLevelButton;
@property (nonatomic, strong) UIView *advanceSettingBackgroundView;
@property (nonatomic, strong) UIScrollView *advanceSettingScrollView;
@property (nonatomic, strong) UIView *advanceSettingViewContainer;

@end

@implementation AdvanceSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    self.title = NSLocalizedString(@"Advance Settings", nil);
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
    
    //查询显示数据
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    NSArray *advanceSettingInfoArray = [base getAdvanceSettingInfo];
    AdvanceSettingModel *model = nil;
    if (advanceSettingInfoArray.count != 0) {
        model = advanceSettingInfoArray[0];
    }else{
        return;
    }
    
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(15, 15, self.view.bounds.size.width - 30, 140)];
    //view.backgroundColor = [UIColor redColor];
    self.array = [NSArray arrayWithObjects: @"Log Level", nil];
    

    self.logLevelButton = [[UIButton alloc]initWithFrame:CGRectMake(view.bounds.size.width * 6/7, 33, view.bounds.size.width * 1/7, labelHeight)];
    [_logLevelButton setTitle:model.log_Level forState:UIControlStateNormal];
    _logLevelButton.titleLabel.font = [UIFont systemFontOfSize:13];
    _logLevelButton.tag = 1;
    [_logLevelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_logLevelButton addTarget:self action:@selector(chooseLogLevel) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_logLevelButton];
    [self.view addSubview:view];
    [self createView:view setLabelText:_array];
    
    UIButton *btnSave = [[UIButton alloc]initWithFrame:CGRectMake(15, 93, self.view.bounds.size.width - 30, 40)];
    btnSave.backgroundColor = UnifiedColor;
    [btnSave setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [btnSave addTarget:self action:@selector(saveTosqlite) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSave];
}

- (void)createView:(UIView *)view setLabelText:(NSArray *)labelArray
{
    UIButton *blueDot = [[UIButton alloc]initWithFrame:CGRectMake(0, 5, 5, 5)];
    blueDot.backgroundColor = UnifiedColor;
    blueDot.layer.cornerRadius = blueDot.frame.size.height/2;
    blueDot.layer.masksToBounds = YES;
    UILabel *TopLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, self.view.bounds.size.width, 20)];
    TopLabel.text = NSLocalizedString(@"General Level", nil);
    [TopLabel setTextColor:UnifiedColor];
    UIView *firstViewLine = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width - 30, 3)];
    firstViewLine.backgroundColor = UnifiedColor;
    [view addSubview:blueDot];
//    [view addSubview:firstlabel];
    [view addSubview:TopLabel];
    [view addSubview:firstViewLine];
    for (int i = 0; i <= labelArray.count - 1; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 33, view.bounds.size.width * 6/7, labelHeight)];
        //label.backgroundColor = [UIColor purpleColor];
        label.text = NSLocalizedString(labelArray[i], nil);
        [view addSubview:label];
    }
}

- (void)chooseLogLevel
{
    _advanceSettingBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height+64)];
    _advanceSettingBackgroundView.alpha = 0.7;
    _advanceSettingBackgroundView.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication].keyWindow addSubview:_advanceSettingBackgroundView];
    
    _advanceSettingScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height)];
    [[UIApplication sharedApplication].keyWindow addSubview:_advanceSettingScrollView];
    
    //添加点击手势
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
//    recognizer.delegate = self;
    recognizer.numberOfTouchesRequired = 1;
    [_advanceSettingScrollView addGestureRecognizer:recognizer];
    
    _advanceSettingViewContainer = [[UIView alloc]initWithFrame:CGRectMake(15, self.view.bounds.size.height /2-self.view.bounds.size.height *2/5, self.view.bounds.size.width - 30, 327)];
    _advanceSettingViewContainer.backgroundColor = [UIColor whiteColor];
    _advanceSettingViewContainer.layer.cornerRadius = 1.0f;
    
    CGFloat videoResolutionViewContainerwidth = _advanceSettingViewContainer.bounds.size.width;
    
    [_advanceSettingScrollView addSubview:_advanceSettingViewContainer];
    
    self.LogLevelArray = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7", nil];
    for (int i = 0; i < _LogLevelArray.count; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, i*(showFrameViewHeight+1), videoResolutionViewContainerwidth, 40)];
        [btn setTitle:_LogLevelArray[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.tag = i;
        [btn addTarget:self action:@selector(logLevelClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, (i+1)*showFrameViewHeight+i, videoResolutionViewContainerwidth, 1)];
        lineView.backgroundColor = [UIColor grayColor];
        
        [_advanceSettingViewContainer addSubview:btn];
        [_advanceSettingViewContainer addSubview:lineView];
    }
}


- (void)logLevelClick:(UIButton *)btn
{
    NSString *changeTitle = [_LogLevelArray objectAtIndex:btn.tag];
    [_logLevelButton setTitle:changeTitle forState:UIControlStateNormal];
    _IsShowFrameView = NO;
    [_advanceSettingBackgroundView removeFromSuperview];
    [_advanceSettingScrollView removeFromSuperview];
}

-(void)singleTap:(UITapGestureRecognizer*)recognizer
{
    [_advanceSettingBackgroundView removeFromSuperview];
    [_advanceSettingScrollView removeFromSuperview];
}

#pragma mark 保存
- (void)saveTosqlite
{
    NSString *log_level = _logLevelButton.titleLabel.text;
//    NSString *ip_level = _IPLevelButton.titleLabel.text;
//    int video_preview = 0;
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
//    video_preview = _videoPreviewButton.selected?1:0;
    if ([base updateAdvanceLog_level:log_level]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"Save audio setting success!", @"HUD message title");
        hud.offset = CGPointMake(0.f, 0.f);
        [hud hideAnimated:YES afterDelay:1.f];
        [[self navigationController] popViewControllerAnimated:YES];
    }else{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"Save audio setting failed!", @"HUD message title");
        hud.offset = CGPointMake(0.f, 0.f);
        [hud hideAnimated:YES afterDelay:1.f];
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (void)backToLastController
{
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
