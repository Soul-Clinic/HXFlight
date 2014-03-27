//
//  FirstViewController.m
//  HXFlight
//
//  Created by Can EriK Lu on 3/21/14.
//  Copyright (c) 2014 Can EriK Lu. All rights reserved.
//

#import "Home.h"
#import "MyHuaxia.h"
#import "ViewOperation.h"
#import <AudioToolbox/AudioToolbox.h>
@interface Home ()
{
	NSArray* tasks;
    NSArray* urgencyColors;
    NSDictionary* shortcuts;
    NSMutableArray*	_buttons;
    CGRect scrollFrame;
    BOOL done;
}
@end

@implementation Home

- (void)viewDidLoad
{
    [super viewDidLoad];

    _marginBottom.constant = self.tabBarController.tabBar.height;

    if (!isiOS7()) {
        _marginBottom.constant = 0;
        _marginTop.constant = -2;
    }

	tasks = @[@[@"bans01", @"待办任务", @"4月10日华夏移动办公平台学习ing", @3], @[@"bans02", @"提醒任务", @"周二下午三点前去机场接刘局长...", @1]];
    urgencyColors = @[rgb(116, 189, 59), rgb(214, 214, 35), rgb(219, 154, 15)];
   	NSString* lastKey = @"快捷方式";
    shortcuts = @{@"消息通知":@"1",
                  @"管理决策":@"2",
                  @"我的工作":@"3",
                  @"我的计划":@"4",
                  @"我的任务":@"5",
                  @"我的日程":@"6",
                  @"个人信息":@"7",
                  @"我的职责":@"8",
                  @"我的文件":@"9",
                  @"薪资福利":@"11",
                  @"运行控制":@"12",
                  @"服务质量":@"13",
                  @"维修管理":@"14",
                  @"安全管理":@"15",
                  @"市场营销":@"16",
                  @"财务管理":@"17",
                  @"人力资源":@"18",
                  @"行政管理":@"19",
                  @"企业管理":@"20",
                  lastKey:@"add"};

    NSMutableArray* allKeys = [shortcuts.allKeys mutableCopy];
    //Set the lastKey to the last
	[allKeys exchangeObjectAtIndex:[allKeys indexOfObject:lastKey] withObjectAtIndex:allKeys.count -1];

    _buttons = [NSMutableArray array];

	CGSize textSize = [allKeys[0] sizeWithFont:[UIFont systemFontOfSize:14]];
    float textHeight = textSize.height;
    float textWidth = textSize.width;
	float spacing = 3.f;

    for (NSString* key in allKeys) {

        UIImage* icon = [UIImage imageNamed:shortcuts[key]];
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, MAX(icon.size.width, textWidth), icon.size.height + textHeight + spacing)];
        float iconX = (button.width - icon.size.width) / 2,
        textX = (button.width - textWidth) / 2;

		[button setImage:icon forState:UIControlStateNormal];
        [button setTitle:key forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, iconX, button.height - icon.size.height , iconX)];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(icon.size.height, -(button.width - textX), 0, 0)];
		button.showsTouchWhenHighlighted = YES;
        UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
        [button addGestureRecognizer:longPress];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
		UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [button addGestureRecognizer:pan];
        button.userInteractionEnabled = YES;
        [_buttons addObject:button];
    }

    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(changToRightTab:)];
	[swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
}
- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender
{
    static CGPoint start;
    if (sender.state == UIGestureRecognizerStateBegan) {
        start = sender.view.origin;
    }
    CGPoint translation = [sender translationInView:sender.view];
	sender.view.origin = CGPointMake(start.x + translation.x, start.y + translation.y);

    NSLog(@"%i - Location is %@\tTranspation is %@,\tvelocity is %@", (int)sender.state, NSStringFromCGPoint([sender locationInView:sender.view]), NSStringFromCGPoint([sender translationInView:sender.view]), NSStringFromCGPoint([sender velocityInView:sender.view]));
}

- (void)rotation:(UIButton*)button
{
    CGFloat rotationAngle = M_PI / 20;
    static BOOL left = YES;
    static void (^ shake)(void);
    if (shake == nil) {
        shake = ^(void) {
            CGAffineTransform transform = CGAffineTransformRotate(button.transform, left ? -rotationAngle : rotationAngle);
            NSLog(@"Button is %@", button.titleLabel.text);
            button.transform = transform;
            left = !left;
        };
    }

    static void (^const complete)(BOOL) = ^(BOOL finished) {
//        NSLog(@"Insider complete");
		[UIView animateWithDuration:0.2 animations:shake completion:complete];
    };
    complete(YES);
    NSLog(@"Roo");
	return;
    NSLog(@"Rotation");
    [UIView animateWithDuration:0.2 animations:shake completion:^(BOOL finished) {
        NSLog(@"Complete %i", finished);
        if (finished) {
            [self rotation:button];
        }
    }];

  
}

