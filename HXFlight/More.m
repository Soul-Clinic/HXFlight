//
//  More.m
//  HXFlight
//
//  Created by Can EriK Lu on 3/21/14.
//  Copyright (c) 2014 Can EriK Lu. All rights reserved.
//

#import "More.h"
#import "PalmHuaxia.h"
#import "Home.h"

@interface More ()
{
	UIImageView* _background;
}
@end

@implementation More

- (void)viewDidLoad
{
    [super viewDidLoad];

    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(changToLeftTab:)];
	[swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];

}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (isiOS7()) {
        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0);
    }
	if (!_background) {
        UIImageView* homeBk = ((Home*)(self.tabBarController.viewControllers[0])).background;
        _background = [[UIImageView alloc] init];
        _background.frame = homeBk.frame;
        _background.y = -self.tableView.contentInset.top;
        _background.image = homeBk.image;
        _background.contentMode = homeBk.contentMode;
        [self.view addSubview:_background];
        [self.view sendSubviewToBack:_background];
        self.tableView.backgroundColor = [UIColor clearColor];

    }

}
- (IBAction)changToLeftTab:(id)sender
{
    PalmHuaxia* palm = self.tabBarController.viewControllers[2];
    palm.fromSwiping = YES;
    self.tabBarController.selectedIndex = 2;
}


- (UIImage *)screenshot
{
    _background.alpha = 0.;
    UIGraphicsBeginImageContextWithOptions(self.view.frameSize, NO, 0);
    CGContextRef current = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:current];
    UIImage* screenshot = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();
    _background.alpha = 1.;
    return screenshot;
}
@end
