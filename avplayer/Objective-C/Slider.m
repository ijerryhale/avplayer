/**
    Slider.m
    avplayer

    Created by Jerry Hale on 9/24/19
    Copyright © 2019 jhale. All rights reserved
 
 This file is part of avplayer.

 avplayer is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 avplayer is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with avplayer.  If not, see <https://www.gnu.org/licenses/>.

*/

#import "Slider.h"

//  Google Toolbox MacOS
@implementation NSBezierPath (BezierPathCGPathAdditions)

-(CGPathRef)createCGPath
{
  CGMutablePathRef thePath = CGPathCreateMutable();
  if (!thePath) return nil;
  
  NSInteger elementCount = [self elementCount];
  
  // The maximum number of points is 3 for a NSCurveToBezierPathElement.
  // (controlPoint1, controlPoint2, and endPoint)
  NSPoint controlPoints[3];
  
  for (NSInteger i = 0; i < elementCount; i++) {
    switch ([self elementAtIndex:i associatedPoints:controlPoints]) {
      case NSMoveToBezierPathElement:
        CGPathMoveToPoint(thePath, &CGAffineTransformIdentity, 
                              controlPoints[0].x, controlPoints[0].y);
        break;
      case NSLineToBezierPathElement:
        CGPathAddLineToPoint(thePath, &CGAffineTransformIdentity, 
                              controlPoints[0].x, controlPoints[0].y);
        break;
      case NSCurveToBezierPathElement:
        CGPathAddCurveToPoint(thePath, &CGAffineTransformIdentity, 
                              controlPoints[0].x, controlPoints[0].y,
                              controlPoints[1].x, controlPoints[1].y,
                              controlPoints[2].x, controlPoints[2].y);
        break;
      case NSClosePathBezierPathElement:
        CGPathCloseSubpath(thePath);
        break;
      default:
            //  NSLog(@"Unknown element at [NSBezierPath (BezierPathCGPathAdditions) cgPath]");
        break;
    };
  }
  return thePath;
}
@end
#pragma mark - _marker

@implementation _marker
@synthesize value = _value;
@synthesize slider = _slider;

@synthesize onImg = _onImg;
@synthesize offImg = _offImg;

-(id)init:(id)slider
{
	self = [super init];
	
	if (self)
	{
		_value = 0;
		_slider = slider;
		
		[self initMarker];
	}
		
	return (self);
}

-(void)initMarker
{
	_onImg = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Marker/PlayHeadOn" ofType:@"tif"]];
	_offImg = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Marker/PlayHeadOff" ofType:@"tif"]];

	double	sliderhght = _slider.frame.size.height;
	double	imghght = [_offImg size].height;
		
	self.frame = CGRectMake(0, sliderhght - imghght, [_offImg size].width, [_offImg size].height);
	self.contents = _onImg;
}

-(double)positionForValue
{
	double	usableTrackLength = _slider.bounds.size.width - (self.frame.size.width / 2) - 13;
	double	knobCenter = usableTrackLength * (self.value - _slider.minValue) /
					(_slider.maxValue - _slider.minValue) + (self.frame.size.width / 2);

	double	position = knobCenter - (self.frame.size.width / 2) + 3;
	//	NSLog(@"_scrubber positionForValue position:%f value:%f", position, self.value);
	
	return (position);
}

-(void)setPositionForValue
{
	CGRect	rect = self.frame;
	double	position = [self positionForValue];
	
	self.frame = CGRectMake(position,  rect.origin.y, rect.size.width, rect.size.height);
}
@end

#pragma mark - _scrubber
@implementation _scrubber
@end

#pragma mark - _markerstart
@implementation _markerstart
-(void)initMarker
{
	_onImg = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Marker/SelectionStartMarkerOn" ofType:@"tif"]];
	_offImg = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Marker/SelectionStartMarkerNoLineOff" ofType:@"tif"]];

	self.frame = CGRectMake(0, 0, [_offImg size].width, [_offImg size].height);
	self.contents = _offImg;
}

-(double)positionForValue
{
	double	usableTrackLength = _slider.bounds.size.width  - (2 * self.frame.size.width);
	double	knobCenter = usableTrackLength * (self.value - _slider.minValue) /
					(_slider.maxValue - _slider.minValue) + (self.frame.size.width / 2);

	double	position = knobCenter - (self.frame.size.width / 2);
	//	NSLog(@"_markerstart positionForValue position:%f value:%f", position, self.value);
	
	return (position);
}
@end

#pragma mark - _markerend
@implementation _markerend

-(void)initMarker
{
	_onImg = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Marker/SelectionEndMarkerOn" ofType:@"tif"]];
	_offImg = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Marker/SelectionEndMarkerOff" ofType:@"tif"]];

	self.frame = CGRectMake(0, 0, [_offImg size].width, [_offImg size].height);
	self.contents = _offImg;
}

