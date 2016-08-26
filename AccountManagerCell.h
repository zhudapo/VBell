//
//  AccountManagerCell.h
//  VBell
//
//  Created by Jose Zhu on 16/4/26.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountManagerCell : UITableViewCell
@property (nonatomic, strong) UISwitch *switchOnline;
- (void)setContent:(NSString *)username loginStatus:(BOOL)loginstauts UISwitchStatus:(BOOL)UISwitchStatus;
@end
