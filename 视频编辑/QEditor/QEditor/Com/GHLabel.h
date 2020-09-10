//
//  GHLabel.h
//  LLabel
//
//  Created by 李国怀 on 2016/9/7.
//  Copyright © 2016年 李国怀. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GHLabel;

typedef void(^TaphandleBlock)(GHLabel *label, NSString *selectStr, NSRange range);

@interface GHLabel : UILabel
@property (nonatomic,   copy) TaphandleBlock linkTapHandle;//链接回调Blcock
@property (nonatomic,   copy) TaphandleBlock userTaphandle;//用户回调Block
@property (nonatomic, strong) UIColor *attrStrColor;//设置特殊字符颜色，默认为蓝色
@end
