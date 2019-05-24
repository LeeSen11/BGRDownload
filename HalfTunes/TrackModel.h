//
//  TrackModel.h
//  HalfTunes
//
//  Created by LeeSen on 2019/5/24.
//  Copyright © 2019 LeeSen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TrackModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *previewUrl;

- (instancetype)initWithName: (NSString *)name artist: (NSString *)artist previewUrl: (NSString *)previewUrl;

@end

NS_ASSUME_NONNULL_END
