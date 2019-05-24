//
//  TrackCell.m
//  HalfTunes
//
//  Created by LeeSen on 2019/5/24.
//  Copyright © 2019 LeeSen. All rights reserved.
//

#import "TrackCell.h"

@implementation TrackCell


- (IBAction)downloadTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(downloadTapped:)]) {
        [self.delegate downloadTapped:self];
    }
}

- (IBAction)pauseOrResumeTapped:(id)sender {
    if ([self.pauseBtn.titleLabel.text isEqualToString:@"暂停"]) {
        if ([self.delegate respondsToSelector:@selector(pauseTapped:)]) {
            [self.delegate pauseTapped:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(resumeTapped:)]) {
            [self.delegate resumeTapped:self];
        }
    }
}

- (IBAction)cancelTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cancelTapped:)]) {
        [self.delegate cancelTapped:self];
    }
}

@end
