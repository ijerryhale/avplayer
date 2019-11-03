/**
    Slider.h
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

@interface NSBezierPath (BezierPathCGPathAdditions)
- (CGPathRef)createCGPath;
@end

@class Slider;
@interface _marker : CALayer
{
	NSImage *_onImg,
            *_offImg;
    Slider  *_slider;
	
	double	_value;
}

@property (readonly) id	onImg;
@property (readonly) id	offImg;

@property double			value;
@property (strong) Slider	*slider;

- (id)init:(id)slider;
- (void)setPositionForValue;
@end

@interface _scrubber : _marker
@end

@interface _markerstart : _marker
@end


@interface _markerend : _marker
@end

@interface _slider_track : CALayer
{
    Slider  *_slider;
}
@property (strong) Slider	*slider;
@end

//	484 X 28
@class _slider_track;
@class _scrubber;
@class _markerstart;
@class _markerend;

@interface Slider : NSControl
{
     _slider_track	*_track;
	
    _scrubber		*_markerScrub;
    _markerstart	*_markerStart;
    _markerend		*_markerEnd;

	NSMutableArray	*_tracker;
	NSPoint			_lastDragLocation;

	double			_previousClick,
					_value,
					_minValue,
					_maxValue;
}

@property double maxValue;
@property double minValue;

@property (strong) _slider_track    *track;
@property (strong) _scrubber        *markerScrub;
@property (strong) _markerstart     *markerStart;
@property (strong) _markerend       *markerEnd;

- (id)initWithFrame:(NSRect)frame;

- (double)value;
- (void)setValue:(double)value;

- (double)startMarker;
- (void)setStartMarker:(double)value;
- (double)endMarker;
- (void)setEndMarker:(double)value;

-(void)resetMarkers;
- (void)selectMarker:(_marker *)marker;

@end

