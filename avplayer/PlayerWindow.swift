/**
    PlayerViewController.swift
    avplayer

    Created by Jerry Hale on 9/21/19
    Copyright © 2019-2020 jhale. All rights reserved
 
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

class PlayerWindow: NSWindow
{
    var  constrainingToScreenSuspended = true
    
    func setConstrainingToScreenSuspended(value: Bool) { constrainingToScreenSuspended = value }

    //  this window has its usual -constrainFrameRect:toScreen: behavior
    //  temporarily suppressed. this enables our window's custom Full Screen
    //  Exit animations to avoid being constrained by the
    //  top edge of the screen and the menu bar.
    //  MARK: overrides
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect
    {
        if constrainingToScreenSuspended { return (frameRect) }
        else { return (super.constrainFrameRect(frameRect, to:screen)) }
    } 
}
