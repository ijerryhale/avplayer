/**
    OpenURLViewController.swift
    avplayer

    Created by Jerry Hale on 9/29/19
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

import Cocoa

class OpenURLViewController: NSViewController
{
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var okBtn: NSButton!

    @IBAction func onClickCancelBtn(_ sender: Any) { view.window?.performClose(nil) }
    @IBAction func onClickOKBtn(_ sender: NSButton)
    {
        //  let url = URL(string: "https://cormya.com/a-wrinkle-in-time-trailer-2_h.480.mov")
        let path = textField.stringValue
        
        if path.isValidURL
        {
            ////    openFile(notification: NSNotification)
            NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIF_OPENFILE), object: NSURL(string: path))

            view.window?.performClose(nil)
        }
    }
}

//  MARK: NSTextFieldDelegate
extension OpenURLViewController : NSTextFieldDelegate
{
    public func controlTextDidChange(_ obj: Notification)
    {
        let textField = obj.object as! NSTextField
        
        if textField.stringValue.count > 0
        {
            if textField.stringValue.isValidURL { okBtn.isEnabled = true }
            else { okBtn.isEnabled = false }
        }
        else { okBtn.isEnabled = false }
    }
}

extension String
{
    var isValidURL: Bool
    {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        {
            //  it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else { return false }
    }
}
