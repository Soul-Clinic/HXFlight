//
//  PatternLockView.m
//  HXFlight
//
//  Created by Can EriK Lu on 3/24/14.
//  Copyright (c) 2014 Can EriK Lu. All rights reserved.
//

#import "PatternLockView.h"



@interface PatternLockView ()
{
    NSMutableArray* selections;
    CGPoint** coordinates;
    BOOL drawing, inError, inSuccess, initialized;
    BOOL** dotSelected;
    CGPoint currentLocation;
}
@end

@implementation PatternLockView

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
	if (self) {
        [self initialize];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self initialize];
    }
    return self;
}
- (void)initialize
{
    self.enabled = YES;
    self.normalDot = [UIImage imageNamed:@"dot_normal"];
    self.selectedDot = [UIImage imageNamed:@"dot_select"];
    self.dotSize = CGSizeMake(49, 49);
    self.lineWidthFactor = 0.18;
    self.normalColor = rgba(31, 96, 212, 0.71);
    self.errorColor = rgba(182, 66, 145, 0.52); //rgba(150, 40, 132, 0.71);//rgba(199, 45, 45, 0.6);
    self.successColor = rgba(139, 201, 60, 0.8);
    self.shadowColor = rgba(0, 0, 0, 0.5);
    self.margin = UIEdgeInsetsMake(40, 30, 0, 30);
    self.column = 3;
    self.accuracy = 0.3;
	self.background = nil;
    self.errorDot = [UIImage imageNamed:@"dot_error"];

    selections = [NSMutableArray array];
	initialized = YES;
}

- (void)setAccuracy:(float)accuracy
{
    if (accuracy >= 0. && accuracy <= 1) {
        _accuracy = accuracy;
    }
}
- (void)setBackground:(UIImage *)background
{
    _background = background;
    [self setNeedsDisplay];
}
- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
    if (initialized) {
        [self updateCoordinate];
    }

}
- (void)setMargin:(UIEdgeInsets)margin
{
    _margin = margin;
    if (initialized) {
        [self updateCoordinate];
    }
}
- (void)setDotSize:(CGSize)dotSize
{
	_dotSize = dotSize;
    if (initialized) {
        [self updateCoordinate];
    }
}
- (void)setColumn:(int)column
{
    if (column < 2) {
        NSLog(@"Error: column is too small");
    }
    if (column * _dotSize.width + _margin.left + _margin.right >= self.width &&
        column * _dotSize.height + _margin.top + _margin.bottom >= self.height) {
        NSLog(@"Error: column is too large, you can try to reduce the dot size before setting this");
    }
    else {
        if (coordinates && dotSelected) {
            [self free];
        }

        _column = column;
        coordinates = malloc(sizeof(CGPoint*) * column);
        dotSelected = malloc(sizeof(BOOL*) * column);
        for (int i = 0; i < column; i++) {
            coordinates[i] = malloc(sizeof(CGPoint) * column);
            dotSelected[i] = malloc(sizeof(BOOL) * column);
            for (int j = 0; j < column; j++) {
                dotSelected[i][j] = NO;
            }
        }
        if (initialized) {
            [self updateCoordinate];
        }
    }
}

