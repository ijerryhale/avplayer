/**
    Tracker.h
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

@interface InputTracker : NSResponder
{
    BOOL    _isEnabled;
    NSView *_view;
	
}
// The owning view of the input tracker. This is the object that any callbacks are sent to.
@property(strong) NSView *view;

@property   BOOL    isEnabled;
// Is this tracker currently monitoring the events and sending out callbacks. If a tracker's enabled state changes to NO, it will automatically cancel any tracking that it is currently performing.

// Stop any tracking the tracker may be performing and reset itself.
- (void)cancelTracking;
@end

@interface ClickTracker : InputTracker {
    SEL _action;
    SEL _doubleAction;
    
    NSPoint _location;
    NSUInteger _modifiers;
}

// The method to call on the view in response to a click.
@property SEL action;

// The method to call on the view in response to a double click. The method should have one paramenter (ClickTracker *) and a void return.
@property SEL doubleAction;

// The location of the cursor in the view's coordinate space during a click action.
@property NSPoint currentPoint;

// The modifier flags of the last event processed by the tracker. The returned value outside of the scope of the action or doubleAction callbacks is undefined.
@property NSUInteger modifiers;

@end

@interface DragTracker : InputTracker {
@private
    BOOL _trackingDrag;
    NSPoint _initialPoint;
    NSPoint _currentPoint;
    
    CGFloat _threshold;
    NSUInteger _modifiers;
    
    SEL _beginTrackingAction;
    SEL _updateTrackingAction;
    SEL _endTrackingAction;
    
    id _userInfo;
}

// The cursor location in the view's coordinate space where the mouse down occured.
@property(readonly) NSPoint initialPoint;
@property(readonly) NSPoint currentPoint;

// The difference between the initial cursor location and the current cursor location. This value is in the view's coordinate space.
@property(readonly) NSPoint delta;

// The modifier flags of the last event processed by the tracker. The returned value outside of the begin and end tracking actions are undefined.
@property(readonly) NSUInteger modifiers;

// The number of points the cursor must move (in any direction) before tracking begins.
@property CGFloat threshold;

// The following three properties hold the tracking callbacks on the view. Each method should have one paramenter (DragTracker *) and a void return.
@property SEL beginTrackingAction;
@property SEL updateTrackingAction;
@property SEL endTrackingAction;

// Storage for your custom object to help with tracking. For example, a pointer to the object being modified may be set as the userInfo when the beginTrackingAction method is called.
@property(retain) id userInfo;
@end
