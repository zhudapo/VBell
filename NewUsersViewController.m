//
//  NewUsersViewController.m
//  VBell
//
//  Created by Jose Zhu on 16/4/12.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "NewUsersViewController.h"
#import "AddUserViewController.h"
#import "CallingShowViewController.h"
#import "ModifyDeviceViewController.h"
#import "userModel.h"
#import "VBellsqlBase.h"
#import "MBProgressHUD.h"
#import "IncomingViewController.h"
#import "DeviceInfoViewController.h"


@interface NewUsersViewController ()

@property (nonatomic, strong) UIButton *detailBtn;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *numberLabel;

@property (nonatomic, strong) UIButton *detailOrAddBtn;
@property (nonatomic, strong) UILabel *nameOrAddLabel;
@property (nonatomic, strong) UILabel *numberOrAddLabel;

@end

@implementation NewUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([_dataObjectModel isKindOfClass:[NSString class]]) {
        self.detailBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 50, 25, 100, 100)];
        [_detailBtn setBackgroundImage:[UIImage imageNamed:@"Add Device.png"] forState:UIControlStateNormal];
        [_detailBtn addTarget:self action:@selector(addUser:) forControlEvents:UIControlEventTouchUpInside];
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 125, self.view.bounds.size.width, 20)];
        _nameLabel.text = NSLocalizedString(@"Add Device", nil);
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = [UIColor grayColor];
        _nameLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:17];
        [self.view addSubview:_nameLabel];
        [self.view addSubview:self.detailBtn];
    }else{
        if ([_dataObjectModel[0] isKindOfClass:[NSString class]]) {
            self.detailBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 50, 15, 100, 100)];
            [_detailBtn setBackgroundImage:[UIImage imageNamed:@"Add Device.png"] forState:UIControlStateNormal];
            [_detailBtn addTarget:self action:@selector(addUser:) forControlEvents:UIControlEventTouchUpInside];
            self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 125, self.view.bounds.size.width, 20)];
            _nameLabel.text = NSLocalizedString(@"Add Device", nil);
            _nameLabel.textAlignment = NSTextAlignmentCenter;
            _nameLabel.textColor = [UIColor grayColor];
            _nameLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:17];
            [self.view addSubview:_nameLabel];
            [self.view addSubview:self.detailBtn];
        }else{
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 115 , DeviceScreenWidth/2, 30)];
        userModel *model = [[userModel alloc]init];
        model = _dataObjectModel[0];
        _nameLabel.text = model.userName;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.numberOfLines = 0;
        _nameLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:13];
        _nameLabel.textColor = [UIColor grayColor];
        [self.view addSubview:_nameLabel];
        
        self.numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 140 , DeviceScreenWidth/2, 20)];
        _numberLabel.text = model.number;
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.numberOfLines = 0;
        _numberLabel.font = [UIFont systemFontOfSize:12];
        _numberLabel.textColor = [UIColor grayColor];
        [self.view addSubview:_numberLabel];
        
        self.detailBtn = [[UIButton alloc] initWithFrame:CGRectMake(DeviceScreenWidth/4 -50, 15, 100, 100)];
        [_detailBtn setImage:[UIImage imageNamed:@"My Device.png"] forState:UIControlStateNormal];
        [_detailBtn addTarget:self action:@selector(showDetail:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_detailBtn];
        
        if ([_dataObjectModel[1] isKindOfClass:[NSString class]]) {
            self.nameOrAddLabel = [[UILabel alloc] initWithFrame:CGRectMake(DeviceScreenWidth/2, 115 , DeviceScreenWidth/2, 30)];
            userModel *model2 = [[userModel alloc]init];
            model2 = _dataObjectModel[1];
            _nameOrAddLabel.text = NSLocalizedString(@"Add Device", nil);
            _nameOrAddLabel.textAlignment = NSTextAlignmentCenter;
            _nameOrAddLabel.numberOfLines = 0;
            _nameOrAddLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:13];
            _nameOrAddLabel.textColor = [UIColor grayColor];
            [self.view addSubview:_nameOrAddLabel];
            
            self.detailOrAddBtn = [[UIButton alloc] initWithFrame:CGRectMake(DeviceScreenWidth*6/8 -50, 15, 100, 100)];
            [_detailOrAddBtn setImage:[UIImage imageNamed:@"Add Device.png"] forState:UIControlStateNormal];
            [_detailOrAddBtn addTarget:self action:@selector(addUser:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_detailOrAddBtn];
        }else{
            self.nameOrAddLabel = [[UILabel alloc] initWithFrame:CGRectMake(DeviceScreenWidth/2, 115 , DeviceScreenWidth/2, 30)];
            userModel *model2 = [[userModel alloc]init];
            model2 = _dataObjectModel[1];
            _nameOrAddLabel.text = model2.userName;
            _nameOrAddLabel.textAlignment = NSTextAlignmentCenter;
            _nameOrAddLabel.numberOfLines = 0;
            _nameOrAddLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:13];
            _nameOrAddLabel.textColor = [UIColor grayColor];
            [self.view addSubview:_nameOrAddLabel];
            
            self.numberOrAddLabel = [[UILabel alloc] initWithFrame:CGRectMake(DeviceScreenWidth/2, 140 , DeviceScreenWidth/2, 20)];
            _numberOrAddLabel.text = model2.number;
            _numberOrAddLabel.textAlignment = NSTextAlignmentCenter;
            _numberOrAddLabel.numberOfLines = 0;
            _numberOrAddLabel.font = [UIFont systemFontOfSize:12];
            _numberOrAddLabel.textColor = [UIColor grayColor];
            [self.view addSubview:_numberOrAddLabel];
            
            self.detailOrAddBtn = [[UIButton alloc] initWithFrame:CGRectMake(DeviceScreenWidth*6/8 -50, 15, 100, 100)];
            [_detailOrAddBtn setImage:[UIImage imageNamed:@"My Device.png"] forState:UIControlStateNormal];
            [_detailOrAddBtn addTarget:self action:@selector(showSecondDetail:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_detailOrAddBtn];
        }
        
        }

    }
}

