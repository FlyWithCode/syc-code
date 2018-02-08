//
//  DctcWordPreviewTableViewCell.h
//  DictComponent
//
//  Created by syc on 2017/12/1.
//  Copyright © 2017年 ND. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DictSDK/DCTSCrossSearchModel.h>


@class DctcWordPreviewTableViewCell;

@protocol DctcWordPreviewTableViewCellDelegate <NSObject>

- (void)didSelectedCollectAction:(DctcWordPreviewTableViewCell *)cell;

- (void)didSelectedVoiceAction:(DctcWordPreviewTableViewCell *)cell;

@end


@interface DctcWordPreviewTableViewCell : UITableViewCell

@property (nonatomic, weak) id delegate;
@property (nonatomic ,strong) UIImageView *voiceImageView;


+ (NSString*)indentify;


- (void)upateDateWithData:(DCTSCrossSearchModel *)model;

- (void)hideLine:(BOOL)hide;


@end
