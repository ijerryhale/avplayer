/**
    DictionaryKey.h
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

extern CGFloat FRAME_DEFAULT_X;
extern CGFloat FRAME_DEFAULT_Y;
extern CGFloat FRAME_DEFAULT_WIDTH;
extern CGFloat FRAME_DEFAULT_HGHT;

extern CGFloat PLAYER_VIEW_HGHT;
extern CGFloat LOWER_VIEW_HGHT;

extern CGFloat SCRUBBER_LEFT_ANCHOR;
extern CGFloat SCRUBBER_WIDTH_ANCHOR;

extern NSString *NOTIF_OPENFILE;
extern NSString *NOTIF_NEW_ASSET;
extern NSString *NOTIF_TOGGLETIMECODEDISPLAY;

extern NSString *WINDOW_FRAME;
extern NSString *LAYER_BACK_COLOR;

extern bool USE_DEFAULT_MOV;

NSString *langForTrack(AVAssetTrack *track);