- (void)addUser:(UIButton *)button
{
    NSLog(@"addUser");
    AddUserViewController *addUser = [[AddUserViewController alloc] init];
    addUser.callback = ^(NSString *userName,NSString *number,NSString *rtspAddress){
        if ([self.delegate respondsToSelector:@selector(moreViewController:addUserModel:andIndex:)]) {
            userModel *model = [[userModel alloc]init];
            model.userName = userName;
            model.number = number;
            model.rtspAddress = rtspAddress;
            [self.delegate moreViewController:self addUserModel:model andIndex:_index];
        }
    };
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
//    self.navigationItem.backBarButtonItem = barButtonItem;
    [self.navigationController pushViewController:addUser animated:YES];
}


- (void)showDetail:(UIButton *)btn
{
    NSLog(@"showDetail");
    DeviceInfoViewController *deviceInfoVC = [[DeviceInfoViewController alloc]init];
    deviceInfoVC.number = _numberLabel.text;
    deviceInfoVC.name = _nameLabel.text;
    [self.navigationController pushViewController:deviceInfoVC animated:YES];
    
//    [self presentViewController:deviceInfoVC animated:YES completion:nil]
//    NSLog(@"call somebody code")
//    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
//    CallingShowViewController *callingVC = [[CallingShowViewController alloc]init];
//    NSDateFormatter *foromatter = [[NSDateFormatter alloc]init];
//    [foromatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSString *time = [foromatter stringFromDate:[NSDate date]];
//    NSString *phoneNumber = _numberLabel.text;
//    NSString *userName = _nameLabel.text;
//    callingVC.name = userName;
//    callingVC.number = phoneNumber;
//    [base insertCallingHistoryTabNumber:phoneNumber name:userName Calltime:time];
    
    //[self presentViewController:callingVC animated:YES completion:nil];
    //self.timer = nil;
    //_timer = [NSTimer scheduledTimerWithTimeInterval:50 target:self selector:@selector(call) userInfo:nil repeats:YES];
}

