//
//  SycWordPreviewView.m
//  DictComponent
//
//  Created by syc on 2017/12/1.
//  Copyright © 2017年 ND. All rights reserved.
//
#define KMaxHeight 282

#import "SycWordPreviewView.h"
#import <Masonry/Masonry.h>
#import <libextobjc/EXTScope.h>
#import <DictSDK/DCTSManager.h>
#import <UCSDK/UCManager.h>
#import "NSError+Extension.h"
#import "UIColor+Extension.h"
#import "DctcFontUtil.h"
#import "UILabel+Html.h"
#import "HUDHelper.h"
#import "DictComponentHelper.h"
#import "DctcConfig.h"
#import "DctcCommonDefine.h"
#import "DctcSearchLoadingView.h"
#import "DctcWordDetailJSBridgeViewModel.h"


@interface SycWordPreviewView () <UITableViewDelegate,UITableViewDataSource,SycWordPreviewTableViewCellDelegate>
@property (nonatomic, strong) UILabel *wordLable;
@property (nonatomic, strong) UIImageView *wordBgImageView;

@property (nonatomic, strong) UILabel *buShouLable;
@property (nonatomic, strong) UILabel *buShouTitleLable;

@property (nonatomic, strong) UILabel *biHuaLable;
@property (nonatomic, strong) UILabel *biHuaTitleLable;

@property (nonatomic, strong) UIImageView *line;
@property (nonatomic, strong) UITableView *wordTablview;

@property (nonatomic, strong) DctcSearchLoadingView *loadingView;

@property (nonatomic, strong) UIControl *dctcMaskView;
@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) CGFloat topSpace;

@property (nonatomic, assign) BOOL isCenter;
@property (nonatomic, assign) BOOL isAddSubView;
@property (nonatomic, assign) BOOL isShowSubView;

@end

@implementation SycWordPreviewView

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
    CGRect frame = CGRectMake((SCREEN_WIDTH-640*kScale)/2, topSpace, 640*kScale, 430*kScale);
    return  [self initWithFrame:frame];
}

- (instancetype)initWithCenter{
    _isCenter = YES;
    CGRect frame = CGRectMake((SCREEN_WIDTH-640*kScale)/2, (SCREEN_HEIGHT - 430*kScale)/2, 640*kScale, 430*kScale);
    return  [self initWithFrame:frame];
}


- (void)updateData:(NSArray *)data  {
    if (data.count <= 0) {
        return;
    }
    [self.dataArray removeAllObjects];
    self.dataArray = [NSMutableArray arrayWithArray:data];
  
    //检查收藏状态
    DCTSCrossSearchModel *tmp = [self.dataArray lastObject];
    @weakify(self);
    for (DCTSCrossSearchModel *m in self.dataArray) {
        [[DctcWordDetailJSBridgeViewModel instance] checkCollectWordId:m.wordId
                                                                 spell:m.spell
                                                         callbackBlock:^(NSString *sourceId, NSString *favId) {
          
             NSString *currentSouceId = [[DctcWordDetailJSBridgeViewModel instance] getSourceIdWithWordId:m.wordId spell:m.spell];
             m.favId = favId;
             m.sourceId = currentSouceId;
            if ([m.wordId isEqualToString:tmp.wordId]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    [self.wordTablview reloadData];
                });
            }
        }];
    }

    [self updateSubPageView];
    [self updatePageViewLayout];
    
    DCTSCrossSearchModel *model = [self.dataArray firstObject];
    NSMutableAttributedString *title = [self.wordLable setHtmlWithString:model.word imgeX:0 imgeY:-3];
    NSString *number = @"";
    NSString *titleStr = @"";
    if (title.length > 1) {
        number = [[title mutableString]substringWithRange:NSMakeRange(1, title.length -1)];
        titleStr = [[title mutableString]substringWithRange:NSMakeRange(0, 1)];
    }else {
        titleStr = [title mutableString];
    }
    UIFont *titleFont = [DctcFontUtil kaiFontWithSize:48];
    if ([self  isChineseString:titleStr]) {
        titleFont = [DctcFontUtil spellFontWithSize:48];
    }
    [self setHtmlStrWithFont:titleFont color:[UIColor colorWithHexString:@"#333333"] text:titleStr lable:self.wordLable];
    
    NSString *bs = [NSString stringWithFormat:@"%@ 部",model.bs];
    [self setHtmlStrWithFont:[DctcFontUtil spellFontWithSize:17] color:[UIColor colorWithHexString:@"#333333"] text:bs lable:self.buShouTitleLable];
    
    NSString *sttroke = [NSString stringWithFormat:@"%@ 画",model.numOfStroke];
    [self setHtmlStrWithFont:[DctcFontUtil spellFontWithSize:17] color:[UIColor colorWithHexString:@"#333333"] text:sttroke lable:self.biHuaTitleLable];
    
    [self.wordTablview reloadData];
    [self.wordTablview setContentOffset:CGPointMake(0, 0)];

}


