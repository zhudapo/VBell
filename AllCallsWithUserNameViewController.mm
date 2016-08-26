//
//  AllCallsWithUserNameViewController.m
//  VBell
//
//  Created by Jose Zhu on 16/8/12.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "AllCallsWithUserNameViewController.h"
#import "AllCallsTableViewCell.h"
#import "VBellsqlBase.h"
#import "CallHistoryModel.h"
#import "MBProgressHUD.h"
#import "CallingShowViewController.h"
#include "sipcall_api.h"
#include "media_engine.h"
#include "video_render_ios_view.h"


static int g_accountid = 0;
static int g_callid = 0;
#define rl_log_debug printf
#define rl_log_info printf
#define rl_log_err printf

@interface AllCallsWithUserNameViewController ()<UITableViewDataSource,UITableViewDelegate>{
    int callType;
}
@property (nonatomic , strong) UIButton *allCalls;
@property (nonatomic , strong) UIButton *inComing;
@property (nonatomic , strong) UIButton *outGoing;
@property (nonatomic , strong) NSMutableArray *allCallsArray;
@property (nonatomic , strong) NSMutableArray *inComingArray;
@property (nonatomic , strong) NSMutableArray *outGoingArray;
@property (nonatomic , strong) UITableView *table;
@property (nonatomic,strong)UIView *mDelActionView;
@property (nonatomic,strong)UIButton *cancelSelectButton;
@property (nonatomic,strong)UIButton *reverseSelectButton;
@property (nonatomic, strong) UIButton *deleteSelectButton;
@property (nonatomic,strong) UIButton *SelectAllBtn;
@property (nonatomic)BOOL mIsReadyDel;
@end

@implementation AllCallsWithUserNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_table reloadData];
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    self.title = NSLocalizedString(@"All Calls", nil);
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
    
    
    UIButton *allCalls = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width / 3, 44)];
    self.allCalls = allCalls;
    [_allCalls setTitle:NSLocalizedString(@"All Calls", nil) forState:UIControlStateNormal];
    [_allCalls setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    [_allCalls setBackgroundImage:[UIImage imageNamed:@"background_highlighted"] forState:UIControlStateNormal];
    [self.view addSubview:_allCalls];
    
    UIButton *inComing = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width / 3, 0, self.view.bounds.size.width / 3, 44)];
    self.inComing = inComing;
    [_inComing setTitle:NSLocalizedString(@"Incoming", nil) forState:UIControlStateNormal];
    [_inComing setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    [self.view addSubview:_inComing];
    
    UIButton *outGoing = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width * 2 / 3, 0, self.view.bounds.size.width / 3, 44)];
    self.outGoing = outGoing;
    [_outGoing setTitle:NSLocalizedString(@"Outgoing", nil) forState:UIControlStateNormal];
    [_outGoing setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    [self.view addSubview:_outGoing];
    
    [self showAllCalls];
    
    self.table = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-108)];
    _table.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    
    [self showAllCalls];
    
    [_allCalls addTarget:self action:@selector(showAllCalls) forControlEvents:UIControlEventTouchUpInside];
    [_inComing addTarget:self action:@selector(showInComing) forControlEvents:UIControlEventTouchUpInside];
    [_outGoing addTarget:self action:@selector(showOutGoing) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(isVideoCall) name:@"VIDEOCALL" object:nil];
}

-(void)showAllCalls
{
    [_allCalls setBackgroundImage:[UIImage imageNamed:@"background_highlighted"] forState:UIControlStateNormal];
    [_inComing setBackgroundImage:[UIImage imageNamed:@"background"] forState:UIControlStateNormal];
    [_outGoing setBackgroundImage:[UIImage imageNamed:@"background"] forState:UIControlStateNormal];
    self.title = NSLocalizedString(@"All Calls", nil);
    [_inComingArray removeAllObjects];
    [_outGoingArray removeAllObjects];
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    self.allCallsArray = [base getCallingHistoryDictionary:0 andCallNumber:_number];
    //self.array = [SAMPLEEASIIOSIP getAllHistory];
    [_table reloadData];
}

-(void)showInComing
{
    [_inComing setBackgroundImage:[UIImage imageNamed:@"background_highlighted"] forState:UIControlStateNormal];
    [_allCalls setBackgroundImage:[UIImage imageNamed:@"background"] forState:UIControlStateNormal];
    [_outGoing setBackgroundImage:[UIImage imageNamed:@"background"] forState:UIControlStateNormal];
    self.title = NSLocalizedString(@"Incoming", nil);
    [_allCallsArray removeAllObjects];
    [_outGoingArray removeAllObjects];
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    self.inComingArray = [base getCallingHistoryDictionary:2 andCallNumber:_number];
    //self.array = [SAMPLEEASIIOSIP getAllHistory];
    [_table reloadData];
}

