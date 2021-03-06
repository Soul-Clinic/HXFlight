//
//  ShortCutViewController.m
//  LayoutShortcuts
//
//  Created by Can EriK Lu on 3/29/14.
//  Copyright (c) 2014 Can EriK Lu. All rights reserved.
//

#import "ShortCutViewController.h"
#import "Common.h"
#import <AudioToolbox/AudioToolbox.h>

#define kShakeAnimationKey		@"shaking"
#define kScaleAnimationKey		@"scale"
#define kPressAlpha				0.9
#define kShakeAngle				(10.0 / 180.0 * M_PI)
#define kShakeTimeframe			0.1
#define kStandardDuration       0.8
#define kMoveDuration			0.5
#define kPressScaleFactor		1.3
#define kLocationScrollBorder	25.0

#define kQuietTimeTotal					0.3
#define kQuietTimeIntervalBetween		0.1
#define kMaxDistanceForQuiet			10.0

#define kMaxDifferInSameLine            12.0


enum LocationClass
{
	kLocationOutsideShortcuts 	= -1,
	kLocationScrollLeft			= -2,
	kLocationScrollRight		= -3,
	kLocationScrollTop			= -4,
	kLocationScrollBottom		= -5
};

@interface ShortCutViewController ()
{
	NSMutableArray* _shortcuts, *_origins, *_orders, *_records;
	UIView* _pressingView, *_containerView;
	float _zPosition;
	int _currentIndex, _destinationIndex, _appending, _pageIndex;
	BOOL _layoutUpdated, _firing, _justEnd, _moving, _initialized;
	CGPoint _currentLocation, _lastOffset;
}
@end

@implementation ShortCutViewController

- (void)_init
{
	_shortcuts = [NSMutableArray array];
	_origins = [NSMutableArray array];
    _orders = [NSMutableArray array];
    _staticViews = @[];
    _alignStaticViews = YES;
	_currentIndex = _destinationIndex = kLocationOutsideShortcuts;
}
- (id)init
{
	self = [super init];
	if (self) {
		[self _init];
	}
	return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self _init];
	}
	return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		[self _init];
	}
	return self;
}
- (void)loadView
{
	[super loadView];
    // Do any additional setup after loading the view.
	_scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
	for (UIView* subview in self.view.subviews) {
		[self.scrollView addSubview:subview];
	}
	_scrollView.backgroundColor = self.view.backgroundColor;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
	self.view = _scrollView;

}

