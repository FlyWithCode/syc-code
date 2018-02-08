//
//  DctcWordPreviewTableViewCell.m
//  DictComponent
//
//  Created by syc on 2017/12/1.
//  Copyright © 2017年 ND. All rights reserved.
//

#import "DctcWordPreviewTableViewCell.h"
#import <Masonry/Masonry.h>
#import <libextobjc/EXTScope.h>
#import "UIColor+Extension.h"
#import "DctcFontUtil.h"
#import "DictComponentHelper.h"
#import "DctcConfig.h"
#import "UILabel+Html.h"
#import "DctcCommonDefine.h"
#import "DctcWordDetailJSBridgeViewModel.h"

@interface DctcWordPreviewTableViewCell ()

@property (nonatomic, strong) UILabel *pinYinLable;
@property (nonatomic, strong) UILabel *wordLable;

@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, strong) UIButton *voiceButton;

@property (nonatomic, strong) UIButton *collectButton;
@property (nonatomic, strong) UIImageView *arrowImageView;

@property (nonatomic, strong) UILabel *typeLable;
@property (nonatomic, strong) UIView *traditionalView;//繁体字视图
@property (nonatomic, strong) UILabel *traditionalLable;

@property (nonatomic, strong) UIImageView *line;

@end
@implementation DctcWordPreviewTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifie{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifie]) {
        [self configUI];
    }
    return self;
}

+ (NSString*)indentify {
    return @"DctcWordPreviewTableViewCell";
}


- (void)upateDateWithData:(DCTSCrossSearchModel *)model {
    if ([[DctcConfig getCurrentDictId]isEqualToString:WEN_YAN_WEN]) {
        if ((model.traditionalFont.length > 0 || model.xuci) ) {
            @weakify(self);
            if (model.traditionalFont.length > 0 && model.xuci) {//繁体+虚词
                self.traditionalView.hidden = NO;
                self.typeLable.hidden = NO;
                
                self.traditionalLable.text = model.traditionalFont;
                CGSize size = [model.traditionalFont sizeWithAttributes:@{NSFontAttributeName:[DctcFontUtil spellFontWithSize:15],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#fa8b2d"]}];
                [self.traditionalView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(self.pinYinLable.mas_trailing).mas_offset(24*kScale);
                    make.centerY.equalTo(self.pinYinLable);
                    make.width.mas_equalTo(size.width+13+13+12+6);
                    make.height.mas_equalTo(14);
                }];
                
                [self.typeLable mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(self.traditionalView.mas_trailing).mas_offset(12*kScale);
                    make.centerY.equalTo(self.pinYinLable);
                    make.size.mas_equalTo(CGSizeMake(24, 12));
                }];
                
                [self.collectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                    @strongify(self);
                    make.leading.equalTo(self.typeLable.mas_trailing).offset(52*kScale);
                    make.top.equalTo(self.centerView.mas_top);
                    make.size.mas_equalTo(CGSizeMake(54*0.5, 54*0.5));
                }];
                
            }else if (model.traditionalFont.length >0 && !model.xuci) {//繁体
                self.traditionalView.hidden = NO;
                self.typeLable.hidden = YES;
                self.traditionalLable.text = model.traditionalFont;
                CGSize size = [model.traditionalFont sizeWithAttributes:@{NSFontAttributeName:[DctcFontUtil spellFontWithSize:15],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#fa8b2d"]}];
                [self.traditionalView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(self.pinYinLable.mas_trailing).mas_offset(24*kScale);
                    make.centerY.equalTo(self.pinYinLable);
                    make.width.mas_equalTo(size.width+13+13+12+6);
                    make.height.mas_equalTo(14);
                }];
                [self.collectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                    @strongify(self);
                    make.leading.equalTo(self.traditionalView.mas_trailing).offset(106*kScale);
                    make.top.equalTo(self.centerView.mas_top);
                    make.size.mas_equalTo(CGSizeMake(54*0.5, 54*0.5));
                }];
            }else if (model.traditionalFont.length <= 0 && model.xuci) {//虚词
                self.traditionalView.hidden = YES;
                self.typeLable.hidden = NO;
                [self.typeLable mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(self.pinYinLable.mas_trailing).mas_offset(24*kScale);
                    make.centerY.equalTo(self.pinYinLable);
                    make.size.mas_equalTo(CGSizeMake(24, 12));
                }];
                
                [self.collectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                    @strongify(self);
                    make.leading.equalTo(self.typeLable.mas_trailing).offset(106*kScale);
                    make.top.equalTo(self.centerView.mas_top);
                    make.size.mas_equalTo(CGSizeMake(54*0.5, 54*0.5));
                }];
            }else {
                self.traditionalView.hidden = YES;
                self.typeLable.hidden = YES;
            }
        }
        [self reloadDeafaultData:model];
    }else {
        [self reloadDeafaultData:model];
    }
}

