/**
    PlayerWindowController.swift
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

import Cocoa
import AVFoundation
import Foundation

class PlayerWindowController : NSWindowController
{
    //  @objc private func willEnterFull(notification: NSNotification) { }
    //  @objc private func didExitFull(notification: NSNotification) { }
    var frameForNonFullScreenMode = NSMakeRect(0.0, 0.0, 0.0, 0.0)

    var splitViewController : SplitViewController?
    var playerViewController : PlayerViewController?
    
    var tracksViewController:TracksViewController?
    
    private static let assetKeysRequiredToPlay = [ "playable", "hasProtectedContent"]
 
    @IBAction func doCreateTrimmedMOV(_ sender: Any)
     {
        let savePanel = NSSavePanel()
        let movDir = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask)

        savePanel.title = "Save Movie As"
        savePanel.canCreateDirectories = false
        
        savePanel.allowedFileTypes = ["mp4", "mov", "MOV", "m4v", "M4V"]
        savePanel.directoryURL = movDir[0]

        savePanel.beginSheetModal(for:self.window!)
        { (response) in

            if response == .OK
            {
                if let url:URL = savePanel.url
                {
                    //  https://gist.github.com/acj/b8c5f8eafe0605a38692
                    typealias TrimCompletion = (Error?) -> ()
                    typealias TrimPoints = [(CMTime, CMTime)]
        
                    func trimVideo(_ sourceURL: URL, destinationURL: URL, trimPoints: TrimPoints, completion: TrimCompletion?)
                    {
                        assert(sourceURL.isFileURL)
                        assert(destinationURL.isFileURL)
        
                        func removeFileAtURLIfExists(url: NSURL)
                        {
                            if let filePath = url.path
                            {
                                let fileManager = FileManager.default
        
                                if fileManager.fileExists(atPath: filePath)
                                {
                                    do { try fileManager.removeItem(atPath: filePath) }
                                    catch { print("Couldn't remove existing destination file: \(error)") }
                                }
                            }
                        }
        
                        func verifyPresetForAsset(preset: String, asset: AVAsset) -> Bool
                        {
                            let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
                            let filteredPresets = compatiblePresets.filter { $0 == preset }
        
                            return (filteredPresets.count > 0 || preset == AVAssetExportPresetHighestQuality)
                        }
        
                        let options = [ AVURLAssetPreferPreciseDurationAndTimingKey: true ]
                        let asset = AVURLAsset(url: sourceURL, options: options)
                        let preferredPreset = AVAssetExportPresetHighestQuality
        
                        if verifyPresetForAsset(preset: preferredPreset, asset: asset)
                        {
                            let composition = AVMutableComposition()
        
                            guard
                                let videoCompTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID()),
                                let audioCompTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())
                            else
                            {
                                let error = NSError(domain: "com.jhale.avplayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Couldn't add mutable tracks"])
                                completion?(error)
                                return
                            }
        
                            guard
                                let assetVideoTrack = asset.tracks(withMediaType: AVMediaType.video).first,
                                let assetAudioTrack = asset.tracks(withMediaType: AVMediaType.audio).first
                            else
                            {
                                self.playerViewController?.noVideoLabel.isHidden = false
        
                                let error = NSError(domain: "com.jhale.avplayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Couldn't find video or audio track in source asset"])
                                completion?(error)
                                return
                            }
        
                            //  preserve the orientation of the source asset
                            videoCompTrack.preferredTransform = assetVideoTrack.preferredTransform
        
                            var accumulatedTime = CMTime.zero
                            for (startTimeForCurrentSlice, endTimeForCurrentSlice) in trimPoints
                            {
                                let durationOfCurrentSlice = CMTimeSubtract(endTimeForCurrentSlice, startTimeForCurrentSlice)
                                let timeRangeForCurrentSlice = CMTimeRangeMake(start: startTimeForCurrentSlice, duration: durationOfCurrentSlice)
                                do
                                {
                                    try videoCompTrack.insertTimeRange(timeRangeForCurrentSlice, of: assetVideoTrack, at: accumulatedTime)
                                    try audioCompTrack.insertTimeRange(timeRangeForCurrentSlice, of: assetAudioTrack, at: accumulatedTime)
                                }
                                catch
                                {
                                    let error = NSError(domain: "com.jhale.avplayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Couldn't insert time ranges: \(error)"])
                                    completion?(error)
                                    return
                                }
        
                                accumulatedTime = CMTimeAdd(accumulatedTime, durationOfCurrentSlice)
                            }
        
                            guard let exportSession = AVAssetExportSession(asset: composition, presetName: preferredPreset)
                            else
                            {
                                let error = NSError(domain: "com.jhale.avplayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Couldn't create export session"])
                                completion?(error)
                                return
                            }
        
                            exportSession.outputURL = destinationURL
                            exportSession.outputFileType = AVFileType.mp4
                            exportSession.shouldOptimizeForNetworkUse = true
        
                            removeFileAtURLIfExists(url: destinationURL as NSURL)
        
                            exportSession.exportAsynchronously(completionHandler: { completion?(exportSession.error) })
                        }
                        else
                        {
                            let error = NSError(domain: "com.jhale.avplayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not find a suitable export preset for the input video"])
                            if let completion = completion { completion(error); return }
                        }
                    }
                    
                    let start:Float64 = (self.playerViewController?.scrubberSlider!.markerStart.value)!
                    let end:Float64 = (self.playerViewController?.scrubberSlider!.markerEnd.value)!
    
                    if end != 0 && end != start
                    {
                        let trimPoints = [(CMTimeMakeWithSeconds(start, preferredTimescale: 10000), CMTimeMakeWithSeconds(end, preferredTimescale: 10000))]
    
                        trimVideo(self.asset!.url, destinationURL: url, trimPoints: trimPoints)
                        { error in
                            if let error = error
                            { handleErrorWithMessage("Failure:createTrimmedMov", error: error) }
                            else { print("Success") }
                        }
                    }
                }
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
        openPanel.allowedFileTypes = expectedExt

        openPanel.beginSheetModal(for:self.window!)
        { (response) in

            if response == .OK
            {
                if let url:URL = openPanel.url
                {
                    ////    we're just notifying ourselves here
                    ////    openFile(notification: Notification)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIF_OPENFILE), object: url)
                }
            }
            
            openPanel.close()
         }
     }
    
    var asset: AVURLAsset?
    {
        didSet
        {
            guard let newAsset = asset else { return }
            
            asynchronouslyLoadURLAsset(newAsset)
        }
    }

    //  MARK: @objc
    @objc func openFile(_ notification: Notification)
    {
        //  print("openFile(_ notification: Notification)")
        playerViewController?.unplayableLabel.isHidden = true
        playerViewController?.noVideoLabel.isHidden = true
        playerViewController?.player.pause()

        if let url:URL = notification.object as? URL
        {
            //  print(url.absoluteString)
            asset = AVURLAsset(url: url , options: nil)
        }
    }

    //  fill in some of the assorted text
    //  values in the PlayerViewController
    func assignMediaCharacteristics(_ newAsset: AVURLAsset?)
    {   //  estimatedDataRate
        guard
            let tracks = newAsset?.tracks(withMediaType: .video)
        else
        {
            let error = NSError(domain: "com.jhale.avplayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Couldn't find Video Track in AVAsset"])
            
            handleErrorWithMessage("Failure:assignMediaCharacteristics", error: error)

            playerViewController?.noVideoLabel.isHidden = false
            
            return
        }

        let descArray = tracks[0].formatDescriptions as! [CMFormatDescription]
 
        if (CMFormatDescriptionGetMediaType(descArray[0]) == kCMMediaType_Video)
        {
            let dimensions = CMVideoFormatDescriptionGetDimensions(descArray[0]);
            let codec = CMFormatDescriptionGetExtension(descArray[0], extensionKey: "FormatName" as CFString)
            let dims = dimensions.width.description + " x " + dimensions.height.description
            
            var codecText:String = ""
            switch codec as! String
            {
                case "'apch'":
                    codecText = "Apple ProRes 422 (HQ)"
                break
                case "'avc1'",
                     "'x264'":
                    codecText = "H.264"
                break
                case "'mpg4'",
                     "'mp4v'":
                    codecText = "MPEG-4 Video"
                break

                default:
                    codecText = codec as! String
                break
            }
            
            playerViewController?.formatText.stringValue = codecText + " " + dims
        }
    }

    func asynchronouslyLoadURLAsset(_ newAsset: AVURLAsset)
    {
        //  using AVAsset now runs the risk of blocking
        //  the current thread (the main UI thread) whilst
        //  I/O happens to populate the properties
        //  it's prudent to defer our work until the
        //  properties we need have been loaded.
        newAsset.loadValuesAsynchronously(forKeys: PlayerWindowController.assetKeysRequiredToPlay)
        {
            //  the asset invokes its completion handler on an arbitrary queue
            //  to avoid multiple threads using our internal state at the same time
            //  we'll elect to use the main thread at all times, let's dispatch
            //  our handler to the main queue
            DispatchQueue.main.async
            {
                //  self.asset` has already changed
                //  no point continuing because
                //  another `newAsset` will come along in a moment.
                guard newAsset == self.asset else { return }
                
                //  test whether the values of each of the keys
                //  we need have been successfully loaded
                var error: NSError?
                for key in PlayerWindowController.assetKeysRequiredToPlay
                {
                    if newAsset.statusOfValue(forKey: key, error: &error) == .failed
                    {
                        let stringFormat = NSLocalizedString("error.asset_key_%@_failed.description", comment: "Can't use this AVAsset because one of it's keys failed to load")
                        
                        let message = String.localizedStringWithFormat(stringFormat, key)
                        
                        handleErrorWithMessage(message, error: error)
                        
                        return
                    }
                }
                //  we can't play this asset.
                if !newAsset.isPlayable || newAsset.hasProtectedContent
                {
                    print(newAsset.isPlayable)
                    print(newAsset.hasProtectedContent)
                    let message = NSLocalizedString("error.asset_not_playable.description", comment: "Can't use this AVAsset because it isn't playable or has protected content")

                    self.playerViewController?.unplayableLabel.isHidden = false
                    
                    handleErrorWithMessage(message)

                    return
                }
                
                //  we can play this asset
                //  create a new `AVPlayerItem
                //  and make it our player's current item.
                self.playerViewController?.playerItem = AVPlayerItem(asset: newAsset)
                self.playerViewController?.frameRate
                    = self.playerViewController?.player.currentItem?.asset.tracks[0].nominalFrameRate ?? 0.0
                //  if this is a local file
                if self.asset!.url.isFileURL
                {
                    (NSApplication.shared.delegate as! AppDelegate).isLocalAsset = true
                    NSDocumentController.shared.noteNewRecentDocumentURL(self.asset!.url)
                }
                else { (NSApplication.shared.delegate as! AppDelegate).isLocalAsset = false }
                
                self.assignMediaCharacteristics(newAsset)
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIF_NEW_ASSET), object: self.asset)
            }
        }
    }
    
    //  MARK: overrides
    override func windowDidLoad()
    { super.windowDidLoad(); print("PlayerWindowController windowDidLoad")

        if USE_DEFAULT_MOV
        {
            //  let url = URL(fileURLWithPath:"/Users/jhale/Desktop/30fps_video_sample.mp4")
            let url = URL(string: "https://cormya.com/the-addams-family-trailer-2_h.480.mov")
            asset = AVURLAsset(url: url! , options: nil)
            
            (NSApplication.shared.delegate as! AppDelegate).isLocalAsset = false
        }
    }

    override func awakeFromNib()
    { super.awakeFromNib(); print("PlayerWindowController awakeFromNib")
        
        frameForNonFullScreenMode = window!.frame
        shouldCascadeWindows = true

        splitViewController = contentViewController as? SplitViewController
        playerViewController = splitViewController?.splitViewItems[0].viewController as? PlayerViewController
                
        tracksViewController = NSStoryboard.tracks.instantiateController(withIdentifier: "\(TracksViewController.self)") as? TracksViewController

        splitViewController?.addChild(tracksViewController!)

        //  there's still bugs here if there is
        //  a pref set and the user has multiple
        //  monitors and changes the display arrangement
        let prefs = UserDefaults.standard.data(forKey: WINDOW_FRAME)
        
        if prefs == nil { window?.setFrame(NSMakeRect(FRAME_DEFAULT_X, FRAME_DEFAULT_Y, FRAME_DEFAULT_WIDTH, FRAME_DEFAULT_HGHT), display: true) }
        else
        {
            do {
                if let frame = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(prefs!) as? NSRect
                {
                    window?.setFrame(frame, display: true)
                }
            } catch { print("NSKeyedUnarchiver.unarchiveObject error") }
        }
        //  full screen change notification
        //  NotificationCenter.default.addObserver(self, selector: #selector(willEnterFull),
        //      name: NSWindow.willEnterFullScreenNotification, object: nil)
        //  NotificationCenter.default.addObserver(self, selector: #selector(didExitFull),
        //      name: NSWindow.didExitFullScreenNotification, object: nil)
    
        ////    openFile(notification: Notification)
        NotificationCenter.default.addObserver(self, selector: #selector(openFile(_:)),
                                               name: Notification.Name(rawValue: NOTIF_OPENFILE), object: nil)
        ////    windowWillClose(notification: Notification)
        NotificationCenter.default.addObserver(self, selector: #selector(windowWillClose(_:)),
                                               name: NSWindow.willCloseNotification, object: nil)
    }
}

//  MARK: NSWindowDelegate
extension PlayerWindowController : NSWindowDelegate
{
    func window(_ window: NSWindow, willUseFullScreenContentSize proposedSize: NSSize) -> NSSize { return (NSMakeSize(proposedSize.width, proposedSize.height)) }
    func customWindowsToEnterFullScreen(for window: NSWindow) -> [NSWindow]? { return ([window]) }

    // MARK: Enter Full Screen
    func window(_ window: NSWindow, startCustomAnimationToEnterFullScreenWithDuration duration: TimeInterval)
    {
        frameForNonFullScreenMode = window.frame
        window.invalidateRestorableState()
        
        let screen = NSScreen.screens[0]
        let screenFrame = screen.frame
        var proposedFrame = screenFrame
        
        proposedFrame.size = self.window(window, willUseFullScreenContentSize: proposedFrame.size)
        proposedFrame.origin.x += floor((NSWidth(screenFrame) - NSWidth(proposedFrame)) / 2)
        proposedFrame.origin.y += floor((NSHeight(screenFrame) - NSHeight(proposedFrame)) / 2)

        //  the center frame for each window is used during
        //  the 1st half of the fullscreen animation and is
        //  the window at its original size but moved to
        //  the center of its eventual full screen frame.
        var centerWindowFrame = window.frame
        
        centerWindowFrame.origin.x = NSWidth(proposedFrame) / 2 - NSWidth(centerWindowFrame) / 2;
        centerWindowFrame.origin.y = NSHeight(proposedFrame) / 2 - NSHeight(centerWindowFrame) / 2;

        //  our animation will be broken into two stages
        //  first, we'll move the window to the center of
        //  the primary screen and then we'll enlarge
        //  it to its full screen size
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = duration
            window.animator().setFrame(centerWindowFrame, display: true)
        }, completionHandler: { () -> Void in

            NSAnimationContext.runAnimationGroup({ context in
                context.duration = duration
                window.animator().setFrame(proposedFrame, display: true)
            }) { }
        })
    }

    // MARK: Exit Full Screen
    func customWindowsToExitFullScreen(for window: NSWindow) -> [NSWindow]? { return ([window]) }
            
    func window(_ window: NSWindow, startCustomAnimationToExitFullScreenWithDuration duration: TimeInterval)
    {
        (self.window as! PlayerWindow).setConstrainingToScreenSuspended(value: true)
        
        var centerWindowFrame = frameForNonFullScreenMode
        
        centerWindowFrame.origin.x = window.frame.size.width / 2 - frameForNonFullScreenMode.size.width / 2
        centerWindowFrame.origin.y = window.frame.size.height / 2 - frameForNonFullScreenMode.size.height / 2

        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = duration
            window.animator().setFrame(centerWindowFrame, display: true)
         }, completionHandler: { () -> Void in

             NSAnimationContext.runAnimationGroup({ context in
                context.duration = duration
                window.animator().setFrame(self.frameForNonFullScreenMode, display: true)
             })
             { (self.window as! PlayerWindow).setConstrainingToScreenSuspended(value: false) }
         })
    }
    
    func windowWillClose(_ notification: Notification)
    {
        NotificationCenter.default.removeObserver(self,
                            name: Notification.Name(rawValue: NOTIF_OPENFILE), object: nil)

        guard let frame = window?.frame else { return }
        
        do
        {
             let data = try NSKeyedArchiver.archivedData(withRootObject: frame, requiringSecureCoding: false)
             UserDefaults.standard.set(data, forKey: WINDOW_FRAME)
        } catch { print("NSKeyedArchiver.archivedData error") }
    }
    
    func window(_ window: NSWindow, willUseFullScreenPresentationOptions proposedOptions:
                                    NSApplication.PresentationOptions = []) -> NSApplication.PresentationOptions
    {
        //  customize our appearance when entering full screen:
        //  we don't want the dock to appear but we want the menubar to hide/show automatically
        return ( [.fullScreen,  //  support full screen for this window (required)
            .autoHideDock,      //  completely hide the dock
            .autoHideMenuBar])  // yes we want the menu bar to show/hide
    }
}
