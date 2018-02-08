//
//  DctcWordPreviewPopView.h
//  DictComponent
//
//  Created by syc on 2017/12/19.
//  Copyright © 2017年 ND. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SycWordPreviewPopViewDelegate <NSObject>

- (void)didSelectWordPopViewMaskView;

@end


@interface SycWordPreviewPopView : UIView

@property (nonatomic, weak) id delegate;

/**
 初始化方法

 @return self
 */
- (instancetype)initWithCenter;

/**
 初始化距离屏幕顶部的距离
 
 @param topSpace 距离屏幕顶部的距离
 @return self
 */
- (instancetype)initWithTopSpace:(CGFloat)topSpace;

/**
 更新数据和提示信息

 @param word 当前文字
 @param message 提示信息
 */
- (void)showPopWord:(NSString *)word message:(NSString *)message;

- (void)removePageView;

/**
 不带背景更新数据和提示信息
 @param word 当前文字
 @param message 提示信息
 @param pView 提示信息要显示在那个View上
 */
- (void)showWord:(NSString *)word message:(NSString *)message pageView:(UIView *)pView;
/**
 不带背景更新数据和提示信息
 */
- (void)hiddenMsgView;

@end
