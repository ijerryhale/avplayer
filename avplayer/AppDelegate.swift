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

import Cocoa

let expectedExt = ["mp4", "MP4", "mov", "MOV", "m4v", "M4V"]

extension Float
{
    func truncate(places : Int)-> Float { return Float(floor(pow(10.0, Float(places)) * self)/pow(10.0, Float(places))) }
}

extension NSStoryboard
{
    struct Storyboard
    {
        static let tracks = "TracksViewController"
    }

    @nonobjc class var tracks: NSStoryboard { return NSStoryboard(name: Storyboard.tracks, bundle: nil) }
}

extension CMTime
{
    var durationText:String
    {
        let secs = CMTimeGetSeconds(self)
        let hours:Int = Int(secs / 3600)
        let minutes:Int = Int(secs.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds:Int = Int(secs.truncatingRemainder(dividingBy: 60))
        
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        
        //  if hours > 0 { return String(format: "%i:%02i:%02i", hours, minutes, seconds) }
        //  else { return String(format: "%02i:%02i", minutes, seconds) }
    }
}

func handleErrorWithMessage(_ message: String?, error: Error? = nil)
{
    NSLog("Error occured with message: \(message ?? "No Message"), error: \(String(describing: error)).")
}

@NSApplicationMain
class AppDelegate: NSObject
{
    //  IB binds to Disable/Enable
    //  Create Movie Clip... Menu Item
    @objc var hasValidAsset = false
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

    @IBAction func doOpenURL(_ sender: Any)
    {
        let openURLController = (NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "OpenURLWindowController") as! NSWindowController)
        openURLController.window?.makeKeyAndOrderFront(nil)
    }

    //  @objc func applicationDidBecomeActive() { }
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
    { /* NotificationCenter.default.removeObserver(self, name: NSApplication.didBecomeActiveNotification, object: nil) */ }
    
    func applicationWillFinishLaunching(_ aNotification: Notification)
    {
        //  print_channel_labels()
        //  NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: NSApplication.didBecomeActiveNotification, object: nil)
    }
}

func print_audio_formats()
{
    print(NSFileTypeForHFSTypeCode(kAudioFormatLinearPCM)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatAC3)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormat60958AC3)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatAppleIMA4)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatMPEG4AAC)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatMPEG4CELP)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatMPEG4HVXC)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatMPEG4TwinVQ)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatMACE3)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatMACE6)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatULaw)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatALaw)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatQDesign)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatQDesign2)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatQUALCOMM)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatMPEGLayer1)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatMPEGLayer2)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatMPEGLayer3)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatTimeCode)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatMIDIStream)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatParameterValueStream)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatAppleLossless)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatMPEG4AAC_HE)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatMPEG4AAC_LD)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatMPEG4AAC_ELD)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatMPEG4AAC_ELD_SBR)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatMPEG4AAC_ELD_V2)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatMPEG4AAC_HE_V2)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatMPEG4AAC_Spatial)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatMPEGD_USAC)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatAMR)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatAMR_WB)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatAudible)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatiLBC)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatDVIIntelIMA)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatMicrosoftGSM)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatAES3)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatEnhancedAC3)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatFLAC)!)
    print(NSFileTypeForHFSTypeCode(kAudioFormatOpus)!)
}