- (void)reloadDeafaultData:(DCTSCrossSearchModel *)model {
    //默认模式
    [self setHtmlStrWithFont:[DctcFontUtil kaiFontWithSize:17] color:[UIColor colorWithHexString:@"#333333"] text:model.spell lable:self.pinYinLable];
    
    [self setHtmlStrWithFont:[DctcFontUtil spellFontWithSize:16] color:[UIColor colorWithHexString:@"#333333"] text:model.explain lable:self.wordLable];
    NSString *sourceId = [[DctcWordDetailJSBridgeViewModel instance] getSourceIdWithWordId:model.wordId spell:model.spell];
    if (model.favId.length > 0 && [sourceId isEqualToString:model.sourceId]) {
        [self changeCollectButtonState:YES];
    }else {
        [self changeCollectButtonState:NO];
    }
}


- (void)changeCollectButtonState:(BOOL)isCollect {
    if (isCollect) {
        [self.collectButton setImage:[DictComponentHelper imageNamed:@"dict_preview_collected_seleted"] forState:UIControlStateNormal];
    }else {
        [self.collectButton setImage:[DictComponentHelper imageNamed:@"dict_preview_collecte_normal"] forState:UIControlStateNormal];
    }
}

#pragma mark - pravite

- (void)configUI {
    self.contentView.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    [self.contentView addSubview:self.centerView];
    

    [self.centerView addSubview:self.voiceButton];
    [self.centerView addSubview:self.voiceImageView];
    [self.centerView addSubview:self.pinYinLable];
    
    [self.centerView addSubview:self.traditionalView];//繁体
    [self.centerView addSubview:self.typeLable];//虚词
    
    [self.centerView addSubview:self.collectButton];
    
    [self.centerView addSubview:self.wordLable];
    [self.contentView addSubview:self.arrowImageView];
    [self.contentView addSubview:self.line];
   

    @weakify(self);
    
    [self.centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.leading.equalTo(self.contentView.mas_leading).offset(40*kScale);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-70*kScale);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    [self.voiceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.leading.equalTo(self.centerView.mas_leading);
        make.top.equalTo(self.centerView.mas_top).offset(2);
        make.size.mas_equalTo(CGSizeMake(41*0.5, 37*0.5));
    }];
    [self.voiceButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.voiceImageView);
    }];
    
    [self.pinYinLable mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.leading.equalTo(self.voiceButton.mas_trailing).offset(24*kScale);
        make.top.equalTo(self.voiceImageView.mas_top);
    }];

    [self.collectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.leading.equalTo(self.pinYinLable.mas_trailing).offset(56*kScale);
        make.top.equalTo(self.centerView.mas_top);
        make.size.mas_equalTo(CGSizeMake(54*0.5, 54*0.5));
    }];
    
    [self.wordLable mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.leading.equalTo(self.centerView.mas_leading);
        make.trailing.equalTo(self.centerView.mas_trailing);
        make.top.equalTo(self.collectButton.mas_bottom).offset(25*kScale);
        make.bottom.equalTo(self.centerView.mas_bottom);
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-40*kScale);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(13*kScale, 23*kScale));
    }];
    
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.trailing.leading.equalTo(self.contentView);
        make.height.mas_equalTo(0.5);
        make.bottom.equalTo(self.contentView.mas_bottom);
    }];
    
}


- (void)playVoice {
    MUPLogDebug(@"playVoice");
    if ([_delegate respondsToSelector:@selector(didSelectedVoiceAction:)]) {
        [_delegate didSelectedVoiceAction:self];
    }
}

- (void)collectAction:(UIButton *)button {
    MUPLogDebug(@"collectAction");
    if ([_delegate respondsToSelector:@selector(didSelectedCollectAction:)]) {
        [_delegate didSelectedCollectAction:self];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
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

- (void)hideLine:(BOOL)hide {
    if (hide) {
        self.line.hidden = YES;
    }else {
        self.line.hidden = NO;
    }
}

#pragma mark - getter & setter

- (UILabel *)pinYinLable {
    if (!_pinYinLable) {
        _pinYinLable = [[UILabel alloc]init];
        _pinYinLable.font = [DctcFontUtil kaiFontWithSize:17];
        _pinYinLable.textColor = [UIColor colorWithHexString:@"#333333"];
        _pinYinLable.textAlignment = NSTextAlignmentCenter;
        [_pinYinLable sizeToFit];
    }
    return _pinYinLable;
}

- (UILabel *)wordLable {
    if (!_wordLable) {
        _wordLable = [[UILabel alloc]init];
        _wordLable.font = [DctcFontUtil spellFontWithSize:16];
        _wordLable.textColor = [UIColor colorWithHexString:@"#333333"];
        _wordLable.textAlignment = NSTextAlignmentLeft;
        [_wordLable sizeToFit];
    }
    return _wordLable;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc]init];
        _arrowImageView.image = [DictComponentHelper imageNamed:@"dict_preview_arrow_icon_normal"];
    }
    return _arrowImageView;
}

