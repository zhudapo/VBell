//
//  ExprotLogViewController.m
//  VBell
//
//  Created by Jose Zhu on 16/4/7.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import "ExprotLogViewController.h"


@interface ExprotLogViewController ()
@property (nonatomic, strong) UITextField *serverUrl;
@end

@implementation ExprotLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建一个UIButton
    UIButton *leftMenuButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    //设置UIButton的图像
    [leftMenuButton setImage:[UIImage imageNamed:@"goback.png"] forState:UIControlStateNormal];
    //给UIButton绑定一个方法，在这个方法中进行popViewControllerAnimated
    [leftMenuButton addTarget:self action:@selector(backToLastController) forControlEvents:UIControlEventTouchUpInside];
    //然后通过系统给的自定义BarButtonItem的方法创建BarButtonItem
    UIBarButtonItem *leftMenu = [[UIBarButtonItem alloc]initWithCustomView:leftMenuButton];
    self.navigationItem.leftBarButtonItem = leftMenu;
    
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    self.title = NSLocalizedString(@"Export Log", nil);
    self.navigationController.navigationBar.translucent = NO;
    
    
    UIButton *btnSendLog = [[UIButton alloc]initWithFrame:CGRectMake(15, 93, self.view.bounds.size.width - 30, 40)];
    btnSendLog.backgroundColor = UnifiedColor;
    [btnSendLog setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [btnSendLog addTarget:self action:@selector(sendLog) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSendLog];
}

- (void)sendLog
{
    NSLog(@"sendLog");
    NSLog(@"OK");
    //    [self redirectNSLogToDocumentFolder];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"logDirectory"];
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:logDirectory error:nil];
    NSString *filePath = [logDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@",[files lastObject]]];
    
    // 1.创建url  采用Apache本地服务器
    NSString *urlString = @"http://syslog.akuvox.com/ios/";
    //    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 2.创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // 文件上传使用post
    request.HTTPMethod = @"POST";
    
    [[[NSURLSession sharedSession] uploadTaskWithRequest:request fromData:[NSData dataWithContentsOfFile:filePath] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSLog(@"upload success：%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        } else {
            NSLog(@"upload error:%@",error);
        }
    }] resume];
    
    
//    [[eioRestfulAPI shareRestfulAPI] sendSuggestion:self.contentTextView.text filePath:filePath callback:^(NSDictionary *response, NSError *error) {
//        if (error) {
//            NSLog(@"error %@",error);
//        }else{
//            NSLog(@"response %@",response);
//        }
//    }];
//    
//    [self removeFromSuperview];
}

- (void)backToLastController
{
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