-(void)showOutGoing
{
    [_outGoing setBackgroundImage:[UIImage imageNamed:@"background_highlighted"] forState:UIControlStateNormal];
    [_inComing setBackgroundImage:[UIImage imageNamed:@"background"] forState:UIControlStateNormal];
    [_allCalls setBackgroundImage:[UIImage imageNamed:@"background"] forState:UIControlStateNormal];
    self.title = NSLocalizedString(@"Outgoing", nil);
    [_inComingArray removeAllObjects];
    [_allCallsArray removeAllObjects];
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    self.outGoingArray = [base getCallingHistoryDictionary:1 andCallNumber:_number];
    //self.array = [SAMPLEEASIIOSIP getAllHistory];
    [_table reloadData];
}

#pragma -mark   UITableViewDataSource,UITableViewDelegate
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_allCallsArray.count != 0) {
        return _allCallsArray.count;
    }else if (_inComingArray.count != 0){
        return _inComingArray.count;
    }else{
        return _outGoingArray.count;
    }
}

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
        cell.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    }
    cell.tag=indexPath.row;
    selectedBody.mIsReadyDel = _mIsReadyDel;
    [cell setContent:selectedBody];
    UILongPressGestureRecognizer * longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(cellLongPress:)];
    
    
    [cell addGestureRecognizer:longPressGesture];
    return cell;
}

- (void)isVideoCall
{
    callType = 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CallHistoryModel *selectedBody = [[CallHistoryModel alloc]init];
    if (_mIsReadyDel) {
        if (_allCallsArray.count != 0) {
            selectedBody = [_allCallsArray objectAtIndex:indexPath.row];
        }else if (_inComingArray.count != 0){
            selectedBody = [_inComingArray objectAtIndex:indexPath.row];
        }else{
            selectedBody = [_outGoingArray objectAtIndex:indexPath.row];
        }
        selectedBody.mIsSelected = !selectedBody.mIsSelected;
        [self doCHangeForSelectAllLabel];
        [_table reloadData];
        return;
    }
    NSLog(@"make call");
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    //呼叫
    int cid = 1000;
    SIPCALL_DIALOUT_DATA dialout;
    memset(&dialout, 0, sizeof(dialout));
    dialout.cid = cid;
    strcpy(dialout.remote_username, [_number UTF8String]);
    sipcall_send_msg(SIPCALL_SEND_MSG_DIALOUT, cid, 1, &dialout, sizeof(dialout));
    g_callid = cid;
    g_accountid = 1;
    
    //当前呼叫时间
    NSDateFormatter *foromatter = [[NSDateFormatter alloc]init];
    [foromatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time = [foromatter stringFromDate:[NSDate date]];
    [base insertCallingHistoryTabNumber:_number name:_name Calltime:time callType:callType callDictionary:1];
    CallingShowViewController *callingShowVC = [[CallingShowViewController alloc]init];
    callingShowVC.g_callid = cid;
    callingShowVC.g_accountid = 1;
    callingShowVC.name = _name;
    callingShowVC.number = _number;
    [self presentViewController:callingShowVC animated:YES completion:nil];
}

#pragma -mark 长按手势
- (void)cellLongPress:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (!_mIsReadyDel) {
            _mIsReadyDel = YES;
            self.navigationItem.hidesBackButton = YES;
            self.title = @"Select no items";
            if (!_mDelActionView) {
                _mDelActionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
                _mDelActionView.backgroundColor = [UIColor clearColor];
                
                //                UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
                //                line.backgroundColor = [UIColor colorWithRed:222.0f/255.0 green:222.0f/255.0 blue:224.0f/255.0 alpha:1.0f];
                //                [_mDelActionView addSubview:line];
                
                CGFloat width = (self.view.bounds.size.width - 20)/5;
                self.cancelSelectButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 22, width, 35)];
                [_cancelSelectButton addTarget:self action:@selector(doCancelDel) forControlEvents:UIControlEventTouchUpInside];
                [_cancelSelectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                _cancelSelectButton.backgroundColor = [UIColor colorWithRed:163.0f/255.0 green:217.0f/255.0 blue:241.0f/255.0 alpha:1.0f];
                //self.cancelSelectButton = imgBtn(CGRectMake(5, 19, width, 40), @"bg_btn_pressed", @"bg_btn_nor", @selector(doCancelDel), self);
                [self.cancelSelectButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
                //[self setButtonParam:self.cancelSelectButton];
                _cancelSelectButton.titleLabel.font = [UIFont systemFontOfSize:13];
                [self.cancelSelectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [_mDelActionView addSubview:self.cancelSelectButton];
                
                self.reverseSelectButton = [[UIButton alloc]initWithFrame:CGRectMake(15 + width*4, 22, width, 35)];
                [_reverseSelectButton addTarget:self action:@selector(reverseSelect:) forControlEvents:UIControlEventTouchUpInside];
                [_reverseSelectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                //self.reverseSelectButton = imgBtn(CGRectMake(15 + width*4, 19, width, 40), @"bg_btn_pressed", @"bg_btn_nor", @selector(reverseSelect:), self);
                [self.reverseSelectButton setTitle:NSLocalizedString(@"Reverse", nil) forState:UIControlStateNormal];
                //[self setButtonParam:self.reverseSelectButton];
                _reverseSelectButton.backgroundColor = [UIColor colorWithRed:253.0f/255.0 green:117.0f/255.0 blue:117.0f/255.0 alpha:1.0f];
                _reverseSelectButton.titleLabel.font = [UIFont systemFontOfSize:13];
                [self.reverseSelectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [_mDelActionView addSubview:self.reverseSelectButton];
                
                _deleteSelectButton = [[UIButton alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-50, self.view.bounds.size.width, 50)];
                [_deleteSelectButton addTarget:self action:@selector(doDeleteSelect:) forControlEvents:UIControlEventTouchUpInside];
                _deleteSelectButton.backgroundColor = [UIColor grayColor];
                [_deleteSelectButton setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
            }
            _table.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.frame.size.height-50);
            [[[UIApplication sharedApplication]keyWindow]addSubview:_mDelActionView];
            [self.view addSubview:_deleteSelectButton];
            //[self.view addSubview:_mDelActionView];
            [_table reloadData];
        }
    }
    [_table reloadData];
}


#pragma -mark 手势操作
- (void)doCancelDel
{
    NSArray *array = [NSArray array];
    array = [self getArrayContents];
    self.title = NSLocalizedString(@"All Calls", nil);
    if (_mIsReadyDel) {
        _mIsReadyDel = NO;
        for (CallHistoryModel *selectedBody in array) {
            if(selectedBody.mIsSelected){
                selectedBody.mIsSelected = NO;
            }
        }
        self.navigationItem.hidesBackButton = NO;
        [_mDelActionView removeFromSuperview];
        _table.frame = CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height);
    }
    [_mDelActionView removeFromSuperview];
    [_deleteSelectButton removeFromSuperview];
    _mDelActionView = nil;
    [_table reloadData];
}

- (void)doDeleteSelect:(UIButton *)btn
{
    NSArray *array = [NSArray array];
    NSMutableArray *mutabelArray = [NSMutableArray array];
    array = [self getArrayContents];
    for (CallHistoryModel *selectedBody in array) {
        if (selectedBody.mIsSelected) {
            [mutabelArray addObject:selectedBody.time];
        }
    }
    if (mutabelArray.count == 0) {
        [self showHUDMessage:@"You did not select records!"];
        return;
    }
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    if ([base deleteCallHistoryWithTime:mutabelArray])
    {
        _mIsReadyDel = NO;
        self.navigationItem.hidesBackButton = NO;
        [_mDelActionView removeFromSuperview];
        _table.frame = CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height);
        [_mDelActionView removeFromSuperview];
        [_deleteSelectButton removeFromSuperview];
        _mDelActionView = nil;
        [self showHUDMessage:@"Delete history record success!"];
        //删除后重新获取新的数组，刷新表格
        self.allCallsArray = [base getCallingHistoryDictionary:0 andCallNumber:_number];
        self.inComingArray = [base getCallingHistoryDictionary:1 andCallNumber:_number];
        self.outGoingArray = [base getCallingHistoryDictionary:2 andCallNumber:_number];
    }
    [_table reloadData];
}

