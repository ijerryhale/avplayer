/**
    AVTrack.swift
    avplayer

    Created by Jerry Hale on 10/22/19
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

struct TrackInfo: Decodable
{
    private enum CodingKeys: String, CodingKey { case name, info }

    var name: String
    var info: String
}

struct TrackFormat: Decodable
{
    private enum CodingKeys: String, CodingKey { case fcc, info }

    var fcc: String
    var info: String
}

class TrackAudioFormat
{
    static let shared: TrackAudioFormat =
    {
        let instance = TrackAudioFormat()
        // setup code if anything
        return (instance)
    }()

    var format: [TrackFormat]

    private init()
    {
        let url = Bundle.main.url(forResource: "track_audio_format", withExtension: "plist")!
        let data = try! Data(contentsOf: url)

        try! format = PropertyListDecoder().decode([TrackFormat].self, from: data)
    }
}

//  MARK: AVTrack
class AVTrack: NSObject
{
    var assetTrack:AVAssetTrack
    var trackInfo:TrackInfo
    
    var mediaType: AVMediaType { get { return (assetTrack.mediaType) } }
    var trackID: CMPersistentTrackID { get { return (assetTrack.trackID) } }
    var isEnabled: Bool { get { return (assetTrack.isEnabled) } }
    var duration: CMTime { get { return (assetTrack.timeRange.duration) } }
    var language: String { get { return (langForTrack(assetTrack)) } }
    var formatDesc: CMFormatDescription { get { return (assetTrack.formatDescriptions[0] as! CMFormatDescription) } }
    
    init(_ track: AVAssetTrack)
    {
        assetTrack = track
        trackInfo = TrackInfo(name: "", info: "")
    }
}

//  MARK: AVTrackVideo
class AVTrackVideo: AVTrack
{
    var dimensions:CMVideoDimensions?
    var frameRate:Float?

    override init(_ track: AVAssetTrack)
    { super.init(track)

        //  AVAssetTrack.nominalFrameRate is
        //  real frame rate for video track
        frameRate = track.nominalFrameRate
        trackInfo.name = "Video Track"

        if let colorBits = CMFormatDescriptionGetExtension(formatDesc, extensionKey: kCMFormatDescriptionExtension_Depth)
        { trackInfo.info = "\(colorBits)-bit, " }

        if let formatName = CMFormatDescriptionGetExtension(formatDesc, extensionKey: kCMFormatDescriptionExtension_FormatName)
        {
            var codecText:String = ""
            switch formatName as! String
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
                    codecText = formatName as! String
                break
            }
    
            trackInfo.info += "\(codecText), "
        }
        
        let dimension =  CMVideoFormatDescriptionGetDimensions(formatDesc)
        
        trackInfo.info += "\(dimension.width) x \(dimension.height)"
     }
}


private let kAudioFormatUknown:AudioFormatID = 0
//  MARK: AVTrackAudio
class AVTrackAudio: AVTrack
{
    private var formatID: [AudioFormatID] = [kAudioFormatUknown, kAudioFormatLinearPCM, kAudioFormatAC3, kAudioFormatAppleIMA4,
                                             kAudioFormatMPEG4AAC, kAudioFormatMACE3, kAudioFormatMACE6,
                                             kAudioFormatULaw, kAudioFormatALaw, kAudioFormatMPEGLayer1, kAudioFormatMPEGLayer2,
                                             kAudioFormatMPEGLayer3, kAudioFormatAppleLossless]
    override init(_ track: AVAssetTrack)
    { super.init(track)
        
        let format:[TrackFormat] = TrackAudioFormat.shared.format
        var aclSize:Int = 0
        var basicInfo:String = ""

        //  get ASBC
        if let basicDesc:UnsafePointer<AudioStreamBasicDescription> = CMAudioFormatDescriptionGetStreamBasicDescription(formatDesc)
        {
            let bd = basicDesc.pointee
            
            if bd.mBitsPerChannel > 0 { basicInfo = " \(bd.mBitsPerChannel)-bit, " }

            var trackFormat = format[Int(kAudioFormatUknown)]
             
             var idx = formatID.firstIndex(of: bd.mFormatID)
             if idx != nil { trackFormat = format[idx!] }
             else
             {
                 // byte swap mFormatID and look again
                 idx = formatID.firstIndex(of: CFSwapInt32(bd.mFormatID))
                 if idx != nil { trackFormat = format[idx!] }
             }

             basicInfo += " \(trackFormat.info), "

            if bd.mFormatFlags > 0
            {
                if bd.mFormatFlags & kAudioFormatFlagIsFloat == 0 { basicInfo += "Integer " }
                else {basicInfo += "Floating Point " }

                if bd.mFormatFlags & kAudioFormatFlagIsBigEndian == 0 { basicInfo += "(Little Endian), " }
                else {basicInfo += "(Big Endian), " }
            }

            if bd.mSampleRate > 0 { basicInfo += " \(bd.mSampleRate / 1000.000) kHz" }
        }
        else
        {
            let error = NSError(domain: "com.jhale.avplayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "No: AudioStreamBasicDescription for AVAudioTrack"])

            handleErrorWithMessage("Failure:AVAudioTrack.init", error: error)
        }
        trackInfo.name = "Sound Track"
        
        //  print(basicInfo)
        if basicInfo.count > 0 { trackInfo.info = basicInfo }

        //  if there is a channel layout
        //  try to get the channel name
        if let channelLayoutPtr:UnsafePointer<AudioChannelLayout> = CMAudioFormatDescriptionGetChannelLayout(formatDesc, sizeOut: &aclSize)
        {
            //  print(channelLayout.pointee)
            var nameSize:UInt32 = 0

            //  simple name for NAME column in TableView
            let sizeError:OSStatus = AudioFormatGetPropertyInfo(kAudioFormatProperty_ChannelLayoutSimpleName, UInt32(aclSize), channelLayoutPtr, &nameSize)
            if sizeError > 0 { print(sizeError) }

            let count:Int = Int(nameSize) / MemoryLayout<CFString>.size
            let simpleNamePtr = UnsafeMutablePointer<CFString>.allocate(capacity: count)
            
            let propError:OSStatus = AudioFormatGetProperty(kAudioFormatProperty_ChannelLayoutSimpleName, UInt32(aclSize), channelLayoutPtr, &nameSize, simpleNamePtr)
            if propError > 0 { print(propError) }
            else { trackInfo.name = simpleNamePtr.pointee as String }
            //  print (simpleNamePtr.pointee as Any)
        }
        else
        {
            let error = NSError(domain: "com.jhale.avplayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "No: CMAudioFormatDescription for AVAudioTrack"])

            handleErrorWithMessage("Failure:AVAudioTrack.init", error: error)
        }
    }
}

//  MARK: AVTrackSubtitle
class AVTrackSubtitle: AVTrack
{
    override init(_ track: AVAssetTrack)
    { super.init(track)

        trackInfo.name = "Subtitle Track"
    }
}

//  MARK: AVTrackClosedCaptioned
class AVTrackClosedCaptioned: AVTrack
{
    override init(_ track: AVAssetTrack)
    { super.init(track)

        trackInfo.name = "Closed Captioned Track"
    }
}

//  MARK: AVTrackTimecode
class AVTrackTimecode: AVTrack
{
    override init(_ track: AVAssetTrack)
    { super.init(track)

        trackInfo.name = "Timecode Track"
    }
}


