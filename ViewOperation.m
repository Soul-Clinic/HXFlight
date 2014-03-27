//
//  ViewOperation.m
//  HXFlight
//
//  Created by Can EriK Lu on 3/22/14.
//  Copyright (c) 2014 Can EriK Lu. All rights reserved.
//

#import "ViewOperation.h"

@implementation ViewOperation

+ (int)layoutSubviews:(NSArray*)subviews inScrollView:(UIScrollView*)scrollView;
{
    return [self layoutSubviews:subviews inScrollView:scrollView subviewMarginTop:-1 countInPages:nil];
}
+ (int)layoutSubviews:(NSArray*)subviews inScrollView:(UIScrollView*)scrollView subviewMarginTop:(float)marginTop
{
    return [self layoutSubviews:subviews inScrollView:scrollView subviewMarginTop:marginTop countInPages:nil];
}
+ (int)layoutSubviews:(NSArray*)subviews inScrollView:(UIScrollView*)scrollView subviewMarginTop:(float)marginTop countInPages:(NSArray*)counts
{
    NSLog(@"Start layouting");

	CGSize viewSize = [subviews.firstObject frameSize];
    CGSize contentSize = UIEdgeInsetsInsetRect(scrollView.frame, scrollView.contentInset).size;
    float columns, rows, pages;
    columns = floorf( contentSize.width / (viewSize.width * 1.2));
    rows = MAX(floorf(contentSize.height / (viewSize.height * 1.1)), 1);

    const float pageSize = columns * rows;
	NSMutableArray* actualCounts = [NSMutableArray array];
	if (!counts) {
        pages = ceilf(subviews.count / pageSize);
        for (int i = 0; i < pages - 1; i++) {
            [actualCounts addObject:[NSNumber numberWithFloat:pageSize]];
        }
		[actualCounts addObject:[NSNumber numberWithFloat:subviews.count - (pages - 1) * pageSize]];
    }
    else {
        int totoalCount = 0;
        for (NSNumber* count in counts) {
            float size = ceilf(MAX(count.floatValue, 1) / pageSize);
			for (int i = 0; i < size - 1; i++) {
                [actualCounts addObject:[NSNumber numberWithFloat:pageSize]];
            }
            [actualCounts addObject:[NSNumber numberWithFloat:count.floatValue - (size - 1) * pageSize]];
            pages += size;
            totoalCount += count.intValue;

        }
        if (totoalCount != subviews.count) {
            NSLog(@"Error: The total subviews number is not equal to total count in the counts array");
            return 0;
        }
    }
	UIEdgeInsets orgin = scrollView.contentInset;
	scrollView.contentSize = CGSizeMake(scrollView.width * pages, contentSize.height);
	scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top, 0, scrollView.contentInset.bottom, 0);

    float marginLeft = (contentSize.width - viewSize.width * columns) / (columns + 1);
    if (marginTop < 0) {
        marginTop = (contentSize.height - rows * viewSize.height) / (rows + 1);
    }
	int n = 0;
	for (int p = 0 ; p < pages; p++) {
        for (int i = 0; i < [actualCounts[p] intValue]; i++) {

            float row = floorf(i  / columns),
            column = i - row * columns;

            UIView* view = subviews[n++];
            view.x = marginLeft + column * (viewSize.width + marginLeft) + p * scrollView.width + orgin.left;
            view.y = marginTop + row * (viewSize.height + marginTop);
            [scrollView addSubview:view];
        }

    }

    return (int)pages;
}

@end
