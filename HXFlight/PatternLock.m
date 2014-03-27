//
//  PatterLock.m
//  HXFlight
//
//  Created by Can EriK Lu on 3/24/14.
//  Copyright (c) 2014 Can EriK Lu. All rights reserved.
//

#import "PatternLock.h"

#define kPasswordKey	@"patternlock_password"
NSString * const kInputPassword = @"请输入手势密码";
NSString * const kInputedWrong = @"密码错误, 请重新输入";
NSString * const kInputedOK = @"登陆成功, 欢迎回来!";
NSString * const kSetPassword = @"请设置手势密码";
NSString * const kConfirmPassword = @"请确认手势密码";
NSString * const kConfirmWrong = @"确认失败, 请重新设置";
NSString * const kSetSucceed = @"设置成功! 请记住您的密码";

@interface PatternLock ()
{
    NSString* password;
}
@end

@implementation PatternLock

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Load");
//    self.pattern.margin = 15;
//	self.pattern.column = 3;
//  self.pattern.accuracy = 0;
//    self.pattern.dotSize = CGSizeMake(35, 35);
    if (!IS_IPHONE5) {
        NSLog(@"iPhone 4");
        self.pattern.margin = UIEdgeInsetsMake(60, self.pattern.margin.left, 0, self.pattern.margin.right);
    }
    self.pattern.delegate = self;
    self.pattern.background = [UIImage imageNamed:@"background"];
    password = userDefaultsStringForKey(kPasswordKey);
    if (!password) {
        self.infoLabel.text = kSetPassword;
    }
    else {
        NSLog(@"password is %@", password);
        self.infoLabel.text = kInputPassword;
    }

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (password) {
        [self inputPasswordWrong:self.pattern];
    }

    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self loginSuccessfully:self.pattern];
}
- (void)patternLockView:(PatternLockView *)patternLockView didFinishWithValue:(NSString *)value
{

    patternLockView.enabled = NO;
    if (!password) {				//First time

        static NSString* firstTimePassword;
        static BOOL confirming = NO;

        if (!confirming) {
            confirming = YES;
            firstTimePassword = value;
            [UIView animateWithDuration:0.5 animations:^{
            	self.infoLabel.text = kConfirmPassword;
            }];

            [self performSelector:@selector(confirmPatternLock:) withObject:patternLockView afterDelay:.6];
        }
        else {
            if ([value isEqual:firstTimePassword]) {
                setUserDefaults(kPasswordKey, firstTimePassword);
                [UIView animateWithDuration:0.5 animations:^{
                    self.infoLabel.text = kSetSucceed;
                }];
                [patternLockView showInSuccessMode];
                [self performSelector:@selector(loginSuccessfully:) withObject:patternLockView afterDelay:.6];
            }
            else {
				[UIView animateWithDuration:0.5 animations:^{
                    self.infoLabel.text = kConfirmWrong;
                }];
                [patternLockView showInErrorMode];
                [self performSelector:@selector(confirmPasswordWrong:) withObject:patternLockView afterDelay:.6];
            }

            firstTimePassword = nil;
            confirming = NO;

        }
    }
    else {
        if ([password isEqual:value]) {
            [UIView animateWithDuration:0.5 animations:^{
                self.infoLabel.text = kInputedOK;
            }];
            [patternLockView showInSuccessMode];
            [self performSelector:@selector(loginSuccessfully:) withObject:patternLockView afterDelay:.6];
        }
        else {
			[UIView animateWithDuration:0.5 animations:^{
                self.infoLabel.text = kInputedWrong;
            }];
            [patternLockView showInErrorMode];
			[self performSelector:@selector(inputPasswordWrong:) withObject:patternLockView afterDelay:.6];
        }
    }
    [self.infoLabel sizeToFit];

}
- (void)confirmPatternLock:(PatternLockView*)patternLockView
{
    patternLockView.enabled = YES;
	[patternLockView clear];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.pattern updateCoordinate];
    [self.pattern setNeedsDisplay];
}

- (void)loginSuccessfully:(PatternLockView*)patternLockView
{
	[self performSegueWithIdentifier:@"done" sender:self];
}

- (void)confirmPasswordWrong:(PatternLockView*)patternLockView
{
    patternLockView.enabled = YES;
	[patternLockView clear];
    [UIView animateWithDuration:0.5 animations:^{
        self.infoLabel.text = kSetPassword;
        [self.infoLabel sizeToFit];
    }];
}

- (void)inputPasswordWrong:(PatternLockView*)patternLockView
{
    patternLockView.enabled = YES;
	[patternLockView clear];
    [UIView animateWithDuration:0.5 animations:^{
        self.infoLabel.text = kInputPassword;
        [self.infoLabel sizeToFit];
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UITabBarController* tab = (UITabBarController*)((UINavigationController*)segue.destinationViewController).topViewController;
        if (isiOS7()) {
            [UITabBar appearance].tintColor = [UIColor whiteColor];
            tab.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
            tab.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
        }
    }
}


@end
