//
//  VideoSettingsViewController.m
//  VBell
//
//  Created by Jose Zhu on 16/4/7.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "VideoSettingsViewController.h"
#import "VBellsqlBase.h"
#import "VideoSettingsModel.h"
#import "MBProgressHUD.h"
#import "GetCurrentDevice.h"

#define labelHeight 40
#define marginHeight 10
#define showFrameViewHeight 40
#define showFrameViewLine 1


@interface VideoSettingsViewController ()<UITextFieldDelegate>

@property(nonatomic)BOOL IsShowFrameView;
@property (nonatomic , strong) UIView *showFrameView;
@property (nonatomic , strong) UIView *secondView;
@property (nonatomic , strong) UIView *thirdView;
@property (nonatomic , strong) UIView *forthView;
@property (nonatomic , strong) NSArray *IPDirectVideoResolutionArray;
@property (nonatomic , strong) NSArray *imageQualityArray;
@property (nonatomic , strong) UIButton *videoPreviewBtn;
@property (nonatomic , strong) UIButton *videoResolutionBtn;
@property (nonatomic , strong) UITextField *cachingTextField;
@property (nonatomic , strong) UIButton *nackBtn;
@property (nonatomic , strong) UIButton *tmmbrBtn;
@property (nonatomic , strong) UIButton *colorBtn;
@property (nonatomic , strong) UIButton *imageBtn;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIView *videoResolutionBackgroundView;
@property (nonatomic, strong) UIScrollView *videoResolutionScrollView;
@property (nonatomic, strong) UIView *videoResolutionViewContainer;


@end

@implementation VideoSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    self.title = NSLocalizedString(@"Video Settings", nil);
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
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, DeviceScreenWidth, DeviceScreenHeight)];
    NSString *deviceVersion = [GetCurrentDevice getCurrentDeviceModel];
    if ([[deviceVersion substringWithRange:NSMakeRange(0, 8)] isEqualToString:@"iPhone 5"]) {
        _scrollView.contentSize = CGSizeMake(DeviceScreenWidth, DeviceScreenHeight+50);
    }
    _scrollView.showsVerticalScrollIndicator = FALSE;
    _scrollView.bounces = NO;
    [self.view addSubview:_scrollView];
    
    //查询显示数据
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    NSArray *videoSettingInfoArray = [base getVideoSettingInfo];
    VideoSettingsModel *model = nil;
    if (videoSettingInfoArray.count != 0) {
        model = videoSettingInfoArray[0];
    }else{
        return;
    }
    
    //*****************1
    UIView *viewFirst = [[UIView alloc]initWithFrame:CGRectMake(15, 15, self.view.bounds.size.width - 30, 120)];
//    viewFirst.backgroundColor = [UIColor redColor];
    [self createView:viewFirst topTitle:@"Enable" firstLabelText:@"IP Direct Video Preview" secondLabelText:@"IP Direct Video Resolution"];
    //******************2
    self.secondView = [[UIView alloc]initWithFrame:CGRectMake(15, 140, self.view.bounds.size.width - 30, 70)];
//    _secondView.backgroundColor = [UIColor orangeColor];
    [self createView:_secondView topTitle:@"RTSP" labelText:@"Caching(100-5000ms)"];
    //*****************3
    self.thirdView = [[UIView alloc]initWithFrame:CGRectMake(15, 225, self.view.bounds.size.width - 30, 120)];
    //viewFirst.backgroundColor = [UIColor redColor];
    [self createView:_thirdView topTitle:@"Media Feedback" firstLabelText:@"NACK" secondLabelText:@"Tmmbr"];
    //******************4
    self.forthView = [[UIView alloc]initWithFrame:CGRectMake(15, 355, self.view.bounds.size.width - 30, 120)];
    //viewsecond.backgroundColor = [UIColor redColor];
    [self createView:_forthView topTitle:@"Other Settings" firstLabelText:@"Color Enhancement" secondLabelText:@"Image Quality"];
    
    self.videoPreviewBtn = [[UIButton alloc]initWithFrame:CGRectMake(viewFirst.bounds.size.width * 6/7+10, marginHeight+23, 30, 30)];
    self.videoResolutionBtn = [[UIButton alloc]initWithFrame:CGRectMake(viewFirst.bounds.size.width * 6/7, 2*marginHeight+25+labelHeight, 50, 30)];