func print_channel_labels()
{
    print(kAudioChannelLayoutTag_Mono) // a standard mono stream
    print(kAudioChannelLayoutTag_Stereo) // a standard stereo stream (L R) - implied playback
    print(kAudioChannelLayoutTag_StereoHeadphones) // a standard stereo stream (L R) - implied headphone playback
    print(kAudioChannelLayoutTag_MatrixStereo) // a matrix encoded stereo stream (Lt, Rt)
    print(kAudioChannelLayoutTag_MidSide) // mid/side recording
    print(kAudioChannelLayoutTag_XY) // coincident mic pair (often 2 figure 8's)
    print(kAudioChannelLayoutTag_Binaural) // binaural stereo (left, right)
    print(kAudioChannelLayoutTag_Ambisonic_B_Format) // W, X, Y, Z

    print(kAudioChannelLayoutTag_Quadraphonic) // L R Ls Rs  -- 90 degree speaker separation
    print(kAudioChannelLayoutTag_Pentagonal) // L R Ls Rs C  -- 72 degree speaker separation
    print(kAudioChannelLayoutTag_Hexagonal) // L R Ls Rs C Cs  -- 60 degree speaker separation
    print(kAudioChannelLayoutTag_Octagonal) // L R Ls Rs C Cs Lw Rw  -- 45 degree speaker separation
    print(kAudioChannelLayoutTag_Cube) // left, right, rear left, rear right
    // top left, top right, top rear left, top rear right

    //  MPEG defined layouts
    print(kAudioChannelLayoutTag_MPEG_1_0) //  C
    print(kAudioChannelLayoutTag_MPEG_2_0) //  L R
    print(kAudioChannelLayoutTag_MPEG_3_0_A) //  L R C
    print(kAudioChannelLayoutTag_MPEG_3_0_B) //  C L R
    print(kAudioChannelLayoutTag_MPEG_4_0_A) //  L R C Cs
    print(kAudioChannelLayoutTag_MPEG_4_0_B) //  C L R Cs
    print(kAudioChannelLayoutTag_MPEG_5_0_A) //  L R C Ls Rs
    print(kAudioChannelLayoutTag_MPEG_5_0_B) //  L R Ls Rs C
    print(kAudioChannelLayoutTag_MPEG_5_0_C) //  L C R Ls Rs
    print(kAudioChannelLayoutTag_MPEG_5_0_D) //  C L R Ls Rs
    print(kAudioChannelLayoutTag_MPEG_5_1_A) //  L R C LFE Ls Rs
    print(kAudioChannelLayoutTag_MPEG_5_1_B) //  L R Ls Rs C LFE
    print(kAudioChannelLayoutTag_MPEG_5_1_C) //  L C R Ls Rs LFE
    print(kAudioChannelLayoutTag_MPEG_5_1_D) //  C L R Ls Rs LFE
    print(kAudioChannelLayoutTag_MPEG_6_1_A) //  L R C LFE Ls Rs Cs
    print(kAudioChannelLayoutTag_MPEG_7_1_A) //  L R C LFE Ls Rs Lc Rc
    print(kAudioChannelLayoutTag_MPEG_7_1_B) //  C Lc Rc L R Ls Rs LFE    (doc: IS-13818-7 MPEG2-AAC Table 3.1)
    print(kAudioChannelLayoutTag_MPEG_7_1_C) //  L R C LFE Ls Rs Rls Rrs
    print(kAudioChannelLayoutTag_Emagic_Default_7_1) //  L R Ls Rs C LFE Lc Rc
    print(kAudioChannelLayoutTag_SMPTE_DTV) //  L R C LFE Ls Rs Lt Rt
    //      (kAudioChannelLayoutTag_ITU_5_1 plus a matrix encoded stereo mix)

    //  ITU defined layouts
    print(kAudioChannelLayoutTag_ITU_1_0) //  C
    print(kAudioChannelLayoutTag_ITU_2_0) //  L R

    print(kAudioChannelLayoutTag_ITU_2_1) //  L R Cs
    print(kAudioChannelLayoutTag_ITU_2_2) //  L R Ls Rs
    print(kAudioChannelLayoutTag_ITU_3_0) //  L R C
    print(kAudioChannelLayoutTag_ITU_3_1) //  L R C Cs

    print(kAudioChannelLayoutTag_ITU_3_2) //  L R C Ls Rs
    print(kAudioChannelLayoutTag_ITU_3_2_1) //  L R C LFE Ls Rs
    print(kAudioChannelLayoutTag_ITU_3_4_1) //  L R C LFE Ls Rs Rls Rrs

    // DVD defined layouts
    print(kAudioChannelLayoutTag_DVD_0) // C (mono)
    print(kAudioChannelLayoutTag_DVD_1) // L R
    print(kAudioChannelLayoutTag_DVD_2) // L R Cs
    print(kAudioChannelLayoutTag_DVD_3) // L R Ls Rs
    print(kAudioChannelLayoutTag_DVD_4) // L R LFE
    print(kAudioChannelLayoutTag_DVD_5) // L R LFE Cs
    print(kAudioChannelLayoutTag_DVD_6) // L R LFE Ls Rs
    print(kAudioChannelLayoutTag_DVD_7) // L R C
    print(kAudioChannelLayoutTag_DVD_8) // L R C Cs
    print(kAudioChannelLayoutTag_DVD_9) // L R C Ls Rs
    print(kAudioChannelLayoutTag_DVD_10) // L R C LFE
    print(kAudioChannelLayoutTag_DVD_11) // L R C LFE Cs
    print(kAudioChannelLayoutTag_DVD_12) // L R C LFE Ls Rs
    // 13 through 17 are duplicates of 8 through 12.
    print(kAudioChannelLayoutTag_DVD_13) // L R C Cs
    print(kAudioChannelLayoutTag_DVD_14) // L R C Ls Rs
    print(kAudioChannelLayoutTag_DVD_15) // L R C LFE
    print(kAudioChannelLayoutTag_DVD_16) // L R C LFE Cs
    print(kAudioChannelLayoutTag_DVD_17) // L R C LFE Ls Rs
    print(kAudioChannelLayoutTag_DVD_18) // L R Ls Rs LFE
    print(kAudioChannelLayoutTag_DVD_19) // L R Ls Rs C
    print(kAudioChannelLayoutTag_DVD_20) // L R Ls Rs C LFE

    // These layouts are recommended for AudioUnit usage
    // These are the symmetrical layouts
    print(kAudioChannelLayoutTag_AudioUnit_4)
    print(kAudioChannelLayoutTag_AudioUnit_5)
    print(kAudioChannelLayoutTag_AudioUnit_6)
    print(kAudioChannelLayoutTag_AudioUnit_8)
    // These are the surround-based layouts
    print(kAudioChannelLayoutTag_AudioUnit_5_0) // L R Ls Rs C
    print(kAudioChannelLayoutTag_AudioUnit_6_0) // L R Ls Rs C Cs
    print(kAudioChannelLayoutTag_AudioUnit_7_0) // L R Ls Rs C Rls Rrs
    print(kAudioChannelLayoutTag_AudioUnit_7_0_Front) // L R Ls Rs C Lc Rc
    print(kAudioChannelLayoutTag_AudioUnit_5_1) // L R C LFE Ls Rs
    print(kAudioChannelLayoutTag_AudioUnit_6_1) // L R C LFE Ls Rs Cs
    print(kAudioChannelLayoutTag_AudioUnit_7_1) // L R C LFE Ls Rs Rls Rrs
    print(kAudioChannelLayoutTag_AudioUnit_7_1_Front) // L R C LFE Ls Rs Lc Rc

    print(kAudioChannelLayoutTag_AAC_3_0) // C L R
    print(kAudioChannelLayoutTag_AAC_Quadraphonic) // L R Ls Rs
    print(kAudioChannelLayoutTag_AAC_4_0) // C L R Cs
    print(kAudioChannelLayoutTag_AAC_5_0) // C L R Ls Rs
    print(kAudioChannelLayoutTag_AAC_5_1) // C L R Ls Rs Lfe
    print(kAudioChannelLayoutTag_AAC_6_0) // C L R Ls Rs Cs
    print(kAudioChannelLayoutTag_AAC_6_1) // C L R Ls Rs Cs Lfe
    print(kAudioChannelLayoutTag_AAC_7_0) // C L R Ls Rs Rls Rrs
    print(kAudioChannelLayoutTag_AAC_7_1) // C Lc Rc L R Ls Rs Lfe
    print(kAudioChannelLayoutTag_AAC_7_1_B) // C L R Ls Rs Rls Rrs LFE
    print(kAudioChannelLayoutTag_AAC_7_1_C) // C L R Ls Rs LFE Vhl Vhr
    print(kAudioChannelLayoutTag_AAC_Octagonal) // C L R Ls Rs Rls Rrs Cs

    print(kAudioChannelLayoutTag_TMH_10_2_std) // L R C Vhc Lsd Rsd Ls Rs Vhl Vhr Lw Rw Csd Cs LFE1 LFE2
    print(kAudioChannelLayoutTag_TMH_10_2_full) // TMH_10_2_std plus: Lc Rc HI VI Haptic

    print(kAudioChannelLayoutTag_AC3_1_0_1) // C LFE
    print(kAudioChannelLayoutTag_AC3_3_0) // L C R
    print(kAudioChannelLayoutTag_AC3_3_1) // L C R Cs
    print(kAudioChannelLayoutTag_AC3_3_0_1) // L C R LFE
    print(kAudioChannelLayoutTag_AC3_2_1_1) // L R Cs LFE
    print(kAudioChannelLayoutTag_AC3_3_1_1) // L C R Cs LFE

    print(kAudioChannelLayoutTag_EAC_6_0_A) // L C R Ls Rs Cs
    print(kAudioChannelLayoutTag_EAC_7_0_A) // L C R Ls Rs Rls Rrs

    print(kAudioChannelLayoutTag_EAC3_6_1_A) // L C R Ls Rs LFE Cs
    print(kAudioChannelLayoutTag_EAC3_6_1_B) // L C R Ls Rs LFE Ts
    print(kAudioChannelLayoutTag_EAC3_6_1_C) // L C R Ls Rs LFE Vhc
    print(kAudioChannelLayoutTag_EAC3_7_1_A) // L C R Ls Rs LFE Rls Rrs
    print(kAudioChannelLayoutTag_EAC3_7_1_B) // L C R Ls Rs LFE Lc Rc
    print(kAudioChannelLayoutTag_EAC3_7_1_C) // L C R Ls Rs LFE Lsd Rsd
    print(kAudioChannelLayoutTag_EAC3_7_1_D) // L C R Ls Rs LFE Lw Rw
    print(kAudioChannelLayoutTag_EAC3_7_1_E) // L C R Ls Rs LFE Vhl Vhr

    print(kAudioChannelLayoutTag_EAC3_7_1_F) // L C R Ls Rs LFE Cs Ts
    print(kAudioChannelLayoutTag_EAC3_7_1_G) // L C R Ls Rs LFE Cs Vhc
    print(kAudioChannelLayoutTag_EAC3_7_1_H) // L C R Ls Rs LFE Ts Vhc

    print(kAudioChannelLayoutTag_DTS_3_1) // C L R LFE
    print(kAudioChannelLayoutTag_DTS_4_1) // C L R Cs LFE
    print(kAudioChannelLayoutTag_DTS_6_0_A) // Lc Rc L R Ls Rs
    print(kAudioChannelLayoutTag_DTS_6_0_B) // C L R Rls Rrs Ts
    print(kAudioChannelLayoutTag_DTS_6_0_C) // C Cs L R Rls Rrs
    print(kAudioChannelLayoutTag_DTS_6_1_A) // Lc Rc L R Ls Rs LFE
    print(kAudioChannelLayoutTag_DTS_6_1_B) // C L R Rls Rrs Ts LFE
    print(kAudioChannelLayoutTag_DTS_6_1_C) // C Cs L R Rls Rrs LFE
    print(kAudioChannelLayoutTag_DTS_7_0) // Lc C Rc L R Ls Rs
    print(kAudioChannelLayoutTag_DTS_7_1) // Lc C Rc L R Ls Rs LFE
    print(kAudioChannelLayoutTag_DTS_8_0_A) // Lc Rc L R Ls Rs Rls Rrs
    print(kAudioChannelLayoutTag_DTS_8_0_B) // Lc C Rc L R Ls Cs Rs
    print(kAudioChannelLayoutTag_DTS_8_1_A) // Lc Rc L R Ls Rs Rls Rrs LFE
    print(kAudioChannelLayoutTag_DTS_8_1_B) // Lc C Rc L R Ls Cs Rs LFE
    print(kAudioChannelLayoutTag_DTS_6_1_D) // C L R Ls Rs LFE Cs

    print(kAudioChannelLayoutTag_WAVE_2_1) // 3 channels, L R LFE
    print(kAudioChannelLayoutTag_WAVE_3_0) // 3 channels, L R C
    print(kAudioChannelLayoutTag_WAVE_4_0_A) // 4 channels, L R Ls Rs
    print(kAudioChannelLayoutTag_WAVE_4_0_B) // 4 channels, L R Rls Rrs
    print(kAudioChannelLayoutTag_WAVE_5_0_A) // 5 channels, L R C Ls Rs
    print(kAudioChannelLayoutTag_WAVE_5_0_B) // 5 channels, L R C Rls Rrs
    print(kAudioChannelLayoutTag_WAVE_5_1_A) // 6 channels, L R C LFE Ls Rs
    print(kAudioChannelLayoutTag_WAVE_5_1_B) // 6 channels, L R C LFE Rls Rrs
    print(kAudioChannelLayoutTag_WAVE_6_1) // 7 channels, L R C LFE Cs Ls Rs
    print(kAudioChannelLayoutTag_WAVE_7_1) // 8 channels, L R C LFE Rls Rrs Ls Rs
}
