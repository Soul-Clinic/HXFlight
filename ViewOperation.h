//
//  ViewOperation.h
//  HXFlight
//
//  Created by Can EriK Lu on 3/22/14.
//  Copyright (c) 2014 Can EriK Lu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewOperation : NSObject


/**
 Layout the subviews in a auto-calculated average sub views vertically margin
 @param subivews
 	The sub views to be layouted in the scrollview
 @param scrollView
 	The scroll view to layout the sub views

 @return The pages count totally to layout such subviews
 */
+ (int)layoutSubviews:(NSArray*)subviews inScrollView:(UIScrollView*)scrollView;

/**
 Layout the subviews in a scroll view, the subviews are supposed to be in the same size, and you can set the contentInset of the scroll view before calling
 @param subivews
 	The sub views to be layouted in the scrollview
 @param scrollView
 	The scroll view to layout the sub views
 @param subviewMarginTop
 	The space between the two lines of subviews vertically

 @return The pages count totally to layout such subviews
 */
+ (int)layoutSubviews:(NSArray*)subviews inScrollView:(UIScrollView*)scrollView subviewMarginTop:(float)marginTop;


/**
 Layout the subviews in a scroll view, the subviews are supposed to be in the same size, and you can set the contentInset of the scroll view before calling
 @param subivews
 The sub views to be layouted in the scrollview
 @param scrollView
 The scroll view to layout the sub views
 @param subviewMarginTop
 The space between the two lines of subviews vertically
 @param counts
 An array containing the max subview counts in every page, if it's nil, it will layout as many subviews as possible in every page
 
 @return The pages count totally to layout such subviews
 */
+ (int)layoutSubviews:(NSArray*)subviews inScrollView:(UIScrollView*)scrollView subviewMarginTop:(float)marginTop countInPages:(NSArray*)counts;
@end