- (void)addPageViewWithParentVC:(UIViewController *)parventVC {
    if (_isAddSubView) {
        return;
    }
    [parventVC.navigationController.view addSubview:self.dctcMaskView];
    [parventVC.navigationController.view addSubview:self];
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

- (void)showPageView:(UIView *)pView {
    if (_isShowSubView) {
        return;
    }
    _isShowSubView = YES;
    [pView addSubview:self];
}

- (void)hiddenPageView {
    if (!_isShowSubView) {
        return;
    }
    _isShowSubView = NO;
    [self removeFromSuperview];
}

- (void)reSetTopSapce:(CGFloat)topSpace {
    _topSpace = topSpace;
    _isCenter = NO;
    [self updateSubPageView];
    [self updatePageViewLayout];
}

- (void)updateSubPageView {
    @weakify(self);
    if (self.type == SycWordPreviewViewTypeWywCarmer) {
        [self hideBhAndBs:YES];
        [self.line mas_remakeConstraints:^(MASConstraintMaker *make) {
            @strongify(self);
            make.top.equalTo(self.wordBgImageView.mas_bottom).offset(40*kScale);
            make.size.mas_equalTo(CGSizeMake(600*kScale, 0.5));
            make.centerX.equalTo(self.mas_centerX);
        }];
    }else if (self.type == SycWordPreviewViewTypeDefault) {
        [self hideBhAndBs:NO];
        [self.line mas_remakeConstraints:^(MASConstraintMaker *make) {
            @strongify(self);
            make.top.equalTo(self.biHuaLable.mas_bottom).offset(30*kScale);
            make.size.mas_equalTo(CGSizeMake(600*kScale, 0.5));
            make.centerX.equalTo(self.mas_centerX);
        }];
    }
}

- (void)hideBhAndBs:(BOOL)hide {
    self.biHuaLable.hidden = hide;
    self.biHuaTitleLable.hidden = hide;
    self.buShouLable.hidden = hide;
    self.buShouTitleLable.hidden = hide;
}

- (void)updatePageViewLayout {
    CGFloat height = 430*kScale;
    if (self.type == SycWordPreviewViewTypeWywCarmer) {
        height = 372*kScale;
    }
    CGFloat centerY = (SCREEN_HEIGHT - 430*kScale)/2;
    if (self.dataArray.count >= 2) {
        [self.wordTablview mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(640*kScale, KMaxHeight*kScale));
        }];
        height = 556*kScale;
        if (self.type == SycWordPreviewViewTypeWywCarmer) {
            height = 488*kScale;
        }
        centerY = (SCREEN_HEIGHT - height)/2;
    }else {
        [self.wordTablview mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(640*kScale, 166*kScale));
        }];
    }
    if (_isCenter) {
        self.frame = CGRectMake((SCREEN_WIDTH-640*kScale)/2, centerY , 640*kScale, height);
    }else {
        self.frame = CGRectMake((SCREEN_WIDTH-640*kScale)/2, _topSpace , 640*kScale, height);
    }
}

#pragma mark - pravite methond


- (void)addSubPageView {
    self.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    [self addSubview:self.wordBgImageView];
    [self addSubview:self.wordLable];
    
    [self addSubview:self.buShouLable];
    [self addSubview:self.buShouTitleLable];
    
    [self addSubview:self.biHuaLable];
    [self addSubview:self.biHuaTitleLable];
    
    [self addSubview:self.line];
    [self addSubview:self.wordTablview];
    
}