//    _videoResolutionBtn.backgroundColor = [UIColor redColor];
    self.cachingTextField = [[UITextField alloc]initWithFrame:CGRectMake(_secondView.bounds.size.width*6/7-10, marginHeight+23, 50, 30)];
    _cachingTextField.text = model.caching;
    _cachingTextField.layer.cornerRadius=3.0f;
    _cachingTextField.layer.masksToBounds=YES;
    _cachingTextField.layer.borderColor=[[UIColor orangeColor]CGColor];
    _cachingTextField.layer.borderWidth= 1.0f;
    _cachingTextField.keyboardType = UIKeyboardTypeNumberPad;
    _cachingTextField.delegate = self;
//    [_cachingTextField becomeFirstResponder];
    self.nackBtn = [[UIButton alloc]initWithFrame:CGRectMake(_thirdView.bounds.size.width * 6/7+10, marginHeight+23, 30 , 30)];
    self.tmmbrBtn = [[UIButton alloc]initWithFrame:CGRectMake(_thirdView.bounds.size.width * 6/7+10, 2*marginHeight+23+labelHeight, 30 , 30)];
    self.colorBtn = [[UIButton alloc]initWithFrame:CGRectMake(_forthView.bounds.size.width * 6/7+10, marginHeight+23, 30, 30)];
    self.imageBtn = [[UIButton alloc]initWithFrame:CGRectMake(_forthView.bounds.size.width * 6/7 , 2*marginHeight+25+labelHeight, 50 , 30)];
//    _imageBtn.backgroundColor = [UIColor redColor];
    if (model.video_Preview == 1) {
        [_videoPreviewBtn setImage:[UIImage imageNamed:@"choose.png"] forState:UIControlStateNormal];
        [_videoPreviewBtn setSelected:YES];
    }else{
        [_videoPreviewBtn setImage:[UIImage imageNamed:@"chooseNot.png"] forState:UIControlStateNormal];
        [_videoPreviewBtn setSelected:NO];
    }
    if (model.nACK == 1) {
        [_nackBtn setImage:[UIImage imageNamed:@"choose.png"] forState:UIControlStateNormal];
        [_nackBtn setSelected:YES];
    }else{
        [_nackBtn setImage:[UIImage imageNamed:@"chooseNot.png"] forState:UIControlStateNormal];
        [_nackBtn setSelected:NO];
    }
    if (model.tMMBR == 1) {
        [_tmmbrBtn setImage:[UIImage imageNamed:@"choose.png"] forState:UIControlStateNormal];
        [_tmmbrBtn setSelected:YES];
    }else{
        [_tmmbrBtn setImage:[UIImage imageNamed:@"chooseNot.png"] forState:UIControlStateNormal];
        [_tmmbrBtn setSelected:NO];
    }
    if (model.color_Enhancement == 1) {
        [_colorBtn setImage:[UIImage imageNamed:@"choose.png"] forState:UIControlStateNormal];
        [_colorBtn setSelected:YES];
    }else{
        [_colorBtn setImage:[UIImage imageNamed:@"chooseNot.png"] forState:UIControlStateNormal];
        [_colorBtn setSelected:NO];
    }
    
    [_videoResolutionBtn setTitle:model.video_Resolution forState:UIControlStateNormal];
    _videoResolutionBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_videoResolutionBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [_imageBtn setTitle:NSLocalizedString(model.image_Quality, nil) forState:UIControlStateNormal];
    _imageBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_imageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [_videoPreviewBtn addTarget:self action:@selector(didCheck:) forControlEvents:UIControlEventTouchUpInside];
    [_videoResolutionBtn addTarget:self action:@selector(chooseVideoResolution) forControlEvents:UIControlEventTouchUpInside];
    [_nackBtn addTarget:self action:@selector(didCheck:) forControlEvents:UIControlEventTouchUpInside];
    [_tmmbrBtn addTarget:self action:@selector(didCheck:) forControlEvents:UIControlEventTouchUpInside];
    [_colorBtn addTarget:self action:@selector(didCheck:) forControlEvents:UIControlEventTouchUpInside];
    [_imageBtn addTarget:self action:@selector(chooseImageQuality) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnSave = [[UIButton alloc]initWithFrame:CGRectMake(15, 500, self.view.bounds.size.width - 30, 40)];
    btnSave.backgroundColor = UnifiedColor;
    [btnSave setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [btnSave addTarget:self action:@selector(saveTosqlite) forControlEvents:UIControlEventTouchUpInside];
    
    [viewFirst addSubview:_videoPreviewBtn];
    [viewFirst addSubview:_videoResolutionBtn];
    [_secondView addSubview:_cachingTextField];
    [_thirdView addSubview:_nackBtn];
    [_thirdView addSubview:_tmmbrBtn];
    [_forthView addSubview:_colorBtn];
    [_forthView addSubview:_imageBtn];
    [_scrollView addSubview:viewFirst];
    [_scrollView addSubview:_secondView];
    [_scrollView addSubview:_thirdView];
    [_scrollView addSubview:_forthView];
    [_scrollView addSubview:btnSave];
}

- (void)createView:(UIView *)view topTitle:(NSString *)title firstLabelText:(NSString *)firstText secondLabelText:(NSString *)secondText
{
    UIButton *blueDot = [[UIButton alloc]initWithFrame:CGRectMake(0, 5, 5, 5)];
    blueDot.backgroundColor = UnifiedColor;
    blueDot.layer.cornerRadius = blueDot.frame.size.height/2;
    blueDot.layer.masksToBounds = YES;
    UILabel *TopLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, self.view.bounds.size.width, 20)];
    TopLabel.text = NSLocalizedString(title, nil);
    [TopLabel setTextColor:UnifiedColor];
    UIView *firstViewLine = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width - 30, 3)];
    firstViewLine.backgroundColor = UnifiedColor;
    UILabel *firstlabel = [[UILabel alloc]initWithFrame:CGRectMake(0, marginHeight+TopLabel.bounds.size.height+3, view.bounds.size.width * 6/7, labelHeight)];
    //firstlabel.backgroundColor = [UIColor purpleColor];
    firstlabel.text = NSLocalizedString(firstText, nil);
    UILabel *secondlabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 2*marginHeight+TopLabel.bounds.size.height+3+labelHeight, view.bounds.size.width * 6/7, labelHeight)];
    //secondlabel.backgroundColor = [UIColor blueColor];
    secondlabel.text = NSLocalizedString(secondText, nil);
    [view addSubview:blueDot];
    [view addSubview:firstlabel];
    [view addSubview:TopLabel];
    [view addSubview:firstViewLine];
    [view addSubview:secondlabel];

}

