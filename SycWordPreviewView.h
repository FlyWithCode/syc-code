//
//  SycWordPreviewView.h
//  DictComponent
//
//  Created by syc on 2017/12/1.
//  Copyright © 2017年 ND. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DctcWordPreviewTableViewCell.h"
#import "DCTSCrossSearchModel.h"


typedef NS_ENUM(NSUInteger, SycWordPreviewViewType) {
    SycWordPreviewViewTypeDefault = 0,                //  默认类型
    SycWordPreviewViewTypeWywCarmer = 1,              //  文言文摄像头取字
};

@protocol SycWordPreviewViewDelegate <NSObject>

- (void)didSelectRowWithModel:(DCTSCrossSearchModel *)model;

- (void)didSelectMaskView;

@end

@interface SycWordPreviewView : UIView

@property (nonatomic, weak) id delegate;

@property (nonatomic, assign) SycWordPreviewViewType type;

- (void)updateData:(NSArray *)data ;


/**
 初始化距离屏幕顶部的距离

 @param topSpace 距离屏幕顶部的距离
 @return self
 */
- (instancetype)initWithTopSpace:(CGFloat)topSpace;


/**
 初始化居中视图

 @return self
 */
- (instancetype)initWithCenter;
/**
 添加视图
 */
- (void)addPageViewWithParentVC:(UIViewController *)parventVC;

/**
 显示不带背景弹窗
 */
- (void)showPageView:(UIView *)pView;
/**
 隐藏不带背景弹窗
 */
- (void)hiddenPageView;

/**
 移除视图
 */
- (void)removePageView;

/**
 该方法会重置之前的设置模式，以当前传入的topSpace 来布局视图。
 @param topSpace 距离屏幕顶部的距离
 */
- (void)reSetTopSapce:(CGFloat)topSpace;
@end
