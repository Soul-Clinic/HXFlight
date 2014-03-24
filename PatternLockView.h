//
//  PatternLockView.h
//  HXFlight
//
//  Created by Can EriK Lu on 3/24/14.
//  Copyright (c) 2014 Can EriK Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PatternLockViewDelegate;

@interface PatternLockView : UIView

/**
 Only scale to fit mode
 */
@property (strong, nonatomic) UIImage* background;
@property (strong, nonatomic) UIImage* normalDot;
@property (strong, nonatomic) UIImage* selectedDot;
@property (strong, nonatomic) UIImage* errorDot;
@property (strong, nonatomic) UIColor* normalColor;
@property (strong, nonatomic) UIColor* errorColor;
@property (strong, nonatomic) UIColor* successColor;
@property (strong, nonatomic) UIColor* shadowColor;
@property (strong, nonatomic, readonly) NSString* value;
@property (assign, nonatomic, readonly) int selectedDotNumber;
@property (assign, nonatomic) int column;
@property (assign, nonatomic) CGSize dotSize;
@property (assign, nonatomic) float lineWidthFactor;
@property (assign, nonatomic) float margin;
@property (assign, nonatomic) BOOL enabled;
/**
 The accuracy of selection area, should be 0 ~ 1.0
 1.0 means you should move very closely to the center of the dot, 0 means as soon as you touch the dot, you will select it
 Default is 0.3
*/
@property (assign, nonatomic) float accuracy;
@property (readonly, nonatomic) BOOL isDrawing;
@property (assign) id<PatternLockViewDelegate>delegate;

- (void)showInErrorMode;
- (void)showInSuccessMode;
- (void)clear;
- (void)updateCoordinate;
@end



@protocol PatternLockViewDelegate <NSObject>

- (void)patternLockView:(PatternLockView*)patternLockView didFinishWithValue:(NSString*)value;

@end