- (void)createView:(UIView *)view topTitle:(NSString *)title labelText:(NSString *)labelText
{
    UIButton *blueDot = [[UIButton alloc]initWithFrame:CGRectMake(0, 5, 5, 5)];
    blueDot.backgroundColor = UnifiedColor;
    blueDot.layer.cornerRadius = blueDot.frame.size.height/2;
    blueDot.layer.masksToBounds = YES;
    UILabel *TopLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, self.view.bounds.size.width, 20)];
    TopLabel.text = NSLocalizedString(title, nil);
    [TopLabel setTextColor:UnifiedColor];
    UIView *firstViewLine = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width - 30, 3)];
    firstViewLine.backgroundColor = UnifiedColor;
    UILabel *firstlabel = [[UILabel alloc]initWithFrame:CGRectMake(0, marginHeight+TopLabel.bounds.size.height+3, view.bounds.size.width * 6/7, labelHeight)];
    firstlabel.text = NSLocalizedString(labelText, nil);
    [view addSubview:blueDot];
    [view addSubview:firstlabel];
    [view addSubview:TopLabel];
    [view addSubview:firstViewLine];
    
}

- (void)didCheck:(UIButton *)btn
{
    if (btn.selected) {
        [btn setSelected:NO];
        [btn setImage:[UIImage imageNamed:@"chooseNot.png"] forState:UIControlStateNormal];
    }else{
        [btn setSelected:YES];
        [btn setImage:[UIImage imageNamed:@"choose.png"] forState:UIControlStateSelected];
    }
}

- (void)chooseVideoResolution
{
    _videoResolutionBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height+64)];
    _videoResolutionBackgroundView.alpha = 0.7;
    _videoResolutionBackgroundView.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication].keyWindow addSubview:_videoResolutionBackgroundView];
    
    _videoResolutionScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height)];
    [[UIApplication sharedApplication].keyWindow addSubview:_videoResolutionScrollView];
    
    //添加点击手势
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    recognizer.numberOfTouchesRequired = 1;
    [_videoResolutionScrollView addGestureRecognizer:recognizer];
    
    _videoResolutionViewContainer = [[UIView alloc]initWithFrame:CGRectMake(15, self.view.bounds.size.height /2-self.view.bounds.size.height *1/5, self.view.bounds.size.width - 30, 204)];
    _videoResolutionViewContainer.backgroundColor = [UIColor whiteColor];
    _videoResolutionViewContainer.layer.cornerRadius = 1.0f;

    CGFloat videoResolutionViewContainerwidth = _videoResolutionViewContainer.bounds.size.width;
    
    [_videoResolutionScrollView addSubview:_videoResolutionViewContainer];

    self.IPDirectVideoResolutionArray = [NSArray arrayWithObjects:@"QCIF",@"CIF",@"VGA",@"4CIF",@"720P", nil];
    for (int i = 0; i < _IPDirectVideoResolutionArray.count; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, i*(showFrameViewHeight+1), videoResolutionViewContainerwidth, showFrameViewHeight)];
        [btn setTitle:_IPDirectVideoResolutionArray[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.tag = i;
        [btn addTarget:self action:@selector(IPChooseClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, (i+1)*showFrameViewHeight+i, videoResolutionViewContainerwidth, 1)];
        lineView.backgroundColor = [UIColor grayColor];
        
        [_videoResolutionViewContainer addSubview:btn];
        [_videoResolutionViewContainer addSubview:lineView];
    }

}