- (void)viewDidLayoutSubviews
{
    if (!_initialized) {
        [self updateSubviews];
//        [self alignShortcuts];
        _initialized = YES;
        self.view.superview.backgroundColor = [UIColor clearColor];
    }
    if (_scrollView.contentSize.width == 0) {
        _scrollView.contentSize = [self _minContentSizeToWrapViews:_shortcuts];
        _scrollView.contentOffset = _lastOffset;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

    if (_scrollView.contentSize.width == 0) {
        _scrollView.contentSize = [self _minContentSizeToWrapViews:_shortcuts];
    }

    _containerView = _scrollView.superview.superview;
    if (_containerView == nil) {
        _containerView = _scrollView.superview;
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    _lastOffset = _scrollView.contentOffset;
}

- (CGSize)_minContentSizeToWrapViews:(NSArray*)views
{
    if (_vertical) {
        CGSize size = CGSizeMake(_scrollView.width, 0);
        float height = 0;
        for (UIView* subview in views) {
            if (subview.bottom > height) {
                height = subview.bottom;
            }
        }
        height = ceilf(height / _scrollView.height) * _scrollView.height;
        size.height = height;
        return size;
    }
    else {
        CGSize size = CGSizeMake(0, _scrollView.height);
        float width = 0;
        for (UIView* subview in views) {
            if (subview.right > width) {
                width = subview.right;
            }
        }
        width = ceilf(width / _scrollView.width) * _scrollView.width;
        size.width = width;
        return size;
    }
}


- (void)alignShortcuts
{
    [self _resortShortcutsIndex];

    CGSize size = [_shortcuts.firstObject frameSize];      //Assume all are in the same size
    if (UIEdgeInsetsEqualToEdgeInsets(_margins, UIEdgeInsetsZero)) {
        _margins.left = (_scrollView.width - size.width * _columns) / _columns / 2;
        _margins.right = _margins.left;
        _margins.top = (_scrollView.height - size.height * _rows) / _rows / 2;
        _margins.bottom = _margins.top;
    }
    int pageSize = (int)(_columns * _rows);
    [UIView animateWithDuration:0.4 animations:^{
        int staticPass = 0;
        for (int n = 0; n < _shortcuts.count; ++n) {
            int i = n + staticPass;
            int page = i / pageSize,
            row = (i % pageSize) / (int)_columns,
            col = i % _columns;

            UIView* shortcut = _shortcuts[n];
            float x = (_vertical ? 0 : page * _scrollView.width) + (col + 1) * _margins.left
            + col * _margins.right + col * shortcut.width ;
            float y = (_vertical ? page * _scrollView.height : 0) + (row + 1) * _margins.top
            + row * _margins.bottom + row * shortcut.height;
            CGRect frame = CGRectMake(x, y, shortcut.width, shortcut.height);


            BOOL intersect = NO;
            for (UIView* staticView in _staticViews) {
                if (CGRectIntersectsRect(frame, staticView.frame)) {
                    staticPass++;
                    n--;
                    intersect = YES;
                    if (_alignStaticViews) {
                        staticView.frame = frame;
                    }
                    break;
                }
            }

            if (!intersect) {
                shortcut.frame = frame;
            }

        }
    } completion:^(BOOL finished) {
        [self updateSubviews];
    }];

}
- (void)setColumns:(int)columns
{
	if (_columns != columns) {
		_columns = columns;
		[self alignShortcuts];
	}
}
- (void)setRows:(int)rows
{
	if (_rows != rows) {
		_rows = rows;
		[self alignShortcuts];
	}
}

- (void)updateSubviews
{
	[_shortcuts removeAllObjects];
	[_origins removeAllObjects];
	for (UIView* aView in _scrollView.subviews) {
		if (CGSizeEqualToSize(aView.frame.size, CGSizeZero)
            || aView.userInteractionEnabled == NO
            || [_staticViews indexOfObject:aView] != NSNotFound) {
            for (UIGestureRecognizer* ges in aView.gestureRecognizers) {
                if ([ges isKindOfClass:[UILongPressGestureRecognizer class]]) {
                    [aView removeGestureRecognizer:ges];
                }
            }

			continue;						//Get rid of the UILayoutGuid
		}
		BOOL existed = NO;
		if (aView.gestureRecognizers) {
			for (UIGestureRecognizer* gesture in aView.gestureRecognizers) {
				if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
					existed = YES;
					break;
				}
			}
		}
		if (!existed) {
			UILongPressGestureRecognizer* lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPressGesture:)];
			[aView addGestureRecognizer:lp];
		}

		[_shortcuts addObject:aView];
	}
    //Update origins and orders
	[self _resortShortcutsIndex];
    [_orders removeAllObjects];
	for (int i = 0; i < _shortcuts.count; ++i) {
		UIView* aView = _shortcuts[i];
		aView.layer.zPosition = i;
		[_origins addObject:[NSValue valueWithCGPoint:aView.origin]];
        [_orders addObject:[NSNumber numberWithInt:i]];
	}
    if (_columns == 0 || _rows == 0) {
        [self _calculateColumnRow];
    }

}
- (void)setStaticViews:(NSArray *)staticViews
{
    _staticViews = staticViews;
    if (_initialized) {
        [self updateSubviews];
    }
}