-(double)positionForValue
{
	double	usableTrackLength = _slider.bounds.size.width - (2 * self.frame.size.width);
	double	vv = (self.value - _slider.minValue);
	double	vvvv = (_slider.maxValue - _slider.minValue);
	double	knobCenter = usableTrackLength * vv /
					vvvv + (self.frame.size.width / 2);
	double	position = knobCenter + (self.frame.size.width / 2);
	//	NSLog(@"_markerend positionForValue position:%f value:%f", position, self.value);
	
	return (position);
}
@end

#pragma mark - _slider_track
@implementation _slider_track
@synthesize slider = _slider;

-(void)drawInContext:(CGContextRef)ctx
{
//	NSLog(@"drawInContext");
//	CGRect  frame = self.bounds;
//	CGContextFillRect(ctx, frame);
//	return;

    // clip
 	NSBezierPath	*switchOutline = [NSBezierPath bezierPathWithRect:NSRectFromCGRect(self.bounds)];
	CGPathRef		pathRef = [switchOutline createCGPath];
	
	CGContextAddPath(ctx, pathRef);
	CGContextClip(ctx);

	// fill the track
	NSColor	*color = [NSColor colorWithCalibratedWhite:0.9 alpha:1.0];
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextAddPath(ctx, pathRef);
    CGContextFillPath(ctx);

    // fill the highlighed range
	double cornerRadius = self.bounds.size.height * .5 / 2.0;

	NSColor	*highliteColor = [NSColor colorWithCalibratedRed:0.0 green:0.45 blue:0.94 alpha:1.0];
	//	NSColor	*highliteColor = [NSColor colorWithCalibratedRed:.6 green:.6 blue:.6 alpha:1.0];
    CGContextSetFillColorWithColor(ctx, highliteColor.CGColor);
    double startVal = [_slider.markerStart positionForValue];
    double endVal = [_slider.markerEnd positionForValue];
    CGContextFillRect(ctx, CGRectMake(startVal, 0, endVal - startVal - 9, self.bounds.size.height));

	// highlight
    NSRect highlight = NSMakeRect(cornerRadius / 2,
									self.bounds.size.height / 2,
                                  self.bounds.size.width - cornerRadius,
								  self.bounds.size.height / 2);
    NSBezierPath *highlightPath = [NSBezierPath bezierPathWithRect:highlight];
	
    CGContextAddPath(ctx, [highlightPath createCGPath]);
    CGContextSetFillColorWithColor(ctx, [NSColor colorWithCalibratedWhite:1.0 alpha:0.4].CGColor);
    CGContextFillPath(ctx);
 
    // shadow
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 2.0), 3.0, [NSColor grayColor].CGColor);
    CGContextAddPath(ctx, pathRef);
    CGContextSetStrokeColorWithColor(ctx, [NSColor grayColor].CGColor);
    CGContextStrokePath(ctx);
 
    // outline
    CGContextAddPath(ctx, pathRef);
    CGContextSetStrokeColorWithColor(ctx, [NSColor blackColor].CGColor);
    CGContextSetLineWidth(ctx, 0.5);
    CGContextStrokePath(ctx);

	[CATransaction begin];
	[CATransaction setDisableActions:YES] ;
	
	[_slider.markerScrub setPositionForValue];
	[_slider.markerStart setPositionForValue];
	[_slider.markerEnd setPositionForValue];
	
	[CATransaction commit];
}
@end

#pragma mark - slider
@implementation Slider

@synthesize track = _track;
@synthesize markerScrub = _markerScrub;
@synthesize markerStart = _markerStart;
@synthesize markerEnd = _markerEnd;

@synthesize minValue = _minValue;
@synthesize maxValue = _maxValue;

#define __min(a, b) ({a < b ? a : b;})
#define __max(a, b) ({a < b ? b : a;})

-(void)dragScrubber:(DragTracker *)tracker
{
	//	NSLog(@"dragScrubber");
    double	delta = tracker.delta.x - _previousClick;
	double	valueDelta = (_maxValue - _minValue) * (delta / (self.bounds.size.width - _markerScrub.frame.size.width));
	double	value = _markerScrub.value + valueDelta;

	[self setValue:__max(__min(value, _maxValue), _minValue)];
	
	_previousClick = tracker.delta.x;
}

-(void)dragScrubberEnd:(DragTracker *)tracker
{
	//	NSLog(@"dragScrubberEnd");
	[self dragScrubber:tracker];
	_previousClick = 0;

	// reset the tracker back to nil values
    tracker.userInfo = nil;
    tracker.updateTrackingAction = nil;
    tracker.endTrackingAction = nil;

    //	tracking over, re-enable all trackers.
    [self enableTrackers];
}

