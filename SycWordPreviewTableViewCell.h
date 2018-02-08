//
//  SycWordPreviewTableViewCell.h
//  DictComponent
//
//  Created by syc on 2017/12/1.
//  Copyright © 2017年 ND. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DictSDK/DCTSCrossSearchModel.h>


@class SycWordPreviewTableViewCell;

@protocol SycWordPreviewTableViewCellDelegate <NSObject>

- (void)didSelectedCollectAction:(SycWordPreviewTableViewCell *)cell;

- (void)didSelectedVoiceAction:(SycWordPreviewTableViewCell *)cell;

@end


@interface SycWordPreviewTableViewCell : UITableViewCell

@property (nonatomic, weak) id delegate;
@property (nonatomic ,strong) UIImageView *voiceImageView;


+ (NSString*)indentify;


- (void)upateDateWithData:(DCTSCrossSearchModel *)model;

- (void)hideLine:(BOOL)hide;


@end
