//
//  mainViewController.m
//  VBell
//
//  Created by Jose Zhu on 16/4/6.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//  主view

#import "mainViewController.h"
//#import "settingViewController.h"
#import "YQSlideMenuController.h"
#import "AccountManagerViewController.h"
#import "AllCallsViewController.h"
#import "NewUsersViewController.h"
#import "ModifyDeviceViewController.h"
#import "Masonry.h"
#import "VBellsqlBase.h"
#import "Reachability.h"
#import "ModifyUserInfoViewController.h"
#import "AccountGroupsModel.h"
#import "AllCallsTableViewCell.h"
#import "CallHistoryModel.h"
#import "DeviceInfoViewController.h"
#import "MBProgressHUD.h"
#import "CallingShowViewController.h"
#import "LoginViewController.h"
#include "sipcall_api.h"
#include "media_engine.h"
#include "video_render_ios_view.h"


static int g_accountid = 0;
static int g_callid = 0;
#define rl_log_debug printf
#define rl_log_info printf
#define rl_log_err printf



@interface mainViewController ()<NewUsersViewControllerDelegate,UITableViewDelegate,UITableViewDataSource>{
    int dicCount;
    int callType;
}
@property (nonatomic, strong) UIButton *btnAccount;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) Reachability *conn;
@property (nonatomic, strong) NSString *NetworkState;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, assign) BOOL loginStatus;
@property (nonatomic , strong) UIButton *allCalls;
@property (nonatomic , strong) UIButton *inComing;
@property (nonatomic , strong) UIButton *outGoing;
@property (nonatomic, strong) UIView *allCallingView;
@property (nonatomic, strong) UIView *comingCallingView;
@property (nonatomic, strong) UIView *outCallingView;
@property (nonatomic , strong) NSMutableArray *allCallsArray;
@property (nonatomic , strong) NSMutableArray *inComingArray;
@property (nonatomic , strong) NSMutableArray *outGoingArray;
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) CallHistoryModel *selectedBody;
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, strong) LoginViewController *loginVC;
@end

@implementation mainViewController

- (NSMutableArray *)arrayModel
{
    if (!_arrayModel) {
        _arrayModel = [NSMutableArray array];
    }
    return _arrayModel;
}

- (NSMutableArray *)doubleArrayModel
{
    if (!_doubleArrayModel) {
        _doubleArrayModel = [NSMutableArray array];
    }
    return _doubleArrayModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置nav
    self.navigationController.navigationBar.barTintColor = UnifiedColor;
//    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"My Device", nil);//@"My Device";
    UIColor * color = [UIColor whiteColor];
    NSDictionary * dict = [NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    self.navigationController.navigationBar.translucent = NO;
    
    //创建一个UIButton
    UIButton *leftMenuButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    //设置UIButton的图像
    [leftMenuButton setImage:[UIImage imageNamed:@"more.png"] forState:UIControlStateNormal];
    //给UIButton绑定一个方法，在这个方法中进行popViewControllerAnimated
    [leftMenuButton addTarget:self action:@selector(showLeftMenuController) forControlEvents:UIControlEventTouchUpInside];
    //然后通过系统给的自定义BarButtonItem的方法创建BarButtonItem
    UIBarButtonItem *leftMenu = [[UIBarButtonItem alloc]initWithCustomView:leftMenuButton];
    self.navigationItem.leftBarButtonItem = leftMenu;
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navigationbar_more_highlighted"] style:UIBarButtonSystemItemReply target:self action:@selector(showLeftMenuController)];
    //判断网络
    [self checkNetworkState];
    //检测网络
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkState) name:kReachabilityChangedNotification object:nil];
    self.conn = [Reachability reachabilityForInternetConnection];
    [self.conn startNotifier];
    
    //获取数据
    [self getData];
    // 设置UIPageViewController的配置项
    NSDictionary *options =[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin] forKey:UIPageViewControllerOptionSpineLocationKey];
    // 实例化UIPageViewController对象，根据给定的属性
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options: options];
    _pageController.dataSource = self;
    [[_pageController view] setFrame:CGRectMake(0, 20, DeviceScreenWidth, DeviceScreenHeight/3+self.navigationController.navigationBar.bounds.size.height)];
    //初始化时拿到第一页
