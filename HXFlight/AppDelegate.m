//
//  AppDelegate.m
//  HXFlight
//
//  Created by Can EriK Lu on 3/21/14.
//  Copyright (c) 2014 Can EriK Lu. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    UITabBarController *dtbc = [[UITabBarController alloc] init];
    _tabBarHeight = dtbc.tabBar.frame.size.height;

    UIImage* bg = [UIImage imageNamed:@"tab_bg"];
    CGSize newSize = CGSizeMake([UIScreen mainScreen].bounds.size.width / 4, _tabBarHeight - (isiOS7() ? 0 : 1));
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageWithImage:bg scaledToSize:newSize]];

    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"Resign active, should not lock screen");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to itΩs current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	NSLog(@"Enter Background");
    [self lockScreen];
}

- (void)lockScreen
{
    [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate new]];
}


@end