- (void)chooseImageQuality
{
    _videoResolutionBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height+64)];
    _videoResolutionBackgroundView.alpha = 0.7;
    _videoResolutionBackgroundView.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication].keyWindow addSubview:_videoResolutionBackgroundView];
    
    _videoResolutionScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height)];
    [[UIApplication sharedApplication].keyWindow addSubview:_videoResolutionScrollView];
    
    //添加点击手势
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    recognizer.delegate = self;
    recognizer.numberOfTouchesRequired = 1;
    [_videoResolutionScrollView addGestureRecognizer:recognizer];
    
    _videoResolutionViewContainer = [[UIView alloc]initWithFrame:CGRectMake(15, self.view.bounds.size.height /2-self.view.bounds.size.height *1/5, self.view.bounds.size.width - 30, 122)];
    _videoResolutionViewContainer.backgroundColor = [UIColor whiteColor];
    _videoResolutionViewContainer.layer.cornerRadius = 1.0f;
    
    CGFloat videoResolutionViewContainerwidth = _videoResolutionViewContainer.bounds.size.width;
    
    [_videoResolutionScrollView addSubview:_videoResolutionViewContainer];
    
    self.imageQualityArray = [NSArray arrayWithObjects:@"Low",@"Middle",@"High",nil];
    for (int i = 0; i < _imageQualityArray.count; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, i*(showFrameViewHeight+1), videoResolutionViewContainerwidth, showFrameViewHeight)];
        [btn setTitle:NSLocalizedString(_imageQualityArray[i], nil) forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.tag = i;
        [btn addTarget:self action:@selector(imageChooseClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, (i+1)*showFrameViewHeight+i, videoResolutionViewContainerwidth, 1)];
        lineView.backgroundColor = [UIColor grayColor];
        
        [_videoResolutionViewContainer addSubview:btn];
        [_videoResolutionViewContainer addSubview:lineView];
    }
    
}

-(void)singleTap:(UITapGestureRecognizer*)recognizer
{
    [_videoResolutionBackgroundView removeFromSuperview];
    [_videoResolutionScrollView removeFromSuperview];
}

- (void)IPChooseClick:(UIButton *)btn
{
    NSString *imageQuality = [_IPDirectVideoResolutionArray objectAtIndex:btn.tag];
    [_videoResolutionBtn setTitle:imageQuality forState:UIControlStateNormal];
    _IsShowFrameView = NO;
    [_videoResolutionBackgroundView removeFromSuperview];
    [_videoResolutionScrollView removeFromSuperview];
}

- (void)imageChooseClick:(UIButton *)btn
{
    NSString *imageQuality = [_imageQualityArray objectAtIndex:btn.tag];
    [_imageBtn setTitle:imageQuality forState:UIControlStateNormal];
    _IsShowFrameView = NO;
    [_videoResolutionBackgroundView removeFromSuperview];
    [_videoResolutionScrollView removeFromSuperview];
}

#pragma mark 保存
- (void)saveTosqlite
{
    NSString *video_resolution = _videoResolutionBtn.titleLabel.text;
    NSString *caching = _cachingTextField.text;
    NSString *image_quality = _imageBtn.titleLabel.text;
    int video_Preview = 0, nack = 0,tmmbr = 0,color_enhancement= 0 ;
    VBellsqlBase *base = [VBellsqlBase shareMyDdataBase];
    video_Preview = _videoPreviewBtn.selected?1:0;
    nack = _nackBtn.selected?1:0;
    tmmbr = _tmmbrBtn.selected?1:0;
    color_enhancement = _colorBtn.selected?1:0;
    if ([base updateVideoPreview:video_Preview video_Resolution:video_resolution caching:caching nack:nack tmmbr:tmmbr color_Enhancement:color_enhancement image_Quality:image_quality]) {
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

#pragma mark - UITextFieldDelegate 只能输入数字
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [self validateNumber:string];
}

- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

- (void)backToLastController
{
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
