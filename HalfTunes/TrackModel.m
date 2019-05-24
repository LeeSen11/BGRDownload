

//
//  TrackModel.m
//  HalfTunes
//
//  Created by LeeSen on 2019/5/24.
//  Copyright © 2019 LeeSen. All rights reserved.
//

#import "TrackModel.h"

@implementation TrackModel

- (instancetype)initWithName:(NSString *)name artist:(NSString *)artist previewUrl:(NSString *)previewUrl
{
    if (self = [super init]) {
        self.name = name;
        self.artist = artist;
        self.previewUrl = previewUrl;
    }
    return self;
}

@end
