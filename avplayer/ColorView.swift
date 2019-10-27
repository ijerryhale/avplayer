/**
    Color.swift
    avplayer

    Created by Jerry Hale on 10/9/19
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

class ColorView: NSView
{
    var backColor:NSColor = NSColor.lightGray

    //  MARK: overrides
    override func draw(_ dirtyRect: NSRect)
    {
        backColor.set()
        backColor.setFill()
        NSBezierPath(rect:bounds).fill()
     }
    
    //  override func awakeFromNib() { super.awakeFromNib(); print("ColorView awakeFromNib") }
}
