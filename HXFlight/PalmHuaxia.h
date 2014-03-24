//
//  PalmHuaxia.h
//  HXFlight
//
//  Created by Can EriK Lu on 3/21/14.
//  Copyright (c) 2014 Can EriK Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PalmHuaxia : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *marginBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *marginTop;
@property (assign, nonatomic) BOOL fromSwiping;
@end
