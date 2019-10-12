/**
    Tracker.m
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

#import "Tracker.h"

@implementation InputTracker

@synthesize view = _view;


- (void)cancelTracking { }
- (BOOL)isEnabled { return (_isEnabled); }

- (id)init
{
    if (self = [super init])
        _isEnabled = YES;

    return (self);
}

- (void)setIsEnabled:(BOOL)enabled
{
    if (_isEnabled && !enabled)
        [self cancelTracking];

    _isEnabled = enabled;
}

@end

@implementation ClickTracker
@synthesize action = _action;
@synthesize doubleAction = _doubleAction;
@synthesize currentPoint = _currentPoint;
@synthesize modifiers = _modifiers;

- (void)mouseDown:(NSEvent *)event
{
    self.currentPoint = [self.view convertPointFromLayer:[event locationInWindow]];

    if ([event clickCount] < 2)
    {
        self.modifiers = [event modifierFlags];

        if (self.isEnabled && self.action)
            [NSApp sendAction:self.action to:self.view from:self];
    }
}

- (void)mouseUp:(NSEvent *)event
{
    if ([event clickCount] == 2)
    {
        self.modifiers = [event modifierFlags];

        if(self.isEnabled && self.doubleAction)
            [NSApp sendAction:self.doubleAction to:self.view from:self];
    }
}
@end

@interface DragTracker()
@property BOOL isTrackingDrag;
@property(readwrite) NSPoint initialPoint;
@property NSPoint currentPoint;
@property(readwrite) NSUInteger modifiers;
@end


@implementation DragTracker

- (id)init
{
    if (self = [super init])
        self.threshold = 2.0;
    
    return (self);
}

- (void)dealloc { self.userInfo = nil; }

#pragma mark NSResponder

- (void)mouseDown:(NSEvent *)event
{
    self.initialPoint = [self.view convertPointFromLayer:[event locationInWindow]];
    self.currentPoint = self.initialPoint;
}

- (void)mouseDragged:(NSEvent *)event
{
    self.modifiers = [event modifierFlags];
    self.currentPoint = [self.view convertPointFromLayer:[event locationInWindow]];

    if (!self.isEnabled) return;
    
    if (!self.isTrackingDrag)
    {
        NSPoint delta = self.delta;
        if (fabs(delta.x) > self.threshold || fabs(delta.y) > self.threshold)
        {
            self.isTrackingDrag = YES;
            if (self.beginTrackingAction) [NSApp sendAction:self.beginTrackingAction to:self.view from:self];
        }
    }
    else if (self.updateTrackingAction) [NSApp sendAction:self.updateTrackingAction to:self.view from:self];
}

- (void)mouseUp:(NSEvent *)event
{
    if (self.isTrackingDrag)
    {
        self.modifiers = [event modifierFlags];
        
        if (self.endTrackingAction) [NSApp sendAction:self.endTrackingAction to:self.view from:self];
        
        self.isTrackingDrag = NO;
    }
}


#pragma mark InputTracker



- (void)cancelTracking
{
    if (self.isTrackingDrag)
    {
        if (self.endTrackingAction) [NSApp sendAction:self.endTrackingAction to:self.view from:self];
        
        self.isTrackingDrag = NO;
    }
}

#pragma mark API

@synthesize isTrackingDrag = _trackingDrag;
@synthesize initialPoint = _initialPoint;
@synthesize currentPoint = _currentPoint;
@synthesize threshold = _threshold;

@synthesize beginTrackingAction = _beginTrackingAction;
@synthesize updateTrackingAction = _updateTrackingAction;
@synthesize endTrackingAction = _endTrackingAction;

@synthesize modifiers = _modifiers;

@synthesize userInfo = _userInfo;

- (NSPoint)delta;
{
    NSPoint delta;
    delta.x = self.currentPoint.x - self.initialPoint.x;
    delta.y = self.currentPoint.y - self.initialPoint.y;
    
    return (delta);
}

@end