- (void)_calculateColumnRow
{

	float minX = MAXFLOAT, minY = MAXFLOAT;
    NSArray* allViews = [_shortcuts arrayByAddingObjectsFromArray:_staticViews];
	for (UIView* view in allViews) {
        if (!CGRectContainsPoint(_scrollView.frame, view.center)) {     //Only calculate the first page
            continue;
        }
        minX = MIN(view.x, minX);
		minY = MIN(view.y, minY);
	}
	_columns = 0;
    _rows = 0;
	for (UIView* view in allViews) {
        if (!CGRectContainsPoint(_scrollView.frame, view.center)) {     //Only calculate the first page
            continue;
        }
		if (view.y - minY < kMaxDifferInSameLine) {
			_columns++;
		}
        if (view.x - minX < kMaxDifferInSameLine) {
            _rows++;
        }
	}
}
- (int)_pressingIndex
{
	return [self _indexAtPosition:_currentLocation];
}
- (int)_indexAtPosition:(CGPoint)point
{
    point = [_scrollView convertPoint:point fromView:_containerView];

	static float scWidth, scHeight, paddingX, paddingY;
	float currentPage, totalPages, x, y;
    currentPage = [self _currentPage];

	if (self.vertical == NO) {
		totalPages = _vertical ? : ceilf(_scrollView.contentSize.width / _scrollView.width),
		x = point.x - _scrollView.contentOffset.x;

		if (x < kLocationScrollBorder && currentPage > 0) {
			return kLocationScrollLeft;
		}
		else if (x > _scrollView.width - kLocationScrollBorder && currentPage < totalPages - 1) {
			return kLocationScrollRight;
		}
	}
	else
	{
		totalPages = ceilf(_scrollView.contentSize.height / _scrollView.height);
		y = point.y - _scrollView.contentOffset.y;

		if (y < kLocationScrollBorder && currentPage > 0) {
			return kLocationScrollTop;
		}
		else if (y > _scrollView.height - kLocationScrollBorder && currentPage < totalPages - 1) {
			return kLocationScrollBottom;
		}
	}

	if (_origins.count == 1) {
		CGPoint pt = [_origins.firstObject CGPointValue];
		if (point.x >  pt.x - paddingX && point.x < pt.x + paddingX + _pressingView.width
			&& point.y > pt.y - paddingY && point.y< pt.y + paddingY + _pressingView.height) {
			return 0;
		}
		else {
			return kLocationOutsideShortcuts;
		}
	}

	if (!scWidth) {
		UIView* sc = _shortcuts.firstObject;
		scWidth = sc.width;
		scHeight = sc.height;
		CGPoint pt1 =  [_origins[0] CGPointValue],
		pt2 =  [_origins[1] CGPointValue],
		pt3 = [_origins[_columns] CGPointValue];
		float distanceX = pt2.x - pt1.x - scWidth, distanceY = pt3.y - pt1.y - scHeight;
		paddingX = MAX(0.0, distanceX * 0.5);
		paddingY = MAX(0.0, distanceY * 0.5);
	}
	for (int i = 0; i < _origins.count; ++i) {
		CGPoint pt = [_origins[i] CGPointValue];
		if (point.x >  pt.x - paddingX && point.x < pt.x + paddingX + scWidth
			&& point.y > pt.y - paddingY && point.y< pt.y + paddingY + scHeight) {
			return i;
		}
	}
	return kLocationOutsideShortcuts;
}

- (void)_offsetDetection:(NSTimer *)timer
{
	static NSMutableArray* distances;
	static CGPoint lastLocation;
	static float offset;
	static int index, count;

	if (distances != timer.userInfo) {
		distances = timer.userInfo;
		lastLocation = _currentLocation;
		index = 0;
		count = (int)distances.count;
		_firing = NO;
	}


	if (_firing) {
		int lastIndex = (index - 1 + count) % count;
		distances[lastIndex] = [NSNumber numberWithFloat:kMaxDistanceForQuiet];
		return;
	}

	offset = sqrtf(powf(_currentLocation.x - lastLocation.x, 2) + powf(_currentLocation.y - lastLocation.y, 2));

	distances[index] = [NSNumber numberWithFloat:offset];
	index = (index + 1) % count;
	float totalDistance = 0;

	for (NSNumber* distance in distances) {
		totalDistance += distance.floatValue;
	}
	if (totalDistance < kMaxDistanceForQuiet) {
		if (!_firing) {
			_firing = YES;
			[self _updateLayout];
		}
	}

	lastLocation = _currentLocation;
}