//    _pageController.view.backgroundColor = [UIColor redColor];
    NewUsersViewController *initialViewController =[self viewControllerAtIndex:0];// 得到第一页
    
    NSArray *viewControllers =[NSArray arrayWithObject:initialViewController];
    [_pageController setViewControllers:viewControllers
                              direction:UIPageViewControllerNavigationDirectionForward
                               animated:NO
                             completion:nil];
    // 在页面上，显示UIPageViewController对象的View
    [self addChildViewController:_pageController];
    [[self view] addSubview:[_pageController view]];
    
    //创建UIPageControl
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = _doubleDicModel.count;//总的图片页数
    self.pageControl.currentPage = 0; //当前页
    self.pageControl.userInteractionEnabled = NO;
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithRed:201.0/255 green:201.0/255 blue:201.0/255 alpha:1.0f];
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:135.0/255 green:192.0/255 blue:208.0/255 alpha:1.0f];
    //_pageControl.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.pageControl];
    
    self.tableView = [[UITableView alloc]init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    self.allCallingView = [[UIView alloc]init];
    _allCallingView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_allCallingView];
    
    self.comingCallingView = [[UIView alloc]init];
    _comingCallingView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_comingCallingView];
    
    self.outCallingView = [[UIView alloc]init];
    _outCallingView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_outCallingView];
    
    self.allCalls = [[UIButton alloc]init];
    [_allCalls setTitle:NSLocalizedString(@"All Calls", nil) forState:UIControlStateNormal];
    
    [_allCalls setTitleColor:[UIColor orangeColor]forState:UIControlStateNormal];
    [self.view addSubview:_allCalls];
    
    self.inComing = [[UIButton alloc]init];
    [_inComing setTitle:NSLocalizedString(@"Incoming", nil) forState:UIControlStateNormal];
    [_inComing setTitleColor:UnifiedColor forState:UIControlStateNormal];
    //    _inComing.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_inComing];
    
    self.outGoing = [[UIButton alloc]init];
    [_outGoing setTitle:NSLocalizedString(@"Outgoing", nil) forState:UIControlStateNormal];
    [_outGoing setTitleColor:UnifiedColor forState:UIControlStateNormal];
    [self.view addSubview:_outGoing];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginMessage:) name:@"loginMessage" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginoutMessage:) name:@"loginoutMessage" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeTitleNameMessage:) name:@"changeTitleNameMessage" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteDevice:) name:@"DELETEDEVICE" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(modifyDevice:) name:@"MODIFYDEVICE" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(isVideoCall) name:@"VIDEOCALL" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(isAudioCall) name:@"AUDIOCALL" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(isReadyCall:) name:@"CHANGEREGISTERSTATE" object:nil];
    
//    [self localLogin];MODIFYDEVICE
}

- (void)viewWillAppear:(BOOL)animated
{
    //界面布局
    [self setupUI];
    [self showAllCalls];
}

