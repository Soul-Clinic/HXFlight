//
//  AppDelegate.h
//  HXFlight
//
//  Created by Can EriK Lu on 3/21/14.
//  Copyright (c) 2014 Can EriK Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UITabBarController* _tab;
}
@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) float tabBarHeight;
@end
