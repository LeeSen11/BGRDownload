//
//  AppDelegate.m
//  HalfTunes
//
//  Created by LeeSen on 2019/5/24.
//  Copyright © 2019 LeeSen. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic, strong) UIColor *tintColor;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self customAppearance];
    return YES;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler
{
    self.backgroundSessionCompletionHandler = completionHandler;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Private Methods
- (void)customAppearance
{
    self.window.tintColor = self.tintColor;
    [UISearchBar appearance].barTintColor = self.tintColor;
    [UINavigationBar appearance].barTintColor = self.tintColor;
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];;
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
}

#pragma mark - Setters and Gettes
- (UIColor *)tintColor
{
    if (!_tintColor) {
        _tintColor = [UIColor redColor];//[[UIColor alloc] initWithRed:242/255 green:71/255 blue:63/255 alpha:1.0];
    }
    return _tintColor;
}

@end