- (void)layOutPageView {
    @weakify(self);
    
    [self.wordBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top).offset(40*kScale);
        make.size.mas_equalTo(CGSizeMake(125*kScale, 125*kScale));
    }];
    
    [self.wordLable mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top).offset(40*kScale);
        make.size.mas_equalTo(CGSizeMake(125*kScale, 125*kScale));
    }];
    
    [self.buShouLable mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.leading.equalTo(self.mas_leading).offset(136*kScale);
        make.top.equalTo(self.wordLable.mas_bottom).offset(40*kScale);
    }];
    [self.buShouTitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.leading.equalTo(self.buShouLable.mas_trailing).offset(20*kScale);
        make.top.equalTo(self.wordLable.mas_bottom).offset(40*kScale);
    }];
    
    [self.biHuaLable mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.leading.equalTo(self.buShouTitleLable.mas_trailing).offset(50*kScale);
        make.top.equalTo(self.wordLable.mas_bottom).offset(40*kScale);
    }];
    [self.biHuaTitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.leading.equalTo(self.biHuaLable.mas_trailing).offset(20*kScale);
        make.top.equalTo(self.wordLable.mas_bottom).offset(40*kScale);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.biHuaLable.mas_bottom).offset(30*kScale);
        make.size.mas_equalTo(CGSizeMake(600*kScale, 0.5));
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    [self.wordTablview mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.line.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(640*kScale, 166*kScale));
        make.centerX.equalTo(self.mas_centerX);
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

- (BOOL)isChineseString:(NSString *)title {
    NSString *match = @"(^[\uE500-\uE657]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ matches %@",title, match];
    return [predicate evaluateWithObject:title];
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DctcWordPreviewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[DctcWordPreviewTableViewCell indentify] forIndexPath:indexPath];
    cell.delegate = self;
    if (self.dataArray.count > 0 && indexPath.row < self.dataArray.count) {
        DCTSCrossSearchModel *model = [self.dataArray objectAtIndex:indexPath.row];
        [cell upateDateWithData:model];
        if (indexPath.row == self.dataArray.count - 1) {
            [cell hideLine:YES];
        }else{
            [cell hideLine:NO];
        }
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MUPLogDebug(@"didSelectRowAtIndexPath");
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.dataArray.count > 0 && indexPath.row < self.dataArray.count) {
        DCTSCrossSearchModel *model = [self.dataArray objectAtIndex:indexPath.row];
        if ([_delegate respondsToSelector:@selector(didSelectRowWithModel:)]) {
            [_delegate didSelectRowWithModel:model];
        }
   }
}

#pragma mark - SycWordPreviewTableViewCellDelegate

- (void)didSelectedCollectAction:(DctcWordPreviewTableViewCell *)cell {
    MUPLogDebug(@"didSelectedCollectAction");
    NSInteger index = [self.wordTablview indexPathForCell:cell].row;
    if (index < self.dataArray.count) {
        DCTSCrossSearchModel *model = [self.dataArray objectAtIndex:index];
        //收藏逻辑
        if (model) {
            [self collectWithModel:model];
        }
    }
}

- (void)didSelectedVoiceAction:(DctcWordPreviewTableViewCell *)cell {
    MUPLogDebug(@"didSelectedVoiceAction");
    NSInteger index = [self.wordTablview indexPathForCell:cell].row;
    if (index < self.dataArray.count) {
        DCTSCrossSearchModel *model = [self.dataArray objectAtIndex:index];
        if (model.mp3Path.length > 0) {
            //后台播放
            [[DCTSManager instance] parseAudioUrl:model.mp3Path withDict:[DctcConfig instance].dictId csHost:[DctcConfig instance].csHost callbackBlock:^(NSString *localAudioPath, NSError *error) {
                //播放音频
                if (localAudioPath && ![localAudioPath isEqualToString:@""]) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [cell.voiceImageView startAnimating];
                    });
                    [self playAudioWithPath:localAudioPath];
                }
            }];
        }
    }
}

#pragma mark - tappaperMaskViewAction
- (void)tappaperMaskViewAction {
    [self removePageView];
    if ([_delegate respondsToSelector:@selector(didSelectMaskView)]) {
        [_delegate didSelectMaskView];
    }
}