- (IBAction)longPressed:(UIGestureRecognizer *)sender
{
    //3 = (int)UIGestureRecognizerStateEnded
	NSLog(@"%@ is long pressed %i ", ((UIButton*)sender.view).titleLabel.text, (int)sender.state);
    __block UIButton* button = (UIButton*)sender.view;

	if (sender.state == UIGestureRecognizerStateBegan) {

//        button.frame = CGRectOffset(button.frame, button.superview.x, button.superview.y);
//		[button.superview.superview addSubview:button];

		done = NO;
        CGFloat rotationAngle = M_PI / 10;
        static BOOL left = YES;
        static void (^ shake)(void);
        if (shake == nil) {
            shake = ^(void) {
                CGAffineTransform transform = CGAffineTransformRotate(button.transform, left ? -rotationAngle : rotationAngle);
                button.transform = transform;
                left = !left;
            };
        }

        static void (^complete)(BOOL);
        if (complete == nil) {
            complete = ^(BOOL finished) {
                NSLog(@"Insider complete");
                if (done) {

                    [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^ {
						button.transform = CGAffineTransformIdentity;
                    } completion:nil];
                }
                else {
                [UIView animateWithDuration:0.3 animations:shake completion:complete];
                }
            };
        }

        complete(YES);
//        [self rotation:button];
		[self performSelector:@selector(doneRotation:) withObject:button afterDelay:2];

//        [self rotation:button];
        //        [UIView animateWithDuration:.12 animations:^{
//            CGAffineTransform transform = CGAffineTransformMakeTranslation(-50, -40);
//            transform = CGAffineTransformScale(transform, 1.3, 1.3);
//            button.transform = transform;
//        } completion:^(BOOL finished) {
//
//            [UIView animateWithDuration:0.52 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAutoreverse
//                             animations:left completion:^(BOOL finished) {
//
//                [UIView animateWithDuration:0.4 animations:^{
//                    CGAffineTransform transform = CGAffineTransformRotate(button.transform, -rotationAngle);
//                    button.transform = transform;
//                }];
//
//            }];
//        }];

//        float rotations = 1;
//        CABasicAnimation* rotationAnimation;
//        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations];
//        rotationAnimation.duration = 3.5;
//        rotationAnimation.cumulative = YES;
//        rotationAnimation.repeatCount = HUGE_VALF;
//
//        [button.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];

//        [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//            NSLog(@"Start");
//            button.transform = CGAffineTransformMakeRotation(M_PI * 1.9);
//        } completion:^(BOOL finished) {
//            NSLog(@"Finish");
//        }];
    }
    if (sender.state == UIGestureRecognizerStateEnded + 10.) {
		[UIView animateWithDuration:0.1 animations:^{
            button.transform = CGAffineTransformMakeRotation(0);
        }];
		return;

    }

}
- (void)doneRotation:(UIButton*)button
{
    [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^ {
        button.transform = CGAffineTransformIdentity;
    } completion:nil];

//    done = YES;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    NSLog(@"Touch up %@", event);
}

- (IBAction)changToRightTab:(id)sender
{
    MyHuaxia* myhx = self.tabBarController.viewControllers[1];
    myhx.fromSwiping = YES;
    self.tabBarController.selectedIndex = 1;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self scrollViewDidEndDecelerating:_scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;

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

- (IBAction)pageChanged:(UIPageControl *)sender
{
    [_scrollView setContentOffset:CGPointMake(sender.currentPage * _scrollView.frame.size.width, 0) animated:YES];
}

- (IBAction)buttonClicked:(UIButton*)sender
{
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    NSLog(@"Hello, %@ is clicked.", sender.titleLabel.text);}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];

	if (CGRectEqualToRect(scrollFrame, CGRectZero) || !CGRectEqualToRect(scrollFrame, _scrollView.frame)) {
        scrollFrame = _scrollView.frame;
        _pageControl.numberOfPages = [ViewOperation layoutSubviews:_buttons inScrollView:_scrollView];
    }
    [self scrollViewDidEndDecelerating:_scrollView];
    if (!isiOS7()) {
        [self.view layoutSubviews];
    }

}


#pragma mark - Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString * const identifier = @"main";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    NSArray* task = tasks[indexPath.row];
    UIImageView* icon = (UIImageView*)[cell.contentView viewWithTag:0];
    UILabel* title = (UILabel *)[cell viewWithTag:1];
    UILabel* detail = (UILabel *)[cell viewWithTag:2];
	UILabel* urgency = (UILabel *)[cell viewWithTag:3];

    icon.image = [UIImage imageNamed:task[0]];
	title.text = task[1];
    detail.text = task[2];
    urgency.text = ((NSNumber*)task[3]).stringValue;
    int level = ((NSNumber*)task[3]).intValue;
    if (level >= 0 && level < urgencyColors.count) {
        urgency.backgroundColor = urgencyColors[level];
    }

    [urgency.layer setCornerRadius:3.f];

	cell.backgroundColor = [UIColor clearColor];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    return cell;
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selecting some one");
    return indexPath;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}

@end
