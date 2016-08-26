//
//  AccountManagerViewController.m
//  VBell
//
//  Created by Jose Zhu on 16/4/7.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "AccountManagerViewController.h"
#import "ModifyUserInfoViewController.h"
#import "AccountManagerCell.h"
#import "VBellsqlBase.h"
//#import "Reachability.h"

@interface AccountManagerViewController ()//<ModifyUserInfoViewControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *onClickBtn;
@property (nonatomic, strong) UILabel *userNameTitle;
@property (nonatomic, strong) UILabel *userNameTitleDetail;
@property (nonatomic, strong) UILabel *userRegisterState;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, assign) BOOL loginStatus;
@property (nonatomic, strong) NSString *AccountName;
@property (nonatomic, strong) UISwitch *switchOnline;

@end

@implementation AccountManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    self.title = NSLocalizedString(@"Account Manager", nil);
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
  
//    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
//    [self.view addSubview:_tableView];
//    _tableView.separatorStyle = NO;
//    _tableView.delegate = self;
//    _tableView.dataSource = self;
    NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
    self.AccountName = [user objectForKey:@"userName"];
    
    
    _onClickBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, DeviceScreenWidth, 60)];
    _onClickBtn.backgroundColor = [UIColor whiteColor];
    [_onClickBtn addTarget:self action:@selector(modifyUserDetail) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_onClickBtn];
    
    UIButton *imageBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 60, 60)];
    [imageBtn setImage:[UIImage imageNamed:@"Account Manager.png"] forState:UIControlStateNormal];
    [self.view addSubview:imageBtn];
    [_onClickBtn addSubview:imageBtn];
    
    _userNameTitle = [[UILabel alloc]initWithFrame:CGRectMake(80, 5, 250, 25)];
    _userNameTitleDetail = [[UILabel alloc]initWithFrame:CGRectMake(80, 35, 250, 20)];
    _userRegisterState = [[UILabel alloc]initWithFrame:CGRectMake(150, 35, 120, 20)];
    _switchOnline = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-80, 10, 70, 30)];
    
    _userRegisterState.textAlignment = NSTextAlignmentLeft;
    
    if (_AccountName.length == 0) {
        _userNameTitle.text = @"Account 1";
        _userNameTitleDetail.text = @"Account 1";
        _userRegisterState.text = NSLocalizedString(@"Disable", nil);
    }else{
        _userNameTitle.text = _AccountName;
    }
    [_onClickBtn addSubview:_userNameTitle];
    [_onClickBtn addSubview:_userNameTitleDetail];
    [_onClickBtn addSubview:_userRegisterState];
    [_onClickBtn addSubview:_switchOnline];
    
    
    _userNameTitleDetail.font = [UIFont systemFontOfSize:14];
    _userRegisterState.font = [UIFont systemFontOfSize:14];
    if ([_registerState isEqualToString:@"1"]) {
        _userNameTitleDetail.textColor = [UIColor greenColor];
        _userNameTitle.textColor = [UIColor greenColor];
        _userRegisterState.textColor = [UIColor greenColor];
        _userNameTitleDetail.text = _AccountName;
        _userRegisterState.text = NSLocalizedString(@"Registering", nil);
    }else if ([_registerState isEqualToString:@"2"]){
        _userNameTitleDetail.textColor = UnifiedColor;
        _userNameTitle.textColor = UnifiedColor;
        _userRegisterState.textColor = UnifiedColor;
        _userNameTitleDetail.text = _AccountName;
        _userRegisterState.text = NSLocalizedString(@"Registered", nil);
        [_switchOnline setOn:YES];
    }else if ([_registerState isEqualToString:@"3"]){
        _userNameTitle.textColor = [UIColor redColor];
        _userNameTitleDetail.textColor = [UIColor redColor];
        _userRegisterState.textColor = [UIColor redColor];
        _userNameTitleDetail.text = _AccountName;
        _userRegisterState.text = NSLocalizedString(@"Failed", nil);
    }else{
        _userNameTitle.textColor = [UIColor grayColor];
        _userNameTitleDetail.textColor = [UIColor redColor];
        _userRegisterState.textColor = [UIColor redColor];
        _userNameTitleDetail.text = _AccountName;
        _userRegisterState.text = NSLocalizedString(@"Disabled", nil);
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeRegisterState:) name:@"CHANGEREGISTERSTATE" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeLoginName:) name:@"CHANGELOGINNAME" object:nil];
}