- (void)_handleLongPressGesture:(UILongPressGestureRecognizer*)gesture
{
	static CGPoint start, beginLocation, currentOrigin;
	static NSTimer* timer;
	UIView* shortcut = gesture.view;
	CALayer* layer = shortcut.layer;

	if (_pressingView && _pressingView != shortcut) {		//Multiple touches
		return;
	}

	switch (gesture.state) {
		case UIGestureRecognizerStateBegan:
		{
            if (_vibrateOnResort) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);			//Only work on iPhone
            }

			shortcut.alpha *= kPressAlpha;
			beginLocation = [gesture locationInView:_containerView];
			_currentLocation = beginLocation;
			_zPosition = layer.zPosition;
			_currentIndex = [self _pressingIndex];
			_pressingView = shortcut;

            CGPoint origin = [_scrollView convertPoint:_pressingView.origin toView:_containerView];
            [_containerView addSubview:_pressingView];
            _pressingView.origin = origin;
			start = _pressingView.origin;

			layer.zPosition = 100;

			[layer addAnimation:[self _scaleAnimationFactor:kPressScaleFactor duration:0.2 * kStandardDuration] forKey:kScaleAnimationKey];
			for (UIView* aView in _shortcuts) {
				if (aView != shortcut) {
					[aView.layer addAnimation:[self _shakeAnimationAngle:kShakeAngle duration:kShakeTimeframe] forKey:kShakeAnimationKey];
				}
			}

			int count = ceilf(kQuietTimeTotal / kQuietTimeIntervalBetween);
			NSMutableArray* distances = [NSMutableArray arrayWithCapacity:count];
			for (int i = 0; i < count; ++i) {
				distances[i] = @0;
			}

			if (timer) {
				[timer invalidate];
			}
			timer = [NSTimer scheduledTimerWithTimeInterval:kQuietTimeIntervalBetween target:self selector:@selector(_offsetDetection:) userInfo:distances repeats:YES];
            if ([timer respondsToSelector:@selector(setTolerance:)]) {
                timer.tolerance = 0.06;
            }

            _records = [_shortcuts copy];
			break;
		}
		case UIGestureRecognizerStateChanged:
		{
			_currentLocation = [gesture locationInView:_containerView];
			currentOrigin = CGPointMake(start.x + (_currentLocation.x - beginLocation.x),
										start.y + (_currentLocation.y - beginLocation.y));
			shortcut.origin = currentOrigin;

			break;
		}
		case UIGestureRecognizerStateEnded:
		{
			[timer invalidate];
			if (!_firing || _moving) {
				[self _layBackPressingView];
			}
			else {
				_justEnd = YES;
			}

			break;
		}
		default:
            NSLog(@"Fail gesture? %i", (int)gesture.state);
			break;
	}
}

