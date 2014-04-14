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
    ShortCutViewController* _shortcutController;
    BOOL done;
}
@end

@implementation Home

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@", self.childViewControllers);
    _shortcutController = self.childViewControllers.firstObject;
    _scrollView = _shortcutController.scrollView;
    _shortcutController.delegate = self;
//    _shortcutController.vibrateOnResort = YES;
    _scrollView.delegate = self;
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
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_buttons addObject:button];
        if ([key isEqual:lastKey]) {
            _shortcutController.staticViews = @[button];
        }
    }

    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(changToRightTab:)];
	[swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
}

- (void)shortcutViewController:(ShortCutViewController*)controller OrdersDidUpdate:(NSArray*)newOrders
{
    NSLog(@"New orders: %@", newOrders);
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
//    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    NSLog(@"Hello, %@ is clicked.  %@   %@", sender.titleLabel.text, _scrollView, NSStringFromCGSize(_scrollView.contentSize) );
}

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
