//
//  AllCallsTableViewCell.h
//  VBell
//
//  Created by Jose Zhu on 16/4/12.
//  Copyright © 2016年 Jose Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CallHistoryModel;
@interface AllCallsTableViewCell : UITableViewCell
- (void)setContent;
- (void)setContent:(CallHistoryModel *)model;
@end
