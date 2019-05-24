//
//  TrackCell.h
//  HalfTunes
//
//  Created by LeeSen on 2019/5/24.
//  Copyright © 2019 LeeSen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TrackCell;
@protocol TrackCellDelegate <NSObject>

- (void)pauseTapped: (TrackCell *)cell;
- (void)resumeTapped: (TrackCell *)cell;
- (void)cancelTapped: (TrackCell *)cell;
- (void)downloadTapped: (TrackCell *)cell;

@end

@interface TrackCell : UITableViewCell

@property (nonatomic, weak) id<TrackCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UILabel *artistLb;
@property (weak, nonatomic) IBOutlet UILabel *progesssLb;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@end

NS_ASSUME_NONNULL_END
