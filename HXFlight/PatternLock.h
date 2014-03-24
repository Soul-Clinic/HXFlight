//
//  PatterLock.h
//  HXFlight
//
//  Created by Can EriK Lu on 3/24/14.
//  Copyright (c) 2014 Can EriK Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatternLockView.h"

@interface PatternLock : UIViewController <PatternLockViewDelegate>
@property (weak, nonatomic) IBOutlet PatternLockView *pattern;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end