- (void)showSecondDetail:(UIButton *)btn
{
    NSLog(@"showDetail");
    DeviceInfoViewController *deviceInfoVC = [[DeviceInfoViewController alloc]init];
    deviceInfoVC.number = _numberOrAddLabel.text;
    deviceInfoVC.name = _nameOrAddLabel.text;
    [self.navigationController pushViewController:deviceInfoVC animated:YES];
    //    NSLog(@"call somebody code")
    //    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    //    CallingShowViewController *callingVC = [[CallingShowViewController alloc]init];
    //    NSDateFormatter *foromatter = [[NSDateFormatter alloc]init];
    //    [foromatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //    NSString *time = [foromatter stringFromDate:[NSDate date]];
    //    NSString *phoneNumber = _numberLabel.text;
    //    NSString *userName = _nameLabel.text;
    //    callingVC.name = userName;
    //    callingVC.number = phoneNumber;
    //    [base insertCallingHistoryTabNumber:phoneNumber name:userName Calltime:time];
    
    //[self presentViewController:callingVC animated:YES completion:nil];
    //self.timer = nil;
    //_timer = [NSTimer scheduledTimerWithTimeInterval:50 target:self selector:@selector(call) userInfo:nil repeats:YES];
}

//- (void)modifyUserInfo:(UIButton *)btn
//{
//    userModel *model = [[userModel alloc]init];
//    model = _dataObjectModel;
//    ModifyDeviceViewController *modifyDeviceVC = [[ModifyDeviceViewController alloc] init];
//    modifyDeviceVC.displayName = model.userName;
//    modifyDeviceVC.number = model.number;
//    modifyDeviceVC.rtspAddress = model.rtspAddress;
//    modifyDeviceVC.index = _index;
//    
//    modifyDeviceVC.callback = ^(NSString *userName,NSString *number,NSString *rtspAddress,NSUInteger index){
//        if([self.delegate respondsToSelector:@selector(modifyViewController:modifyUserModel:andIndex:)]){
//            userModel *model = [[userModel alloc]init];
//            model.userName = userName;
//            model.number = number;
//            model.rtspAddress = rtspAddress;
//            [self.delegate modifyViewController:self modifyUserModel:model andIndex:index];
//        }
//    };
//    
////    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
////    self.navigationItem.backBarButtonItem = barButtonItem;
//    [self.navigationController pushViewController:modifyDeviceVC animated:YES];
//}

//- (void)deleteUserInfo:(UIButton *)btn
//{
//    userModel *model = [[userModel alloc]init];
//    model = _dataObjectModel;
//    if([self.delegate respondsToSelector:@selector(modifyViewController:modifyUserModel:andIndex:)]){
//        userModel *model = [[userModel alloc]init];
//        model.number = _numberLabel.text;
//        VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
//        BOOL result = [base deleteUserInfoUsingPhoneNumber:_numberLabel.text];
//        if (result) {
//            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//            hud.mode = MBProgressHUDModeText;
//            hud.label.text = NSLocalizedString(@"Delete Device Success!", @"HUD message title");
//            hud.offset = CGPointMake(0.f, 0.f);
//            [hud hideAnimated:YES afterDelay:1.f];
//            [self.delegate deleteViewController:self modifyUserModel:model andIndex:_index];
//        }else{
//            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//            hud.mode = MBProgressHUDModeText;
//            hud.label.text = NSLocalizedString(@"Delete wrong!", @"HUD message title");
//            hud.offset = CGPointMake(0.f, 0.f);
//            
//            [hud hideAnimated:YES afterDelay:1.f];
//        }
//        
//    }
//}

@end
