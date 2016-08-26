//
//  AudioCodecViewController.m
//  VBell
//
//  Created by Jose Zhu on 16/4/11.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "AudioCodecViewController.h"
#import "VBellsqlBase.h"
#import "AudioCodecModel.h"
#import "MBProgressHUD.h"
#import "AudioAndVideoCodecCell.h"

#define contentHeight 40
@interface AudioCodecViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *audioCodecInfoArray;
@property (nonatomic, strong) UITableView *tableView;
@end



@implementation AudioCodecViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    self.title = NSLocalizedString(@"Audio Codec", nil);
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
    self.audioCodecInfoArray = [base getAudioCodecInfo];
    if (_audioCodecInfoArray.count == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"audioCodecInfo表为空!", @"HUD message title");
        hud.offset = CGPointMake(0.f, 0.f);
        [hud hideAnimated:YES afterDelay:1.f];
        [[self navigationController] popViewControllerAnimated:YES];
        return;
    }
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(15, 15, self.view.bounds.size.width - 30, 30)];
    //topView.backgroundColor = [UIColor redColor];
    
    UILabel *enableLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width * 1/4, 30)];
    enableLabel.text = NSLocalizedString(@"Enable", nil);
    [enableLabel setTextColor:UnifiedColor];
    [enableLabel setFont:[UIFont systemFontOfSize:15]];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(95, 0, self.view.bounds.size.width * 1/4, 30)];
    nameLabel.text = NSLocalizedString(@"Name", nil);
    [nameLabel setTextColor:UnifiedColor];
    [nameLabel setFont:[UIFont systemFontOfSize:15]];
    
    UILabel *payloadLabel = [[UILabel alloc]initWithFrame:CGRectMake(195, 0, self.view.bounds.size.width * 1/4, 30)];
    payloadLabel.text = NSLocalizedString(@"Payload", nil);
    [payloadLabel setTextColor:UnifiedColor];
    [payloadLabel setFont:[UIFont systemFontOfSize:15]];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 30, topView.bounds.size.width, 1)];
    [lineView setBackgroundColor:UnifiedColor];
    
    [topView addSubview:enableLabel];
    [topView addSubview:nameLabel];
    [topView addSubview:payloadLabel];
    [topView addSubview:lineView];
    [self.view addSubview:topView];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 46, self.view.bounds.size.width, 220)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.allowsSelection = NO;
    _tableView.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    [self.view addSubview:_tableView];
    
    
    UIButton *saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, 285, self.view.bounds.size.width - 30, 40)];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    saveBtn.backgroundColor = UnifiedColor;
    [saveBtn addTarget:self action:@selector(saveAudioCodec) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
    
    //tableview编辑状态
    [_tableView setEditing:YES animated:YES];
}

//- (void)setupContent:(UIView *)view name:(NSString *)name
//{
//    UIButton *enableBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, view.bounds.size.width*1/7, view.bounds.size.height)];
//    [enableBtn setImage:[UIImage imageNamed:@"new_feature_share_true"] forState:UIControlStateNormal];
//    [enableBtn setSelected:YES];
//    [enableBtn addTarget:self action:@selector(didCheck:) forControlEvents:UIControlEventTouchUpInside];
//    //enableBtn.backgroundColor = [UIColor blueColor];
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(view.bounds.size.width*2/7-20, 0, view.bounds.size.width*4/7, view.bounds.size.height)];
//    label.text = name;
//    //label.backgroundColor = [UIColor redColor];
//    UIButton *payloadBtn = [[UIButton alloc]initWithFrame:CGRectMake(view.bounds.size.width*5/7-20, 0, view.bounds.size.width*2/7, view.bounds.size.height)];
//    //payloadBtn.backgroundColor = [UIColor orangeColor];
//    [view addSubview:enableBtn];
//    [view addSubview:label];
//    [view addSubview:payloadBtn];
//}

#pragma -mark enable按钮
//- (void)didCheck:(UIButton *)btn
//{
//    if (btn.selected) {
//        [btn setSelected:NO];
//        [btn setImage:[UIImage imageNamed:@"new_feature_share_false"] forState:UIControlStateNormal];
//    }else{
//        [btn setSelected:YES];
//        [btn setImage:[UIImage imageNamed:@"new_feature_share_true"] forState:UIControlStateSelected];
//    }
//}

#pragma -mark tabelViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AudioAndVideoCodecCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identity"];
    AudioCodecModel *model = [[AudioCodecModel alloc]init];
    if (_audioCodecInfoArray.count != 0) {
        model = [_audioCodecInfoArray objectAtIndex:indexPath.row];
    }
    if (!cell) {
        cell = [[AudioAndVideoCodecCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"identity"];
    }
    cell.contentView.backgroundColor = [UIColor whiteColor];
    //cell.textLabel.text = @"1111";
    //    cell.tag=indexPath.row;
    //selectedBody.mIsReadyDel = _mIsReadyDel;
    [cell setContent:model];
//    cell.contentView.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    //UILongPressGestureRecognizer * longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(cellLongPress:)];
    
    
    //[cell addGestureRecognizer:longPressGesture];
    return cell;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _audioCodecInfoArray.count;
}

//cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

#pragma mark 选择编辑模式，添加模式很少用,默认是删除
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

#pragma mark 排序 当移动了某一行时候会调用
//编辑状态下，只要实现这个方法，就能实现拖动排序
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    // 取出要拖动的模型数据
    AudioCodecModel *model = _audioCodecInfoArray[sourceIndexPath.row];
    //删除之前行的数据
    [_audioCodecInfoArray removeObject:model];
    // 插入数据到新的位置
    [_audioCodecInfoArray insertObject:model atIndex:destinationIndexPath.row];
}


- (void)saveAudioCodec
{
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    [base deleteAudioCodecInfoTab];
    
    AudioCodecModel *model = [[AudioCodecModel alloc]init];
    if (_audioCodecInfoArray.count != 0) {
        int insertCount = 0;
        for (int i = 0; i<_audioCodecInfoArray.count; i++) {
            model = [_audioCodecInfoArray objectAtIndex:i];
            if([base insertAudioCodecInfoTab:model]){
                insertCount ++;
            }
        }
        if (insertCount == 4) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"CHANGEAUDIOCODEC" object:nil];
        }
    }
    
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)backToLastController
{
    [[self navigationController] popViewControllerAnimated:YES];
}
@end