- (UIButton *)voiceButton {
    if (!_voiceButton) {
        _voiceButton = [[UIButton alloc]init];
        [_voiceButton addTarget:self action:@selector(playVoice) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceButton;
}

- (UIImageView *)voiceImageView {//语言播放视图
    if (!_voiceImageView) {
        _voiceImageView = [[UIImageView alloc] init];
        _voiceImageView.image = DCTCImageNamed(@"dctc_homepage_voice_icon3");
        NSMutableArray *arr = [NSMutableArray array];
        UIImage *image1 = [DictComponentHelper imageNamed:@"dctc_homepage_voice_icon1"];
        UIImage *image2 =[DictComponentHelper imageNamed:@"dctc_homepage_voice_icon2"];
        UIImage *image3 =[DictComponentHelper imageNamed:@"dctc_homepage_voice_icon3"];
        [arr addObject:image1];
        [arr addObject:image2];
        [arr addObject:image3];
        _voiceImageView.animationImages = [arr copy];
        _voiceImageView.animationRepeatCount = 1;
        _voiceImageView.animationDuration = 1.5;
    }
    return _voiceImageView;
}

- (UIButton *)collectButton {
    if (!_collectButton) {
        _collectButton = [[UIButton alloc]init];
        [_collectButton setImage:[DictComponentHelper imageNamed:@"dict_preview_collecte_normal"] forState:UIControlStateNormal];
        [_collectButton addTarget:self action:@selector(collectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _collectButton;
}

- (UIImageView *)line {
    if (!_line) {
        _line = [[UIImageView alloc]init];
        _line.backgroundColor = [UIColor colorWithHexString:@"#dddddd"];
    }
    return _line;
}

- (UIView *)centerView {
    if (!_centerView) {
        _centerView = [[UIView alloc]init];
        _centerView.backgroundColor = [UIColor whiteColor];
    }
    return _centerView;
}

- (UILabel *)typeLable {
    
    if (!_typeLable) {
        _typeLable = [[UILabel alloc]init];
        _typeLable.textColor = [UIColor colorWithHexString:@"#ffffff"];
        _typeLable.backgroundColor = [UIColor colorWithHexString:DCTCLoacalString(@"DICT_BACKGROUND_SELETED_COLOR")];
        _typeLable.layer.cornerRadius = 2;
        _typeLable.clipsToBounds = YES;
        _typeLable.font = [UIFont systemFontOfSize:9];
        _typeLable.textAlignment = NSTextAlignmentCenter;
        _typeLable.text = @"虚词";
        _typeLable.hidden = YES;
    }
    return _typeLable;
}
- (UIView *)traditionalView {
    if (!_traditionalView) {
        _traditionalView = [[UIView alloc] init];
        UIImageView *left = [[UIImageView alloc] init];
        left.image = DCTCImageNamed(@"dctc_search_result_traditional_leftIcon");
        UIImageView *right = [[UIImageView alloc] init];
        right.image = DCTCImageNamed(@"dctc_search_result_traditional_rightIcon");
        UIImageView *traditionImage = [[UIImageView alloc] init];
        traditionImage.image = DCTCImageNamed(@"dctc_search_result_traditional");
        [_traditionalView addSubview:left];
        [_traditionalView addSubview:traditionImage];
        [_traditionalView addSubview:self.traditionalLable];
        [_traditionalView addSubview:right];
        [left mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_traditionalView);
            make.centerY.equalTo(_traditionalView);
            make.size.mas_equalTo(left.image.size);
        }];
        [traditionImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(left.mas_trailing).offset(0);
            make.centerY.equalTo(_traditionalView);
            make.size.mas_equalTo(traditionImage.image.size);
        }];
        [self.traditionalLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(traditionImage.mas_trailing).offset(2);
            make.centerY.equalTo(_traditionalView);
            
        }];
        [right mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_traditionalLable.mas_trailing).offset(-0);
            make.centerY.equalTo(_traditionalView);
            make.size.mas_equalTo(right.image.size);
        }];
        _traditionalView.hidden = YES;
    }
    return _traditionalView;
}
- (UILabel *)traditionalLable {
    if (!_traditionalLable) {
        _traditionalLable = [[UILabel alloc] init];
        _traditionalLable.font = [DctcFontUtil spellFontWithSize:15];
        _traditionalLable.textColor = [UIColor colorWithHexString:@"#fa8b2d"];
        [_traditionalLable sizeToFit];
    }
    return _traditionalLable;
}

@end