#pragma mark - playAudioWithPath
//播放音频
- (void)playAudioWithPath:(NSString *)localAudioFile {
    NSURL *url = [NSURL fileURLWithPath:localAudioFile];
    if (!url) {
        MUPLogError(@"Fail to get url: %@", localAudioFile);
        return;
    }
    
    NSError *error = nil;
    self.player=[[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) {
        MUPLogError(@"fail to initWithContentsOfURL:%@ error:%@", url, error);
        return;
    }
    if(![self.player prepareToPlay]){
        MUPLogError(@"fail to prepare to playAudio:%@",localAudioFile);
        return;
    }
    if(![self.player play]){
        MUPLogError(@"fail to play audio:%@",localAudioFile);
    }
}


- (void)collectWithModel:(DCTSCrossSearchModel *)searchModel {
    @weakify(self);
    MUPLogInfo(@"ios ===发起收藏动作=======");
    if ([UCManager getCurrentUser]) {
        if (![[APFAppFactory instance] getComponent:@"com.nd.social.collection"]) {
            [HUDHelper showWithMessage:@"未集成收藏组件,请检查!"];
            return;
        }
        if (searchModel.favId.length > 0) {
            // 取消收藏
            [self showLoading];
            MUPLogInfo(@"ios ===发起取消收藏=======");
            [[DctcWordDetailJSBridgeViewModel instance] delCollectWithFavId:searchModel.favId
                                                                     wordId:searchModel.wordId
                                                                      spell:searchModel.spell
                                                              callbackBlock:^(BOOL succ, NSError * error,NSString *sourceId) {
                if ([error isNetworkError]) {
                    MUPLogInfo(@"ios ===取消收藏成功回调isNetworkError=======");
                    [self hidenLoading];
                    [HUDHelper showByError:error];
                    return;
                }
                searchModel.favId = nil;
                searchModel.sourceId = sourceId;
                if (succ) {
                    @weakify(self);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        @strongify(self);
                        [self.wordTablview reloadData];
                        NSDictionary *dict = @{@"sourceId":sourceId,
                                               @"favId":@"",
                                               };
                        [[NSNotificationCenter defaultCenter] postNotificationName:k_dict_preview_Collection_result_event object:nil userInfo:dict];
                        [[APFAppFactory instance].getEventAPI triggerEvent:nil eventName:k_dict_notice_collection_refresh_data_event param:@{}];
                    });
                }
                [self hidenLoading];
                NSString *msg = (!succ || error) ? DCTCLoacalString(@"DICT_CANCEL_COLLECT_FAIL"): DCTCLoacalString(@"DICT_HAD_CANCEL_COLLECT_SUCCESS");
                [HUDHelper showWithMessage:msg];
            }];
        } else {
            // 添加收藏
            MUPLogInfo(@"ios ===发起添加收藏=======");
            NSInteger type = 0;
            if ([[DctcConfig getCurrentDictId]isEqualToString:WEN_YAN_WEN]) {
                type = searchModel.xuci ? 2 : 1;
            }
            [[DctcWordDetailJSBridgeViewModel instance] upCollectionList:searchModel.wordId title:searchModel.word desc:searchModel.explain spell:searchModel.spell type:type mp3Path:searchModel.mp3Path keyword:searchModel.word callbackBlock:^(NSString *sourceId, NSString *favId) {
                if ([favId longLongValue] == 0) {
                    MUPLogInfo(@"ios ===添加收藏失败=======");
                    return;
                }
                searchModel.favId = favId;
                searchModel.sourceId = sourceId;
                if ([favId longLongValue] > 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        @strongify(self);
                        [self.wordTablview reloadData];
                        NSDictionary *dict = @{@"sourceId":sourceId,
                                               @"favId":favId,
                                               };
                        [[NSNotificationCenter defaultCenter] postNotificationName:k_dict_preview_Collection_result_event object:nil userInfo:dict];
                        [[APFAppFactory instance].getEventAPI triggerEvent:nil eventName:k_dict_notice_collection_refresh_data_event param:@{}];
                    });
                }
            }];
        }
    } else {
        MUPLogInfo(@"ios ===收藏如果未登录，需要跳转到登录页面=======");
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *currentVC = [[[APFAppFactory instance] getContext] currentViewController];
            NSDictionary *context = @{KEY_CMP_SRC_CONTROLLER : currentVC};
            [[APFAppFactory instance] goPage:context url:@"cmp://com.nd.sdp.uc_component/login?show_type=1"];
        });
    }
}


- (void)showLoading {
    [self creatLoadingView];
    if (self.loadingView) {
        [self.loadingView startAnimation];
    }
}
- (void)creatLoadingView {
    [self addSubview:self.loadingView];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading);
        make.trailing.equalTo(self.mas_trailing);
        make.centerY.equalTo(self.mas_centerY);
        if (IOS11) {
            make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(44);
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
        }else {
            make.top.equalTo(self).offset(64);
            make.bottom.equalTo(self.mas_bottom);
        }
    }];
}


