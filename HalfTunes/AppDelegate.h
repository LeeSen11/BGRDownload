//
//  AppDelegate.h
//  HalfTunes
//
//  Created by LeeSen on 2019/5/24.
//  Copyright © 2019 LeeSen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompletionHandler)(void);

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, copy) CompletionHandler backgroundSessionCompletionHandler;

@end