- (void)getData
{
    //查询显示数据
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    self.arrayModel = [base getUserInfo];
    dicCount = 0;
    
    if (self.arrayModel.count != 0) {
        if (self.arrayModel.count%2==0) {//偶数
            for (int i = 0; i<(self.arrayModel.count-1); i++) {
                self.doubleArrayModel = [NSMutableArray array];
                [self.doubleArrayModel addObject:[_arrayModel objectAtIndex:i]];
                [self.doubleArrayModel addObject:[_arrayModel objectAtIndex:++i]];
                if (i==1) {
                    self.doubleDicModel = [NSMutableDictionary dictionaryWithObject:_doubleArrayModel forKey:[NSString stringWithFormat:@"%d",dicCount]];
                }else{
                    [self.doubleDicModel setObject:_doubleArrayModel forKey:[NSString stringWithFormat:@"%d",dicCount]];
                }
                dicCount +=1;
            }
            [self.arrayModel addObject:NSLocalizedString(@"Add Device", nil)];
            [_doubleDicModel setObject:[_arrayModel lastObject] forKey:[NSString stringWithFormat:@"%d",dicCount]];
        }else if (self.arrayModel.count/2 != 0 || self.arrayModel.count == 1)//奇数
        {
            [self.arrayModel addObject:NSLocalizedString(@"Add Device", nil)];
            for (int i = 0; i<=(self.arrayModel.count-1); i++) {
                self.doubleArrayModel = [NSMutableArray array];
                [self.doubleArrayModel addObject:[_arrayModel objectAtIndex:i]];
                [self.doubleArrayModel addObject:[_arrayModel objectAtIndex:++i]];
                if (i==1) {
                    self.doubleDicModel = [NSMutableDictionary dictionaryWithObject:_doubleArrayModel forKey:[NSString stringWithFormat:@"%d",dicCount]];
                }else{
                    [self.doubleDicModel setObject:_doubleArrayModel forKey:[NSString stringWithFormat:@"%d",dicCount]];
                }
                dicCount +=1;
            }
        }
        NSLog(@"jose%@",_doubleDicModel);
    }else
    {
        [self.arrayModel addObject:NSLocalizedString(@"Add Device", nil)];
        self.doubleDicModel = [NSMutableDictionary dictionaryWithObject:_arrayModel forKey:[NSString stringWithFormat:@"%d",dicCount]];
    }
}


- (void)setupUI
{
    __weak typeof(self) weakSelf = self;

    //添加约束适配屏幕
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.view);
        make.size.mas_equalTo(CGSizeMake(DeviceScreenWidth,DeviceScreenHeight*2/3-self.navigationController.navigationBar.bounds.size.height*1.5));
    }];
    
    [_allCallingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_tableView.mas_top);
        make.size.mas_equalTo(CGSizeMake(DeviceScreenWidth/3,2));
    }];
    [_comingCallingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_tableView.mas_top);
        make.left.offset(DeviceScreenWidth/3);
        make.size.mas_equalTo(CGSizeMake(DeviceScreenWidth/3,2));
    }];
    [_outCallingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_tableView.mas_top);
        make.left.offset(DeviceScreenWidth*2/3);
        make.size.mas_equalTo(CGSizeMake(DeviceScreenWidth/3,2));
    }];
    
    [_allCalls mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_allCallingView.mas_top);
        make.size.mas_equalTo(CGSizeMake(DeviceScreenWidth/3,30));
    }];
    [_inComing mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_allCallingView.mas_top);
        make.left.offset(DeviceScreenWidth/3);
        make.size.mas_equalTo(CGSizeMake(DeviceScreenWidth/3,30));
    }];
    [_outGoing mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_allCallingView.mas_top);
        make.left.offset(DeviceScreenWidth*2/3);
        make.size.mas_equalTo(CGSizeMake(DeviceScreenWidth/3,30));
    }];
    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_allCalls.mas_top);
        make.size.mas_equalTo(CGSizeMake(self.view.bounds.size.width,self.navigationController.navigationBar.bounds.size.height*1/3));
    }];
    
    [_allCalls addTarget:self action:@selector(showAllCalls) forControlEvents:UIControlEventTouchUpInside];
    [_inComing addTarget:self action:@selector(showInComing) forControlEvents:UIControlEventTouchUpInside];
    [_outGoing addTarget:self action:@selector(showOutGoing) forControlEvents:UIControlEventTouchUpInside];
}

