//
//  AccountGroupsModel.h
//  VBell
//
//  Created by Jose Zhu on 16/4/26.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountGroupsModel : NSObject
/**注册名*/
@property (nonatomic, strong) NSString *registerName;
/**用户名*/
@property (nonatomic, strong) NSString *userName;
/**密码*/
@property (nonatomic, strong) NSString *password;
/**显示名*/
@property (nonatomic, strong) NSString *displayName;
/**服务器*/
@property (nonatomic, strong) NSString *serverURL;
/**服务器端口*/
@property (nonatomic, strong) NSString *serverPort;
/**代理服务器*/
@property (nonatomic, strong) NSString *proxyServerURL;
/**代理服务器端口*/
@property (nonatomic, strong) NSString *proxyServerPort;
@end