- (void)updateCoordinate
{
    float x, y, dw = MAX(_dotSize.width, _dotSize.height), padding,
    w = self.width - _margin.left - _margin.right,
    h = self.height - _margin.top - _margin.bottom;

	if (h > w) {
        x = _margin.left;
        y = (h - w) / 2 + _margin.top;

        padding = (w - _column * dw) / (_column - 1);
        for (int i = 0; i < _column; i++) {
            for (int j = 0; j < _column; j++) {
                coordinates[i][j] = CGPointMake(x + j * (dw + padding), y + i * (dw + padding));
            }
        }

    }
    else {
		y = _margin.top;
        x = (w - h) / 2 + _margin.left;
        padding = (h -  _column * dw) / (_column - 1);
        for (int i = 0; i < _column; i++) {
            for (int j = 0; j < _column; j++) {
                coordinates[i][j] = CGPointMake(x + j * (dw + padding), y + i * (dw + padding));
            }
        }
    }
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateCoordinate];
}
- (void)drawRect:(CGRect)rect
{

    // Draw the background, if needed
    if (_background) {
        [_background drawInRect:self.frame];
    }
    // Draw the dots
    for (int i = 0; i < _column; i++) {
        for (int j = 0; j < _column; j++) {
            CGPoint p = coordinates[i][j];
            UIImage* image = dotSelected[i][j] ? (inError ? _errorDot : _selectedDot) : _normalDot;
			[image drawInRect:CGRectMake(p.x, p.y, _dotSize.width, _dotSize.height)];
        }
    }
    // Draw the lines
    if (selections.count > 0) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextSetStrokeColorWithColor(ctx, (inError ? _errorColor.CGColor : (inSuccess ? _successColor.CGColor :_normalColor.CGColor)));
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 5, _shadowColor.CGColor);
		CGContextSetLineWidth(ctx, MAX(_dotSize.width, _dotSize.height) * _lineWidthFactor);
		CGContextSetLineJoin(ctx, kCGLineJoinRound);

        CGPoint first = coordinates[[selections[0][0] intValue]][[selections[0][1] intValue]];
        CGPoint center = CGPointMake(first.x + _dotSize.width / 2, first.y + _dotSize.height / 2);
        CGContextMoveToPoint(ctx, center.x, center.y);

        for (int n = 0; n < selections.count - 1; n++) {
            CGPoint p2 = coordinates[[selections[n+1][0] intValue]][[selections[n+1][1] intValue]];
            center = CGPointMake(p2.x + _dotSize.width / 2, p2.y + _dotSize.height / 2);
            CGContextAddLineToPoint(ctx, center.x, center.y);
        }
        if (_isDrawing) {
            CGContextAddLineToPoint(ctx, currentLocation.x, currentLocation.y);
        }

        CGContextStrokePath(ctx);
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if (!_enabled) {
        return;
    }
    UITouch* touch = [touches anyObject];
    CGPoint t = [touch locationInView:self];
    BOOL inside = NO;
    for (int i = 0; i < _column; i++) {
        for (int j = 0; j < _column; j++) {
            CGPoint p = coordinates[i][j];
			if (t.x >= p.x && t.x <= (p.x + _dotSize.width) && t.y > p.y && t.y < (p.y + _dotSize.height)) {
                if (!dotSelected[i][j]) {
                    [selections addObject:@[[NSNumber numberWithInt:i], [NSNumber numberWithInt:j]]];
                }
                dotSelected[i][j] = YES;
                inside = YES;

                break;
            }
        }
        if (inside) {
            break;
        }
    }
    currentLocation = t;
    _isDrawing = YES;
    [self setNeedsDisplay];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (!_enabled) {
        return;
    }
    UITouch* touch = [touches anyObject];
    CGPoint t = [touch locationInView:self];
    BOOL inside = NO;
    float w = _dotSize.width, h = _dotSize.height;
    float f1 = 0.45 * _accuracy, f2 = 1 - f1;
    for (int i = 0; i < _column; i++) {
        for (int j = 0; j < _column; j++) {
            CGPoint p = coordinates[i][j];
			if (t.x >= p.x + f1 * w && t.x <= (p.x + f2 * w) && t.y > p.y + f1 * h && t.y < (p.y + f2 * h)) {
                if (!dotSelected[i][j]) {
                    [selections addObject:@[[NSNumber numberWithInt:i], [NSNumber numberWithInt:j]]];
                }
                dotSelected[i][j] = YES;
                inside = YES;
                break;
            }
        }
        if (inside) {
            break;
        }
    }
	currentLocation = t;
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    _isDrawing = NO;
    NSMutableString* mString = [NSMutableString string];
    for (NSArray* coordinate in selections) {
        NSNumber* x = coordinate[0];
        NSNumber* y = coordinate[1];
        [mString appendFormat:@"(%@,%@) ", x, y];
    }
    _value = [mString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	_selectedDotNumber = (int)selections.count;
    [self setNeedsDisplay];
	if (_selectedDotNumber && [self.delegate respondsToSelector:@selector(patternLockView:didFinishWithValue:)]) {
        [self.delegate patternLockView:self didFinishWithValue:self.value];
    }
    
}

- (void)showInErrorMode
{
    inError = YES;
    [self setNeedsDisplay];
}
- (void)showInSuccessMode
{
	inSuccess = YES;
    [self setNeedsDisplay];
}
- (void)clear
{
	for (int i = 0; i < _column; i++) {
        for (int j = 0; j < _column; j++) {
            dotSelected[i][j] = NO;
        }
    }
    inError = NO;
    inSuccess = NO;
    [selections removeAllObjects];
    _value = nil;
    _selectedDotNumber = 0;
    [self setNeedsDisplay];
}

- (void)dealloc
{
	[self free];
}
- (void)free
{
    for (int i = 0; i < _column; i++) {
        free(coordinates[i]);
        free(dotSelected[i]);
    }
    free(coordinates);
    free(dotSelected);
}
@end