- (void)_layBackPressingView
{
	CALayer* layer = _pressingView.layer;
	layer.transform = [((CALayer*)layer.presentationLayer) transform];
	[layer removeAnimationForKey:kScaleAnimationKey];

    [self _resortShortcutsIndex];
	float duration = (_currentIndex >= 0 ? 0.2 : 0.6) * kStandardDuration;
    _scrollView.scrollEnabled = NO;
	[UIView animateWithDuration:duration
						  delay:0
						options:UIViewAnimationOptionBeginFromCurrentState
					 animations:^{
						 _pressingView.alpha /= kPressAlpha;
						 layer.transform = CATransform3DIdentity;
                         NSUInteger index = [_shortcuts indexOfObject:_pressingView];
                         CGPoint origin = [_scrollView convertPoint:[_origins[index] CGPointValue] toView:_containerView] ;
                         _pressingView.origin = origin;
                         CGPoint current = [_scrollView convertPoint:[_origins[index] CGPointValue] toView:_scrollView.superview];
                         if (!CGRectContainsPoint(_scrollView.superview.bounds, current)  ) {
                             _pressingView.alpha = 0.0;
                         }

						 if (_layoutUpdated) {
							 for (int i = 0; i < _shortcuts.count; ++i) {
								 UIView* shortcut = _shortcuts[i];
                                 if (shortcut != _pressingView) {
                                     shortcut.origin = [_origins[i] CGPointValue];
                                 }
							 }
						 }
					 }
					 completion:^(BOOL finished) {
						 layer.zPosition = _zPosition;
						 for (UIView* shortcut in _shortcuts) {
							 [shortcut.layer removeAnimationForKey:kShakeAnimationKey];
						 }
                         _pressingView.alpha = 1.0;
                         CGPoint origin = [_scrollView convertPoint:_pressingView.origin fromView:_containerView];
                         _pressingView.origin = origin;
                         [_scrollView addSubview:_pressingView];
						 _currentIndex = kLocationOutsideShortcuts;
						 _pressingView = nil;
						 _appending = NO;
						 _layoutUpdated = NO;
                         _justEnd = NO;
                         _scrollView.scrollEnabled = YES;
						 [self _resortShortcutsIndex];
                         NSMutableArray* temp = [NSMutableArray array];
                         for (int i = 0; i < _shortcuts.count; ++i) {
                             [temp addObject:_orders[[_records indexOfObject:_shortcuts[i]]]];
                         }
                         _orders = temp;
                         if ([_delegate respondsToSelector:@selector(shortcutViewController:OrdersDidUpdate:)]) {
                             [_delegate shortcutViewController:self OrdersDidUpdate:[NSArray arrayWithArray:_orders]];
                         }

					 }];
}
- (void)_resortShortcutsIndex
{
	if (_pressingView) {
		[_shortcuts removeObject:_pressingView];
	}
	float pageWidth = _scrollView.width;

	[_shortcuts sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		UIView* view1 = obj1, *view2 = obj2;
		float vertical = fabsf(view1.y - view2.y), horizontal = view1.x - view2.x;
		float pageIndex1= floorf(view1.x / pageWidth), pageIndex2 = floorf(view2.x / pageWidth);

		if (pageIndex1 != pageIndex2) {
			return pageIndex1 < pageIndex2 ? NSOrderedAscending : NSOrderedDescending;
		}

		if (vertical > kMaxDifferInSameLine || horizontal == 0) {
			return view1.y < view2.y ? NSOrderedAscending : NSOrderedDescending;
		}
		else if (horizontal != 0) {
			return view1.x < view2.x ? NSOrderedAscending : NSOrderedDescending;
		}
		return NSOrderedSame;
	}];

	if (_pressingView) {
		if (_currentIndex >= 0) {				//Outside means the last one, on that page
			[_shortcuts insertObject:_pressingView atIndex:_currentIndex];
		}
		else {

            float lastOne = [self _lastIndexInCurrentPage];
            if (_shortcuts.count < lastOne) {
                lastOne = _shortcuts.count;
            }

			[_shortcuts insertObject:_pressingView atIndex:lastOne];
		}
	}
}

- (CABasicAnimation*)_scaleAnimationFactor:(float)factor duration:(float)duration
{
	CABasicAnimation* scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scale.toValue = [NSNumber numberWithFloat:factor];
	scale.duration = duration;
	scale.delegate = self;
	scale.removedOnCompletion = NO;
	scale.fillMode = kCAFillModeForwards;
	scale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	return scale;
}
- (CABasicAnimation*)_shakeAnimationAngle:(float)angle duration:(float)duration
{
	CABasicAnimation* rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	rotate.fromValue = [NSNumber numberWithFloat:angle];
	rotate.toValue = [NSNumber numberWithFloat:-angle];
	rotate.duration = duration;
	rotate.beginTime = CACurrentMediaTime() + duration * (rand() % 100) / 100;
	rotate.autoreverses = YES;
	rotate.delegate = self;
	rotate.repeatCount = HUGE_VALF;
	return rotate;
}