-(void)dragStartMarker:(DragTracker *)tracker
{
	//	NSLog(@"dragStartMarker");
    double	delta = tracker.delta.x - _previousClick;
	double	valueDelta = (_maxValue - _minValue) * (delta / (self.bounds.size.width - _markerStart.frame.size.width));
	double	value = _markerStart.value + valueDelta;
	double	endValue = _markerEnd.value;

	_markerStart.value = __max(__min(value, endValue), _minValue);
	[self setValue:_markerStart.value];
	
	_previousClick = tracker.delta.x;
}

-(void)dragStartMarkerEnd:(DragTracker *)tracker
{
	//	NSLog(@"dragStartMarkerEnd");

	[self dragStartMarker:tracker];
	_previousClick = 0;

	// reset the tracker back to nil values
    tracker.userInfo = nil;
    tracker.updateTrackingAction = nil;
    tracker.endTrackingAction = nil;

    //	tracking over, re-enable all trackers.
    [self enableTrackers];
}

-(void)dragEndMarker:(DragTracker *)tracker
{
	//	NSLog(@"dragEndMarker");
    double	delta = tracker.delta.x - _previousClick;
	double	valueDelta = (_maxValue - _minValue) * (delta / (self.bounds.size.width - _markerEnd.frame.size.width));
	double	value = _markerEnd.value + valueDelta;
	double	startValue = _markerStart.value;

	_markerEnd.value = __min(__max(value, startValue), _maxValue);
	[self setValue:_markerEnd.value];

	_previousClick = tracker.delta.x;
}

-(void)dragEndMarkerEnd:(DragTracker *)tracker
{
	//	NSLog(@"dragEndMarker");
	
	[self dragEndMarker:tracker];
	_previousClick = 0;

	// reset the tracker back to nil values
    tracker.userInfo = nil;
    tracker.updateTrackingAction = nil;
    tracker.endTrackingAction = nil;

    //	tracking over, re-enable all trackers.
    [self enableTrackers];
}

-(void)resetMarkers
{
    _markerScrub.value = 0.0;
    _markerStart.value = 0.0;
    _markerEnd.value = 0.0;
    
    _markerScrub.contents = _markerScrub.offImg;
    _markerStart.contents = _markerStart.offImg;
    _markerEnd.contents = _markerEnd.offImg;
}

-(void)selectMarker:(_marker *)marker
{
	marker.contents = marker.onImg;

	if (marker != _markerScrub) _markerScrub.contents = _markerScrub.offImg;
	if (marker != _markerStart) _markerStart.contents = _markerStart.offImg;
	if (marker != _markerEnd) _markerEnd.contents = _markerEnd.offImg;	
}

-(void)beginMouseDrag:(DragTracker *)tracker
{
    //    NSLog(@"beginMouseDrag");
    NSPoint mouse = [self convertPoint:tracker.currentPoint fromView:nil];

    if (CGRectContainsPoint(_markerScrub.frame, CGPointMake(mouse.x, mouse.y)))
    {
        tracker.updateTrackingAction = @selector(dragScrubber:);
        tracker.endTrackingAction = @selector(dragScrubberEnd:);
    }
    else if (CGRectContainsPoint(_markerStart.frame, CGPointMake(mouse.x, mouse.y)))
    {
        tracker.updateTrackingAction = @selector(dragStartMarker:);
        tracker.endTrackingAction = @selector(dragStartMarkerEnd:);
    }
    else if (CGRectContainsPoint(_markerEnd.frame, CGPointMake(mouse.x, mouse.y)))
    {
        tracker.updateTrackingAction = @selector(dragEndMarker:);
        tracker.endTrackingAction = @selector(dragEndMarkerEnd:);
    }
    
    [self disableTrackersExcluding:tracker];
}

-(void)clickAction:(ClickTracker *)tracker
{
	#pragma unused (tracker)
	//	NSLog(@"clickAction");
	NSPoint mouse = [self convertPoint:tracker.currentPoint fromView:nil];
    BOOL    altkeyDown = ([tracker modifiers] & NSEventModifierFlagOption) != 0;

	if (CGRectContainsPoint(_markerScrub.frame, CGPointMake(mouse.x, mouse.y)))
		[self selectMarker:_markerScrub];
	else if (CGRectContainsPoint(_markerStart.frame, CGPointMake(mouse.x, mouse.y)))
	{
        if (altkeyDown) //  move the marker to the current scrubber
        {
            [self selectMarker:_markerScrub];
                        
            _markerStart.value = _markerScrub.value;
            [_track setNeedsDisplay];
        }
        else            //  move the scrubber to the marker
        {
            [self selectMarker:_markerStart];
            [self setValue:_markerStart.value];
        }
	}
	else if (CGRectContainsPoint(_markerEnd.frame, CGPointMake(mouse.x, mouse.y)))
	{
        if (altkeyDown) //  move the marker to the current scrubber
        {
           [self selectMarker:_markerScrub];
            
            _markerEnd.value = _markerScrub.value;
            [_track setNeedsDisplay];
        }
        else
        {
            [self selectMarker:_markerEnd];
            [self setValue:_markerEnd.value];
        }
	}
	else if (CGRectContainsPoint(_track.frame, CGPointMake(mouse.x, mouse.y)))
	{
		[self selectMarker:_markerScrub];
		double	value = (_maxValue - _minValue) * ((mouse.x - _track.frame.origin.x) / _track.bounds.size.width);
		
		_markerScrub.value = __max(__min(value, _maxValue), _minValue);
		[self setValue:_markerScrub.value];
	}
}

