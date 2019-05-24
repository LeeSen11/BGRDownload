//
//  Download.h
//  HalfTunes
//
//  Created by LeeSen on 2019/5/24.
//  Copyright © 2019 LeeSen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Download : NSObject

@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, copy) NSString *fileSizeText;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSData *resumeData;

- (instancetype)initWithUrl: (NSString *)url;

@end

NS_ASSUME_NONNULL_END