- (void)showHUDMessage:(NSString *)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = NSLocalizedString(message, @"HUD message title");
    hud.offset = CGPointMake(0.f, 0.f);
    [hud hideAnimated:YES afterDelay:1.f];
}

- (void)reverseSelect:(UIButton *)btn
{
    NSArray *array = [NSArray array];
    array = [self getArrayContents];
    for (CallHistoryModel *selectedBody in array) {
        if(selectedBody.mIsSelected){
            selectedBody.mIsSelected = NO;
        }else{
            selectedBody.mIsSelected = YES;
        }
    }
    [self doCHangeForSelectAllLabel];
    [_table reloadData];
}

#pragma - mark ...
- (void)doCHangeForSelectAllLabel
{
    NSArray *array = [NSArray array];
    array = [self getArrayContents];
    int countYES=0;
    int countNO=0;
    for (CallHistoryModel *body in array) {
        if(body.mIsSelected){
            countYES=countYES+1;
        }else{
            countNO=countNO+1;
        }
    }
    if (_mIsReadyDel) {
        self.title = [NSString stringWithFormat:@"Select %d items",countYES];
    }
}
//数据内容
- (NSArray *)getArrayContents
{
    NSArray *array = [NSArray array];
    if (_allCallsArray.count != 0) {
        return  array = _allCallsArray;
    }else if (_inComingArray.count != 0){
        return array = _inComingArray;
    }else{
        return array = _outGoingArray;
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}


- (void)backToLastController
{
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