-(void)mouseDown:(NSEvent *)event
{
    _lastDragLocation = [event locationInWindow];
    [_tracker makeObjectsPerformSelector:_cmd withObject:event];
}

-(void)mouseDragged:(NSEvent *)event { [_tracker makeObjectsPerformSelector:_cmd withObject:event]; }
-(void)mouseUp:(NSEvent *)event { [_tracker makeObjectsPerformSelector:_cmd withObject:event]; }

-(BOOL)acceptsFirstResponder { return (YES); }

-(void)disableTrackersExcluding:(InputTracker *)excluded
{
    for (InputTracker *tracker in _tracker)
		if (tracker != excluded) tracker.isEnabled = NO;
}

-(void)enableTrackers
{
    for (InputTracker *tracker in _tracker)
		tracker.isEnabled = YES;
}

-(double)value { return (_markerScrub.value); }
-(void)setValue:(double)value
{
    _value = value;
	_markerScrub.value = _value;

	[_track setNeedsDisplay];
}

-(double)startMarker { return (_markerStart.value); }
-(void)setStartMarker:(double)value
{
	_markerStart.value = value;
	[_markerScrub setValue:value];
}

-(double)endMarker { return (_markerEnd.value); }
-(void)setEndMarker:(double)value
{
	_markerEnd.value = value;
	[_markerScrub setValue:value];
}

-(void) drawRect:(NSRect)dirtyRect
{
	#pragma unused (dirtyRect)
	//  [[NSColor whiteColor] set];
	//  NSRectFill([self bounds]);
	
	#if 0

	[_markerScrub setPositionForValue];
	[_markerScrub setNeedsDisplay];

	[_markerStart setPositionForValue];
	[_markerStart setNeedsDisplay];

	[_markerEnd setPositionForValue];
	[_markerEnd setNeedsDisplay];

	#endif
}

-(id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];

	if (self)
	{
		ClickTracker    *clickTracker = [ClickTracker new];
		DragTracker     *dragTracker = [DragTracker new];

		clickTracker.action = @selector(clickAction:);
		clickTracker.view = self;

		_tracker = [NSMutableArray array];
		[_tracker addObject:clickTracker];

		dragTracker.beginTrackingAction = @selector(beginMouseDrag:);
		dragTracker.view = self;
		[_tracker addObject:dragTracker];

		[self setWantsLayer:YES];
		// Initialization code
		_minValue = 0.0;
        _maxValue = 1.0;
		_previousClick = 0.0;
	
		//	track
		_track = [_slider_track layer];
		_track.slider = self;

		_track.autoresizingMask = kCALayerWidthSizable;
		_track.needsDisplayOnBoundsChange = YES;
		
		[self.layer addSublayer:_track];

		CGRect  trackFrame = NSRectToCGRect(self.bounds);
		
		trackFrame.origin.y += trackFrame.size.height / 4;
		trackFrame.size.height /= 2;
		
		trackFrame.origin.x += 9;
		trackFrame.size.width -= 18;
		
		_track.frame = trackFrame;
		[_track setNeedsDisplay];

		//	scrubber
        _markerScrub = [[_scrubber alloc]init:self];
		_markerScrub.needsDisplayOnBoundsChange = YES;
        
        [self.layer addSublayer:_markerScrub];
		
		//	markerStart
		_markerStart = [[_markerstart alloc]init:self];
        
		[self.layer addSublayer:_markerStart];
		
		//	markerEnd
		_markerEnd = [[_markerend alloc]init:self];
        
		[self.layer addSublayer:_markerEnd];
		
		[CATransaction begin];
		[CATransaction setDisableActions:YES];

		[_markerScrub setPositionForValue];
		[_markerStart setPositionForValue];
		[_markerEnd setPositionForValue];

		[CATransaction commit];
	}

    return (self);
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //NSLog(@"observeValueForKeyPath %f", value);
    
	if (*(long *)context == 0)
		self.value = [[change objectForKey:NSKeyValueChangeNewKey]doubleValue];
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end

