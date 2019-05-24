//
//  Download.m
//  HalfTunes
//
//  Created by LeeSen on 2019/5/24.
//  Copyright © 2019 LeeSen. All rights reserved.
//

#import "Download.h"

@implementation Download

- (instancetype)initWithUrl:(NSString *)url
{
    if (self = [super init]) {
        self.url = url;
    }
    return self;
}

@end