- (void)changeRegisterState:(NSNotification *)notification
{
    NSDictionary * infoDic = [notification object];
    NSString *registerState = [infoDic valueForKey:@"registerState"];
    if ([registerState isEqualToString:@"3"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _userNameTitle.textColor = [UIColor redColor];
            _userNameTitleDetail.textColor = [UIColor redColor];
            _userRegisterState.textColor = [UIColor redColor];
            _userRegisterState.text = _AccountName;
            _userRegisterState.text = NSLocalizedString(@"Failed", nil);
        });
    }else if ([registerState isEqualToString:@"2"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            _userNameTitle.textColor = UnifiedColor;
            _userNameTitleDetail.textColor = UnifiedColor;
            _userRegisterState.textColor = UnifiedColor;
            _userRegisterState.text = _AccountName;
            _userRegisterState.text = NSLocalizedString(@"Registered", nil);
            [_switchOnline setOn:YES];
        });
    }else if ([registerState isEqualToString:@"1"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            _userNameTitle.textColor = [UIColor greenColor];
            _userNameTitleDetail.textColor = [UIColor greenColor];
            _userRegisterState.textColor = [UIColor greenColor];
            _userNameTitleDetail.text = _AccountName;
            _userRegisterState.text = NSLocalizedString(@"Registering", nil);
        });
    }else{//0
        dispatch_async(dispatch_get_main_queue(), ^{
            _userNameTitle.textColor = [UIColor grayColor];
            _userNameTitleDetail.textColor = [UIColor grayColor];
            _userRegisterState.textColor = [UIColor grayColor];
            _userNameTitleDetail.text = _AccountName;
            _userRegisterState.text = NSLocalizedString(@"Disabled", nil);
        });
    }
}


- (void)modifyUserDetail
{
    ModifyUserInfoViewController *userInfoVC = [[ModifyUserInfoViewController alloc]init];
    userInfoVC.userNameTitle = _AccountName;
//    userInfoVC.delegate = self;
    [self.navigationController pushViewController:userInfoVC animated:YES];
}


- (void)changeLoginName:(NSNotification *)notification
{
    NSDictionary * infoDic = [notification object];
    NSString *changedName = [infoDic valueForKey:@"changedName"];
    _userNameTitle.text = changedName;
    _userNameTitleDetail.text = changedName;
    _AccountName = changedName;
}

//- (void)modifyUserInfoController:(ModifyUserInfoViewController *)controller userName:(NSString *)userName
//{
//    _userNameTitle.text = userName;
//    _userNameTitleDetail.text = userName;
//    _AccountName = userName;
//    if ([self.delegate respondsToSelector:@selector(ModifyUserDetail:userName:)]) {
//        [self.delegate ModifyUserDetail:self userName:userName];
//    }
//}




#pragma mark -UITableViewDelegate,UITableViewDataSource
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return 1;
//}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *ID = @"identity";
//    AccountManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
//    if (!cell) {
//        cell = [[AccountManagerCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
//        cell.backgroundColor = [UIColor whiteColor];
//    }
//    if (_AccountName.length!=0 && _UISwitchStatus) {
//        [cell setContent:_AccountName loginStatus:YES UISwitchStatus:_UISwitchStatus];
//    }else if (_username.length!=0){
//        [cell setContent:_username loginStatus:_loginStatus UISwitchStatus:_UISwitchStatus];
//    }else if (_AccountName.length!=0 && _UISwitchStatus == NO){
//        [cell setContent:_AccountName loginStatus:YES UISwitchStatus:_UISwitchStatus];
//    } else{
//        [cell setContent:@"Account 1" loginStatus:NO UISwitchStatus:_UISwitchStatus];
//    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    return cell;
//}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"%ld",(long)indexPath.row);
//    ModifyUserInfoViewController *userInfoVC = [[ModifyUserInfoViewController alloc]init];
//    userInfoVC.delegate = self;
//    userInfoVC.userNameTitle = _AccountName;
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
//    self.navigationItem.backBarButtonItem = barButtonItem;
//    [self.navigationController pushViewController:userInfoVC animated:YES];
//}

//- (void)changeLoginStatuesController:(ModifyUserInfoViewController *)controller username:(NSString *)username loginSuccessedOrNot:(BOOL)loginStatues
//{
//    self.username = username;
//    self.loginStatus = loginStatues;
//    [_tableView reloadData];
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 60;
//}
//
//
//- (void)changeRegisterState:(NSNotification *)notification
//{
//    NSString *userNameTitle = notification.userInfo[@"userName"];
//    _UISwitchStatus = YES;
//    _AccountName = userNameTitle;
//}
//
//
//- (void)dealloc
//{
//    [[NSNotificationCenter defaultCenter]removeObserver:self];
//}
//
- (void)backToLastController
{
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
