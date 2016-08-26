//
//  AllCallsViewController.m
//  VBell
//
//  Created by Jose Zhu on 16/4/7.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "AllCallsViewController.h"
#import "AllCallsTableViewCell.h"
#import "VBellsqlBase.h"
#import "CallHistoryModel.h"
#import "MBProgressHUD.h"

@interface AllCallsViewController ()<UITableViewDataSource,UITableViewDelegate>

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


@end

@implementation AllCallsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_table reloadData];
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    self.title = NSLocalizedString(@"All Calls", nil);
    self.navigationController.navigationBar.translucent = NO;
    UIColor * color = [UIColor whiteColor];
    NSDictionary * dict = [NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    
    UIButton *allCalls = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width / 3, 44)];
    self.allCalls = allCalls;
    [_allCalls setTitle:NSLocalizedString(@"All Calls", nil) forState:UIControlStateNormal];
    [_allCalls setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    [_allCalls setBackgroundImage:[UIImage imageNamed:@"goback.png"] forState:UIControlStateNormal];
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

    [_allCalls addTarget:self action:@selector(showAllCalls) forControlEvents:UIControlEventTouchUpInside];
    [_inComing addTarget:self action:@selector(showInComing) forControlEvents:UIControlEventTouchUpInside];
    [_outGoing addTarget:self action:@selector(showOutGoing) forControlEvents:UIControlEventTouchUpInside];
    
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
    [cell setContent:selectedBody];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CallHistoryModel *selectedBody = [[CallHistoryModel alloc]init];

    if (_allCallsArray.count != 0) {
        selectedBody = [_allCallsArray objectAtIndex:indexPath.row];
    }else if (_inComingArray.count != 0){
        selectedBody = [_inComingArray objectAtIndex:indexPath.row];
    }else{
        selectedBody = [_outGoingArray objectAtIndex:indexPath.row];
    }
    selectedBody.mIsSelected = !selectedBody.mIsSelected;
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





- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


@end
