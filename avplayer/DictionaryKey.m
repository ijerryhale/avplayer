/**
    DictionaryKey.m
    avplayer

    Created by Jerry Hale on 10/20/19
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

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

#import "DictionaryKey.h"

CGFloat FRAME_DEFAULT_X = 186;
CGFloat FRAME_DEFAULT_Y = 186;
CGFloat FRAME_DEFAULT_WIDTH = 640;
CGFloat FRAME_DEFAULT_HGHT = 530;

CGFloat PLAYER_VIEW_HGHT = 220.0;
CGFloat LOWER_VIEW_HGHT = 260.0;

CGFloat SCRUBBER_LEFT_ANCHOR = 38.0;
CGFloat SCRUBBER_WIDTH_ANCHOR = 294.0;

NSString *NOTIF_OPENFILE = @"NOTIF_OPEN_FILE";
NSString *NOTIF_NEW_ASSET = @"NOTIF_NEW_ASSET";
NSString *NOTIF_TOGGLETIMECODEDISPLAY = @"NOTIF_TOGGLETIMECODEDISPLAY";


NSString *WINDOW_FRAME = @"KEY_WINDOW_FRAME";
NSString *LAYER_BACK_COLOR = @"KEY_LAYER_BACK_COLOR";

bool USE_DEFAULT_MOV = true;


NSString *langForTrack(AVAssetTrack *track)
{
    NSString    *code = [track languageCode];

    return ([NSString stringWithUTF8String:lang_for_code2(code.UTF8String)->eng_name]);
}