-(void)showAllCalls
{
    [_inComingArray removeAllObjects];
    [_outGoingArray removeAllObjects];
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    self.allCallsArray = [base getCallingHistoryDictionary:0];
//    self.allCallsArray = [base getCallingHistoryDictionary:0 andCallNumber:@""];
    _allCallingView.backgroundColor = [UIColor orangeColor];
    [_allCalls setTitleColor:[UIColor orangeColor]forState:UIControlStateNormal];
    _comingCallingView.backgroundColor = [UIColor clearColor];
    [_inComing setTitleColor:UnifiedColor forState:UIControlStateNormal];
    _outCallingView.backgroundColor = [UIColor clearColor];
    [_outGoing setTitleColor:UnifiedColor forState:UIControlStateNormal];
    
    //self.array = [SAMPLEEASIIOSIP getAllHistory];
    [_tableView reloadData];
}

-(void)showInComing
{
    [_allCallsArray removeAllObjects];
    [_outGoingArray removeAllObjects];
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
//    self.inComingArray = [base getCallingHistoryDictionary:2 andCallNumber:@""];
    _comingCallingView.backgroundColor = [UIColor orangeColor];
    [_inComing setTitleColor:[UIColor orangeColor]forState:UIControlStateNormal];
    _allCallingView.backgroundColor = [UIColor clearColor];
    [_allCalls setTitleColor:UnifiedColor forState:UIControlStateNormal];
    _outCallingView.backgroundColor = [UIColor clearColor];
    [_outGoing setTitleColor:UnifiedColor forState:UIControlStateNormal];
    self.inComingArray = [base getCallingHistoryDictionary:2];
    //self.array = [SAMPLEEASIIOSIP getAllHistory];
    [_tableView reloadData];
}

-(void)showOutGoing
{
    [_inComingArray removeAllObjects];
    [_allCallsArray removeAllObjects];
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
//    self.outGoingArray = [base getCallingHistoryDictionary:1 andCallNumber:@""];
    _outCallingView.backgroundColor = [UIColor orangeColor];
    [_outGoing setTitleColor:[UIColor orangeColor]forState:UIControlStateNormal];
    _comingCallingView.backgroundColor = [UIColor clearColor];
    [_inComing setTitleColor:UnifiedColor forState:UIControlStateNormal];
    _allCallingView.backgroundColor = [UIColor clearColor];
    [_allCalls setTitleColor:UnifiedColor forState:UIControlStateNormal];
    self.outGoingArray = [base getCallingHistoryDictionary:1];
    //self.array = [SAMPLEEASIIOSIP getAllHistory];
    [_tableView reloadData];
}


- (void)changepagecountMoreandModify:(UIButton *)button andIndex:(NSUInteger)index
{
    NewUsersViewController * initialViewController =[self viewControllerAtIndex:index];// 得到第一页
    NSArray *viewControllers =[NSArray arrayWithObject:initialViewController];
    [_pageController setViewControllers:viewControllers
                              direction:UIPageViewControllerNavigationDirectionForward
                               animated:NO
                             completion:nil];
    
    self.pageControl.numberOfPages = self.doubleDicModel.count;//总的页数
    self.pageControl.currentPage = index;
}


- (void)changepagecountDelete:(UIButton *)button andIndex:(NSUInteger)index
{
    NewUsersViewController *initialViewController = nil;
    if (index == 0) {
        initialViewController = [self viewControllerAtIndex:index];
    }else{
        initialViewController = [self viewControllerAtIndex:index-1];
    }
    
    NSArray *viewControllers =[NSArray arrayWithObject:initialViewController];
    [_pageController setViewControllers:viewControllers
                              direction:UIPageViewControllerNavigationDirectionForward
                               animated:NO
                             completion:nil];
    
    self.pageControl.numberOfPages = self.doubleDicModel.count;//总的页数
    self.pageControl.currentPage = index;
}

// 得到相应的VC对象  就是这里
- (NewUsersViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (([self.doubleDicModel count] == 0) || (index >= [self.doubleDicModel count])) {
        return nil;
    }
    // 创建一个新的控制器类，并且分配给相应的数据
    NewUsersViewController *dataViewController =[[NewUsersViewController alloc] init];
    dataViewController.dataObjectModel = [_doubleDicModel objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)index]];
    dataViewController.index = index;
    dataViewController.delegate = self;
    
    return dataViewController;
}