- (void)_updateLayout
{
	_destinationIndex = [self _pressingIndex];

    if (_destinationIndex == _currentIndex) {
        _firing = NO;
        return;
    }

	if (_destinationIndex < 0 && _destinationIndex != kLocationOutsideShortcuts) {
		CGPoint offset = _scrollView.contentOffset;
		switch (_destinationIndex) {
			case kLocationScrollBottom:
				offset.y += _scrollView.height;
				break;
			case kLocationScrollTop:
				offset.y -= _scrollView.height;
				break;
			case kLocationScrollLeft:
				offset.x -= _scrollView.width;
				break;
			case kLocationScrollRight:
				offset.x += _scrollView.width;
				break;
			default:
				break;
		}

        [_scrollView setContentOffset:offset animated:YES];
        [self performSelector:@selector(endScrolling) withObject:nil afterDelay:0.5];
        return;
	} else {
        [self _rearrange];
	}
}
- (void)endScrolling
{
	if (_justEnd) {
		_justEnd = NO;
		[self _layBackPressingView];
	}
    else {
        [self performSelector:@selector(_resetScroll) withObject:nil afterDelay:0.5];
    }
    if ([_scrollView.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [_scrollView.delegate scrollViewDidEndDecelerating:_scrollView];
    }
}
- (void)_resetScroll
{
	_firing = NO;
    if (_justEnd) {
        [self _layBackPressingView];
    }
}

- (float)_currentPage
{
    float currentPage = _vertical ?  floorf(_scrollView.contentOffset.y / _scrollView.height) : floorf(_scrollView.contentOffset.x / _scrollView.width);
    return currentPage;
}
- (float)_lastIndexInCurrentPage
{
    float currentPage = [self _currentPage];
    float lastOne = (currentPage + 1) * _columns * _rows - 1;

    CGRect frame = _vertical ? CGRectMake(0, 0, _scrollView.width, _scrollView.height * (currentPage + 1)) :
    CGRectMake(0, 0, _scrollView.width * (currentPage + 1), _scrollView.height);
    for (UIView* aView in _staticViews) {
        if (CGRectContainsPoint(frame, aView.center)) {
            lastOne--;
        }
    }
    return lastOne;
}
- (void)_rearrange
{

    float lastOne = [self _lastIndexInCurrentPage];

    if (_shortcuts.count - 1 < lastOne) {
        lastOne = _shortcuts.count - 1;
    }

	if (_currentIndex == kLocationOutsideShortcuts) {				//Move in
		[self _moveShortcutsRangFrom:_destinationIndex to:lastOne - 1 directionForward:YES];
	}
	else if (_destinationIndex == kLocationOutsideShortcuts) {           //Move out
        _destinationIndex = lastOne;
        if (_currentIndex < lastOne) {
            [self _moveShortcutsRangFrom:_currentIndex + 1 to:lastOne directionForward:NO];
        }
        else if (_currentIndex > lastOne) {
            [self _moveShortcutsRangFrom:lastOne to:_currentIndex - 1 directionForward:YES];
        }
        else {
            _firing = NO;
        }
	}
	else if (_currentIndex < _destinationIndex) {
		[self _moveShortcutsRangFrom:_currentIndex + 1 to:_destinationIndex directionForward:NO];
	}
	else if (_currentIndex > _destinationIndex) {
		[self _moveShortcutsRangFrom:_destinationIndex to:_currentIndex - 1 directionForward:YES];
	}
}

- (void)_moveShortcutsRangFrom:(int)first to:(int)last directionForward:(BOOL)forward
{
	_layoutUpdated = YES;

	if (_moving) {
		_appending = YES;
		return;
	}
	_currentIndex = _destinationIndex;
	static float duration = kMoveDuration;
	int row = 0;
	for (int i = first; i <= last; ++i) {
		int column = i % _columns;
		if (!column && i) {
			row++;
		}
		_moving = YES;
		UIView* shortcut = _shortcuts[i];
		[UIView animateWithDuration:duration
							  delay:(row * 0.2 + column * 0.15) * duration
							options:UIViewAnimationOptionBeginFromCurrentState
						 animations:^{
							 shortcut.origin =[_origins[forward ? i + 1 : i - 1] CGPointValue];
						 }
						 completion:^(BOOL finished) {
							 _moving = NO;
							 [self _resortShortcutsIndex];
							 if (_appending && _currentIndex != _destinationIndex) {
								 [self _updateLayout];
								 _appending = NO;
							 } else {
                                 _firing = NO;
                             }
                             if (_justEnd) {
                                 [self _layBackPressingView];
                             }
						 }];
	}
}









@end
