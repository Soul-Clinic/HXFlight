//
//  FirstViewController.h
//  HXFlight
//
//  Created by Can EriK Lu on 3/21/14.
//  Copyright (c) 2014 Can EriK Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShortCutViewController.h"
@interface Home : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *marginBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *marginTop;

@property (strong, nonatomic, readonly) UIImage* screenshot;
@property (weak, nonatomic) IBOutlet UIImageView *background;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)pageChanged:(UIPageControl *)sender;
@end
