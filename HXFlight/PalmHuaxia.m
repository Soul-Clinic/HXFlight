//
//  PalmHuaxia.m
//  HXFlight
//
//  Created by Can EriK Lu on 3/21/14.
//  Copyright (c) 2014 Can EriK Lu. All rights reserved.
//

#import "PalmHuaxia.h"
#import "More.h"
#import "ViewOperation.h"
@interface PalmHuaxia ()
{
    NSMutableArray*	_buttons;
    UIImageView* _rightScreenshot;
    NSDictionary* shortcuts;
    CGRect scrollFrame;
}
@end

@implementation PalmHuaxia

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _marginBottom.constant = self.tabBarController.tabBar.height;
    if (!isiOS7()) {
        _marginBottom.constant = 0;
        _marginTop.constant = 0;
    }
    shortcuts = @{@"消息通知":@"1",
                  @"管理决策":@"2",
                  @"我的工作":@"3",
                  @"我的计划":@"4",
                  @"我的任务":@"5",
                  @"我的日程":@"6",
                  @"个人信息":@"7",
                  @"我的职责":@"8",
                  @"我的文件":@"9",
                  @"我的收藏":@"10",
                  @"薪资福利":@"11",
                  @"运行控制":@"12",
                  @"服务质量":@"13",
                  @"维修管理":@"14",
                  @"安全管理":@"15",
                  @"市场营销":@"16",
                  @"财务管理":@"17",
                  @"人力资源":@"18",
                  @"行政管理":@"19",
                  @"企业管理":@"20" };

    NSArray* allKeys = shortcuts.allKeys;
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
        _scrollView.contentInset = UIEdgeInsetsMake(16, 0, 0, 0);
    }
}
- (void)viewDidLayoutSubviews
{
	if (CGRectEqualToRect(scrollFrame, CGRectZero) || !CGRectEqualToRect(scrollFrame, _scrollView.frame)) {
        scrollFrame = _scrollView.frame;
        [ViewOperation layoutSubviews:_buttons inScrollView:_scrollView subviewMarginTop:17 countInPages:@[@11, @9, @0]];
    }
    _scrollView.contentOffset = CGPointMake(_scrollView.width, -_scrollView.contentInset.top);
    if (_fromSwiping) {
        _scrollView.contentOffset = CGPointMake(_scrollView.width * 2, -_scrollView.contentInset.top);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!_rightScreenshot) {
        _rightScreenshot = [[UIImageView alloc] initWithFrame:self.view.frame];
        _rightScreenshot.y = -_scrollView.contentInset.top;
        _rightScreenshot.x = _scrollView.width * 2;
        _rightScreenshot.contentMode = UIViewContentModeTop;
        [_scrollView addSubview:_rightScreenshot];
    }

	if (_fromSwiping) {
        More* more = self.tabBarController.viewControllers[3];
        _rightScreenshot.image = more.screenshot;
    }

}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (_fromSwiping) {
        [_scrollView setContentOffset:CGPointMake(_scrollView.width, -_scrollView.contentInset.top) animated:YES];
        _fromSwiping = NO;
    }
    else {
        More* more = self.tabBarController.viewControllers[3];
        _rightScreenshot.image = more.screenshot;
    }
}

- (IBAction)buttonClicked:(UIButton*)sender
{
    NSLog(@"Hello, %@ is clicked.", sender.titleLabel.text);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.tabBarController.selectedIndex = page + 1;
}
@end