// 根据数组元素值，得到下标值
- (NSUInteger)indexOfViewController:(NewUsersViewController *)viewController {
    return viewController.index;//[self.arrayModel indexOfObject:viewController.dataObjectModel];
//    return [self.doubleDicModel objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)index]];
}

- (void)isVideoCall
{
    callType = 1;
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    //当前呼叫时间
    NSDateFormatter *foromatter = [[NSDateFormatter alloc]init];
    [foromatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time = [foromatter stringFromDate:[NSDate date]];
    
    [base insertCallingHistoryTabNumber:_selectedBody.phoneNumber name:_selectedBody.userName Calltime:time callType:callType callDictionary:1];
}

- (void)isAudioCall
{
    callType = 0;
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    //当前呼叫时间
    NSDateFormatter *foromatter = [[NSDateFormatter alloc]init];
    [foromatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time = [foromatter stringFromDate:[NSDate date]];
    
    [base insertCallingHistoryTabNumber:_selectedBody.phoneNumber name:_selectedBody.userName Calltime:time callType:callType callDictionary:1];
}

- (void)isReadyCall:(NSNotification *)notification
{
    NSDictionary * infoDic = [notification object];
    NSString *registerState = [infoDic valueForKey:@"registerState"];
    if ([registerState isEqualToString:@"2"]) {
        _isReady = YES;
    }
    
}

#pragma mark- MoreViewControllerDelegate
- (void)moreViewController:(NewUsersViewController *)controller addUserModel:(userModel *)userModel andIndex:(NSUInteger)index
{
    
    
//    [self.doubleDicModel setObject:userModel forKey:[NSString stringWithFormat:@"%lu",(unsigned long)index]];
    [self getData];
    [self.arrayModel insertObject:userModel atIndex:index];
    [self changepagecountMoreandModify:nil andIndex:index];
}

- (void)deleteDevice:(NSNotification *)notification
{
    [self getData];
    [self changepagecountDelete:nil andIndex:0];
}
- (void)modifyDevice:(NSNotification *)notification
{
    [self getData];
    [self changepagecountMoreandModify:nil andIndex:0];
}


#pragma mark- UIPageViewControllerDataSource

// 返回上一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    
    NSUInteger index = [self indexOfViewController:(NewUsersViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        self.pageControl.currentPage = 0;
        return nil;
    }
    self.pageControl.currentPage = index;
    index--;
    // 返回的ViewController，将被添加到相应的UIPageViewController对象上。
    // UIPageViewController对象会根据UIPageViewControllerDataSource协议方法，自动来维护次序。
    // 不用我们去操心每个ViewController的顺序问题。
    return [self viewControllerAtIndex:index];
    
    
}

// 返回下一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    
    NSUInteger index = [self indexOfViewController:(NewUsersViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    self.pageControl.currentPage = index;
    index++;
    if (index == [self.doubleDicModel count]) {
        self.pageControl.currentPage = index;
        return nil;
    }
    return [self viewControllerAtIndex:index];
}


//// allCalls
//- (void) history
//{
//    AllCallsViewController *allCallsVC = [[AllCallsViewController alloc]init];
//    allCallsVC.allUserArrayModel = _arrayModel;
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
//    self.navigationItem.backBarButtonItem = barButtonItem;
//    [self.navigationController pushViewController:allCallsVC animated:YES];
//}

//Accounts
- (void) accounts
{
    AccountManagerViewController *accountManagerVC = [[AccountManagerViewController alloc]init];
    if (_loginStatus) {
        accountManagerVC.UISwitchStatus = YES;
    }else{
        accountManagerVC.UISwitchStatus = NO;
    }
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = barButtonItem;
    [self.navigationController pushViewController:accountManagerVC animated:YES];
    
}

//settings
- (void)showLeftMenuController
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"showLeftMenu" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.conn stopNotifier];
//    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VIDEOCALL" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AUDIOCALL" object:nil];
//
}

//关闭通知
//- (void)dealloc
//{
//    [self.conn stopNotifier];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VIDEOCALL" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AUDIOCALL" object:nil];
//}
//判断网络
- (void)checkNetworkState
{
    // 1.检测wifi状态
    Reachability *wifi = [Reachability reachabilityForLocalWiFi];

    // 2.检测手机是否能上网络(WIFI\3G\2.5G)
    Reachability *conn = [Reachability reachabilityForInternetConnection];

    // 3.判断网络状态
    if ([wifi currentReachabilityStatus] != NotReachable || [conn currentReachabilityStatus] != NotReachable) { // 有网络
        //[_btnAccount setTitle:_NetworkState.length==0?@"Account 1":_NetworkState forState:UIControlStateNormal];
        [self getUserInfoandHelpLogin];
        self.NetworkState = _username.length == 0?@"Account 1":_username;
        [_btnAccount setTitle:_NetworkState forState:UIControlStateNormal];
     }else { // 没有网络
        self.NetworkState = @"Network Unavailable";
         [_btnAccount setTitle:_NetworkState forState:UIControlStateNormal];
         [_btnAccount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

- (void)getUserInfoandHelpLogin
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    self.username = [settings objectForKey:@"username"];
    NSString *pwd = [settings objectForKey:@"password"];
    if (_username.length!=0&&pwd.length!=0) {
        [self localLogin:_username andpassword:pwd];
    }
}

- (void)localLogin:(NSString *)usernameStr andpassword:(NSString *)password
{
//    [[SampleEasiioSIP sharedSampleSIP] login:usernameStr passwork:password callback:^(BOOL result, int resultCode, NSString *resultMsg) {
//        NSLog(@"%d,%d,%@",result,resultCode,resultMsg);
//        if (result) {
//            [_btnAccount setTitleColor:[UIColor colorWithRed:46.0/255 green:166.0/255 blue:36.0/255 alpha:1.0] forState:UIControlStateNormal];
//            _loginStatus = YES;
//        } else {
//            _NetworkState = @"Account 1";
//            [_btnAccount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//            if (resultCode == 0) {
//                NSLog(@"网络请求失败，请检查网络连接");
//            } else if (resultCode == 2) {
//                NSLog(@"密码错误或密码账号不匹配");
//            } else if (resultCode == 3) {
//                NSLog(@"获取sip设置信息失败");
//            } else if (resultCode == 4) {
//                NSLog(@"登录帐号或用户名不存在");
//            } else if (resultCode == 5) {
//                NSLog(@"更新域名信息失败");
//            }
//            _loginStatus = NO;
//        }
//    }];
}

- (void)loginMessage:(NSNotification *)notification
{
    [_btnAccount setTitleColor:[UIColor colorWithRed:46.0/255 green:166.0/255 blue:36.0/255 alpha:1.0] forState:UIControlStateNormal];
    _loginStatus = YES;
}

- (void)loginoutMessage:(NSNotification *)notification
{
    [_btnAccount setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    _loginStatus = NO;
}

- (void)changeTitleNameMessage:(NSNotification *)notification
{
    NSString *userNameTitle = notification.userInfo[@"userName"];
    _loginStatus = YES;
    [_btnAccount setTitleColor:[UIColor colorWithRed:46.0/255 green:166.0/255 blue:36.0/255 alpha:1.0] forState:UIControlStateNormal];
    [_btnAccount setTitle:userNameTitle forState:UIControlStateNormal];
}

#pragma mark -tableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AllCallsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identity"];
    
    CallHistoryModel *selectedBody = [[CallHistoryModel alloc]init];
    if (_allCallsArray.count != 0) {
        selectedBody = [_allCallsArray objectAtIndex:indexPath.row];
    }else if (_inComingArray.count != 0){
        selectedBody = [_inComingArray objectAtIndex:indexPath.row];
    }else{
        selectedBody = [_outGoingArray objectAtIndex:indexPath.row];
    }
    if (!cell) {
        cell = [[AllCallsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"identity"];
        //cell.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    }
    cell.contentView.backgroundColor = [UIColor whiteColor];
    //需要替换
//    [cell setContent];
    cell.tag=indexPath.row;
    //selectedBody.mIsReadyDel = _mIsReadyDel;
    [cell setContent:selectedBody];
    //UILongPressGestureRecognizer * longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(cellLongPress:)];
    
    
    //[cell addGestureRecognizer:longPressGesture];
    return cell;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_allCallsArray.count != 0) {
        return _allCallsArray.count;
    }else if (_inComingArray.count != 0){
        return _inComingArray.count;
    }else{
        return _outGoingArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"Delete", nil);
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (_allCallsArray.count != 0) {
            CallHistoryModel *model = [_allCallsArray objectAtIndex:indexPath.row];
            NSString *callTime = model.time;
            VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
            if ([base deleteOneCallHistoryWithTime:callTime]) {
                NSLog(@"DELETE CallHistory SUCCESS");
                [self showHUDMessage:@"Delete history record success!"];
                [_allCallsArray removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath]withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }else if (_inComingArray.count != 0){
            [_inComingArray removeObjectAtIndex:indexPath.row];
        }else{
            [_outGoingArray removeObjectAtIndex:indexPath.row];
        }
        
    }
    else
    {
//        [self.dataArr addObject:@100];
//        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.dataArr.count - 1 inSection:0];
//        [tableView insertRowsAtIndexPaths:@[newIndexPath]withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)showHUDMessage:(NSString *)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = NSLocalizedString(message, @"HUD message title");
    hud.offset = CGPointMake(0.f, 0.f);
    [hud hideAnimated:YES afterDelay:1.f];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isReady) {
        //取消选中高亮
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        _selectedBody = [[CallHistoryModel alloc]init];
        if (_allCallsArray.count != 0) {
            _selectedBody = [_allCallsArray objectAtIndex:indexPath.row];
        }else if (_inComingArray.count != 0){
            _selectedBody = [_inComingArray objectAtIndex:indexPath.row];
        }else{
            _selectedBody = [_outGoingArray objectAtIndex:indexPath.row];
        }
        
        NSLog(@"make call");
        CallingShowViewController *callingShowVC = [[CallingShowViewController alloc]init];
        //呼叫
        int cid = 1000;
        SIPCALL_DIALOUT_DATA dialout;
        memset(&dialout, 0, sizeof(dialout));
        dialout.cid = cid;
        strcpy(dialout.remote_username, [_selectedBody.phoneNumber UTF8String]);
        NSString *callNumber =  _selectedBody.phoneNumber;
        NSArray *array = [callNumber componentsSeparatedByString:@"."];
        if (array.count == 4) {
            sipcall_send_msg(SIPCALL_SEND_MSG_DIALOUT, cid, 1, &dialout, sizeof(dialout));
            g_callid = cid;
            g_accountid = 1;
            callingShowVC.g_accountid = 1;
        }else{
            sipcall_send_msg(SIPCALL_SEND_MSG_DIALOUT, cid, 0, &dialout, sizeof(dialout));
            g_callid = cid;
            g_accountid = 0;
            callingShowVC.g_accountid = 0;
        }
        callingShowVC.g_callid = cid;
        callingShowVC.name = _selectedBody.userName;
        callingShowVC.number = _selectedBody.phoneNumber;
        _callback(_selectedBody.phoneNumber);
        [self presentViewController:callingShowVC animated:YES completion:nil];
    }else{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"Account is not Ready", @"HUD message title");
        // Move to bottm center.
        hud.offset = CGPointMake(0.f, 0.f);
        [hud hideAnimated:YES afterDelay:1.f];
        return;
    }
    
    
}


@end