- (void)hidenLoading {
    if (self.loadingView) {
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if (self.loadingView) {
                [self.loadingView stopAnimation];
                [self.loadingView removeFromSuperview];
            }
        });
    }
}

#pragma mark - getter & setter

- (UILabel *)wordLable {
    if (!_wordLable) {
        _wordLable = [[UILabel alloc]init];
        _wordLable.font = [DctcFontUtil kaiFontWithSize:48];
        _wordLable.textColor = [UIColor colorWithHexString:@"#333333"];
        _wordLable.textAlignment = NSTextAlignmentCenter;
    }
    return _wordLable;
}

- (UIImageView *)wordBgImageView {
    if (!_wordBgImageView) {
        _wordBgImageView = [[UIImageView alloc]init];
        _wordBgImageView.image = [DictComponentHelper imageNamed:@"dctc_homepage_daily_title_bg"];
    }
    return _wordBgImageView;
}

- (UILabel *)buShouLable {
    if (!_buShouLable) {
        _buShouLable = [[UILabel alloc]init];
        _buShouLable.font = [UIFont systemFontOfSize:15];
        _buShouLable.textColor = [UIColor colorWithHexString:@"#999999"];
        _buShouLable.text = @"部首:";
        _buShouLable.textAlignment = NSTextAlignmentCenter;
        [_buShouLable sizeToFit];
    }
    return _buShouLable;
}

- (UILabel *)buShouTitleLable {
    if (!_buShouTitleLable) {
        _buShouTitleLable = [[UILabel alloc]init];
        _buShouTitleLable.font = [DctcFontUtil spellFontWithSize:17];
        _buShouTitleLable.textColor = [UIColor colorWithHexString:@"#333333"];
        _buShouTitleLable.textAlignment = NSTextAlignmentCenter;
        [_buShouTitleLable sizeToFit];
    }
    return _buShouTitleLable;
}


- (UILabel *)biHuaLable {
    if (!_biHuaLable) {
        _biHuaLable = [[UILabel alloc]init];
        _biHuaLable.text = @"笔画:";
        _biHuaLable.font = [UIFont systemFontOfSize:15];
        _biHuaLable.textColor = [UIColor colorWithHexString:@"#999999"];
        _biHuaLable.textAlignment = NSTextAlignmentCenter;
        [_biHuaLable sizeToFit];
    }
    return _biHuaLable;
}

- (UILabel *)biHuaTitleLable {
    if (!_biHuaTitleLable) {
        _biHuaTitleLable = [[UILabel alloc]init];
        _biHuaTitleLable.font = [DctcFontUtil spellFontWithSize:17];
        _biHuaTitleLable.textColor = [UIColor colorWithHexString:@"#333333"];
        _biHuaTitleLable.textAlignment = NSTextAlignmentCenter;
        [_biHuaTitleLable sizeToFit];
    }
    return _biHuaTitleLable;
}

- (UIImageView *)line {
    if (!_line) {
        _line = [[UIImageView alloc]init];
        _line.backgroundColor = [UIColor colorWithHexString:@"#dddddd"];
    }
    return _line;
}

- (UITableView *)wordTablview {
    if (!_wordTablview) {
        _wordTablview = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_wordTablview registerClass:[DctcWordPreviewTableViewCell class] forCellReuseIdentifier:[DctcWordPreviewTableViewCell indentify]];
        _wordTablview.backgroundColor = [UIColor whiteColor];
        _wordTablview.delegate = self;
        _wordTablview.dataSource = self;
        _wordTablview.rowHeight = 166*kScale;
        _wordTablview.showsVerticalScrollIndicator = YES;
        _wordTablview.showsHorizontalScrollIndicator = NO;
        _wordTablview.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (IOS11) {//关闭Self-Sizing
            _wordTablview.estimatedRowHeight = 0;
            _wordTablview.estimatedSectionFooterHeight = 0;
            _wordTablview.estimatedSectionHeaderHeight = 0;
        }
    }
    return _wordTablview;
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

-(DctcSearchLoadingView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[DctcSearchLoadingView alloc] init];
    }
    return _loadingView;
}


- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}



@end
