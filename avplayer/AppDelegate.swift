/**
    PlayerViewController.swift
    avplayer

    Created by Jerry Hale on 9/11/19
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

let NOTIF_TOGGLETIMECODEDISPLAY = "ToggleTimeCodeDisplay"
let NOTIF_CREATE_TRIMMED_MOV = "CreateTrimmedMOV"

import Cocoa

extension Float
{
    func truncate(places : Int)-> Float
    {
        return Float(floor(pow(10.0, Float(places)) * self)/pow(10.0, Float(places)))
    }
}

@NSApplicationMain
class AppDelegate: NSObject
{
    //  IB bind to Create
    //  Trimmed MOV Menu Item
    @objc var isLocalAsset = false
    
    //  MARK: IBAction
    @IBAction func doToggleTimeCodeDisplay(_ mi: NSMenuItem)
    {
        var title = mi.title
        let show = "Show Time Code"
        let hide = "Hide Time Code"
        
        if title == show { title = hide}
        else { title = show }
        
        mi.title = title
        ////    toggleTimeCodeDisplay()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIF_TOGGLETIMECODEDISPLAY), object: nil)
    }
    
    @IBAction func doCreateTrimmedMOV(_ sender: Any)
    {
        let savePanel = NSSavePanel()
        let movDir = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask)

        savePanel.title = "Save Movie As"
        savePanel.canCreateDirectories = false
        savePanel.allowedFileTypes = ["mp4", "mov", "MOV", "m4v", "M4V"]
        savePanel.directoryURL = movDir[0]
        //  savePanel.nameFieldStringValue =

        savePanel.beginSheetModal(for:NSApplication.shared.keyWindow!)
        { (response) in
            
            if response == .OK
            {
                ////    createTrimmedMOV(notification: NSNotification)
               NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIF_CREATE_TRIMMED_MOV), object: savePanel.url)
            }

            savePanel.close()
        }
    }

    @IBAction func doOpenFile(_ sender: Any)
    {
        let openPanel = NSOpenPanel()

        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.allowedFileTypes = ["mp4", "mov", "MOV", "m4v", "M4V"]

        openPanel.beginSheetModal(for:NSApplication.shared.keyWindow!)
        { (response) in

            if response == .OK
            {
                ////    openFile(notification: Notification)
                NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIF_OPENFILE), object: openPanel.url)
            }

            openPanel.close()
        }
    }
    
    @IBAction func doOpenURL(_ sender: Any)
     {
        let openURLController = (NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "OpenURLWindowController") as! NSWindowController)
        openURLController.window?.makeKeyAndOrderFront(nil)
    }
    
    //  MARK: @objc
    @objc func applicationDidBecomeActive() { }
}

//  MARK: NSApplicationDelegate
extension AppDelegate : NSApplicationDelegate
{
    func application(_ sender: NSApplication, openFile filename: String) -> Bool
    {
        //  Mac OS 10.15: if the app is active and a file is sent to
        //  the trash, the trashed file is auto-magically removed
        //  from the Open Recent Menu
        if FileManager.default.fileExists(atPath: filename)
        {
            ////    openFile(notification: Notification)
            NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIF_OPENFILE), object: URL.init(fileURLWithPath: filename))
        }
        else { return (false) }

        return (true)
    }

    func applicationWillTerminate(_ aNotification: Notification)
    { NotificationCenter.default.removeObserver(self, name: NSApplication.didBecomeActiveNotification, object: nil) }
    
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: NSApplication.didBecomeActiveNotification, object: nil)
    }
}
