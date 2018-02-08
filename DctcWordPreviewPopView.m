//
//  DctcWordPreviewPopView.m
//  DictComponent
//
//  Created by syc on 2017/12/19.
//  Copyright © 2017年 ND. All rights reserved.
//
#import <Masonry/Masonry.h>
#import <libextobjc/EXTScope.h>
#import "UIColor+Extension.h"
#import "DctcFontUtil.h"
#import "UILabel+Html.h"
#import "DictComponentHelper.h"
#import "DctcConfig.h"
#import "DctcCommonDefine.h"
#import "DctcWordPreviewPopView.h"

@interface DctcWordPreviewPopView ()
@property (nonatomic, strong) UILabel *wordLable;
@property (nonatomic, strong) UILabel *showMessageLable;

@property (nonatomic, strong) UIControl *dctcMaskView;
@property (nonatomic, assign) BOOL isAddSubView;
@property (nonatomic, assign) BOOL isShowMsg;
@property (nonatomic, assign) CGFloat topSpace;

@end


@implementation DctcWordPreviewPopView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubPageView];
        [self layOutPageView];
    }
    return self;
}

#pragma mark - public methond

- (instancetype)initWithTopSpace:(CGFloat)topSpace {
    _topSpace = topSpace;
    CGRect frame = CGRectMake((SCREEN_WIDTH-640*kScale)/2, topSpace, 640*kScale, 260*kScale);
    return  [self initWithFrame:frame];
}

- (instancetype)initWithCenter {
    CGRect frame = CGRectMake((SCREEN_WIDTH-640*kScale)/2, (SCREEN_HEIGHT - 260*kScale)/2, 640*kScale, 260*kScale);
    return  [self initWithFrame:frame];
}

- (void)showPopWord:(NSString *)word message:(NSString *)message {
    [self addPageView];
    [self setHtmlStrWithFont:[UIFont systemFontOfSize:15.0] color:[UIColor colorWithHexString:@"#333333"] text:word lable:self.wordLable];
    self.showMessageLable.text = message;
}

- (void)addPageView {
    if (_isAddSubView) {
        return;
    }
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.dctcMaskView];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    _isAddSubView = YES;
}

- (void)removePageView {
    if (!_isAddSubView) {
        return;
    }
    _isAddSubView = NO;
    [self removeFromSuperview];
    [self.dctcMaskView removeFromSuperview];
}

/**
 不带背景更新数据和提示信息
 @param word 当前文字
 @param message 提示信息
 */
- (void)showWord:(NSString *)word message:(NSString *)message pageView:(UIView *)pView {
    if (!_isShowMsg) {
        [pView addSubview:self];
        _isShowMsg = YES;
    }
    [self setHtmlStrWithFont:[UIFont systemFontOfSize:15.0] color:[UIColor colorWithHexString:@"#333333"] text:word lable:self.wordLable];
    self.showMessageLable.text = message;
}
/**
 不带背景更新数据和提示信息
 */
- (void)hiddenMsgView {
    if (_isShowMsg) {
        _isShowMsg = NO;
        [self removeFromSuperview];
    }
}


#pragma mark - pravite methond

- (void)addSubPageView {
    self.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    [self addSubview:self.wordLable];
    [self addSubview:self.showMessageLable];
}

- (void)layOutPageView {
    @weakify(self);
    [self.wordLable mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top).offset(76*kScale);
    }];
    [self.showMessageLable mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.leading.trailing.equalTo(self);
        make.bottom.equalTo(self.mas_bottom).offset(-50*kScale);
    }];
}
- (void)setHtmlStrWithFont:(UIFont *)font
                     color:(UIColor *)color
                      text:(NSString *)text
                     lable:(UILabel *)lable {
    text = text ? text : @"";
    NSDictionary *textDic = @{
                              NSFontAttributeName:font,
                              NSForegroundColorAttributeName:color,
                              };
    NSMutableAttributedString *keyMultStr = [lable setHtmlWithString:text imgeX:0 imgeY:-3];
    [keyMultStr addAttributes:textDic range:NSMakeRange(0, keyMultStr.length)];
    lable.attributedText = keyMultStr;

}

#pragma mark - tappaperMaskViewAction
- (void)tappaperMaskViewAction {
    [self removePageView];
    if ([_delegate respondsToSelector:@selector(didSelectWordPopViewMaskView)]) {
        [_delegate didSelectWordPopViewMaskView];
    }
}

#pragma mark - getter & setter

- (UILabel *)wordLable {
    if (!_wordLable) {
        _wordLable = [[UILabel alloc]init];
        _wordLable.font = [UIFont systemFontOfSize:15];
        _wordLable.textColor = [UIColor colorWithHexString:@"#333333"];
        _wordLable.textAlignment = NSTextAlignmentCenter;
        [_wordLable sizeToFit];
    }
    return _wordLable;
}

- (UILabel *)showMessageLable {
    if (!_showMessageLable) {
        _showMessageLable = [[UILabel alloc]init];
        _showMessageLable.font = [UIFont systemFontOfSize:15];
        _showMessageLable.textColor = [UIColor colorWithHexString:@"#999999"];
        _showMessageLable.textAlignment = NSTextAlignmentCenter;
        [_showMessageLable sizeToFit];
    }
    return _showMessageLable;
}

- (UIControl *)dctcMaskView {
    if (!_dctcMaskView) {
        _dctcMaskView = [[UIControl alloc]initWithFrame:CGRectMake(0,0,SCREEN_WIDTH , SCREEN_HEIGHT)];
        [_dctcMaskView addTarget:self action:@selector(tappaperMaskViewAction) forControlEvents:UIControlEventTouchUpInside];
        _dctcMaskView.backgroundColor = [UIColor blackColor];
        _dctcMaskView.alpha = 0.5f;
        _dctcMaskView.userInteractionEnabled = YES;
        _dctcMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
    }
    return _dctcMaskView;
}

@end
