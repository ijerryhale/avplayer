/**
    PlayerView.swift
    avplayer

    Created by Jerry Hale on 9/26/19
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

class PlayerView: NSView
{
    var backColor:NSColor = NSColor.black
    var isReceivingDrag = false { didSet { needsDisplay = true } }

    //  MARK: overrides
    override func draw(_ dirtyRect: NSRect)
    {
        if isReceivingDrag
        {
            let path = NSBezierPath(rect:bounds)
            let blue = NSColor.blue.withAlphaComponent(0.3)
            
            blue.setStroke()
            path.lineWidth = 15.0
            path.stroke()
        }
        else { backColor.set() }
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool
    {
        guard let pasteboard = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
                 let path = pasteboard[0] as? String
            else { return (false) }

        NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIF_OPENFILE), object: URL(fileURLWithPath: path))

        isReceivingDrag = false
        
        return (true)
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation
    {
        func checkExtension(_ drag: NSDraggingInfo) -> Bool
        {
            guard let board = drag.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
                   let path = board[0] as? String
             else { return false }

             let suffix = URL(fileURLWithPath: path).pathExtension
             for ext in expectedExt { if ext == suffix { return true } }
            
            return (false)
        }

        if checkExtension(sender) == true
        {
            backColor = NSColor.init(cgColor: self.layer!.backgroundColor!)!
            isReceivingDrag = true
                   
            return (.copy)

        } else { return (NSDragOperation()) }
    }

    override func awakeFromNib()
    { super.awakeFromNib(); print("PlayerView awakeFromNib")
        
        registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
    }
}
