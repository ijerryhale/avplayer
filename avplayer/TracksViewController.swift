/**
    TracksViewController.swift
    avplayer

    Created by Jerry Hale on 10/17/19
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

class CheckBoxTableCellView : NSTableCellView
{
    @IBOutlet weak var checkbox: NSButton!
}

//    MARK: TracksViewController
class TracksViewController: NSViewController
{
    struct CellIdent
    {
        static let ID = "ID"
        static let ISENABLED = "ISENABLED"
        static let NAME = "NAME"
        static let DURATION = "DURATION"
        static let LANGUAGE = "LANGUAGE"
        static let INFO = "INFO"
    }

    var track : [AVTrack]?

    @IBOutlet weak var tableView: NSTableView!

    @IBAction func isEnabledClicked(_ sender: NSButton)
    {
//        let t = track![sender.tag].assetTrack as! AVMutableMovieTrack
//
//        t.isEnabled = !t.isEnabled
//
//        print(t.isEnabled)
    }
    
    //  MARK: @objc
    @objc func refreshTrackData(_ notification: Notification)
    {
        //  AVAssetTrack
        if let asset = notification.object as? AVAsset
        {
            track = [AVTrack]()
            
            var newTrack:AVTrack?
            
            for t in asset.tracks
            {
                switch t.mediaType
                {
                    case .video:
                        newTrack = AVTrackVideo(t);             /* print("video") */
                    break
                    case .audio:
                        newTrack = AVTrackAudio(t);             /* print("audio") */
                    break
                    case .text:
                        newTrack = AVTrackSubtitle(t);          /* print("text") */
                    break
                    case .closedCaption:
                        newTrack = AVTrackClosedCaptioned(t);   /* print("closed caption") */
                    break
                    case .subtitle:
                        newTrack = AVTrackSubtitle(t)           /* print("subtitle") */
                    break
                    case .timecode:
                        newTrack = AVTrackTimecode(t)           /* print("timecode") */
                    break
                    case .text, .metadata, .depthData:
                        print("text, metadata, depth data")
                    break
                    default:
                        print("unknown")
                    break
                }
                
                track?.append(newTrack!)
            }

            tableView.reloadData()
        }
    }

    //  MARK: overrides
    //  override func awakeFromNib() { }
    //  override func viewWillAppear()
    //  { super.viewWillAppear(); print("TracksViewController viewWillAppear") }
    override func viewDidLoad()
    {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(lessThanOrEqualToConstant: LOWER_VIEW_HGHT).isActive = true

        ////    refreshTrackData(notification: Notification)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTrackData(_:)),
                                               name: Notification.Name(rawValue: NOTIF_NEW_ASSET), object: nil)
    }
}

//    MARK: NSTableViewDelegate, NSTableViewDataSource
extension TracksViewController : NSTableViewDelegate, NSTableViewDataSource
{
    func numberOfRows(in tableView: NSTableView) -> Int { return (track?.count ?? 0) }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        var cid: String = ""
        guard let item = track?[row] else { return (nil) }

        if tableColumn == tableView.tableColumns[0] { cid = CellIdent.ID }
        else if tableColumn == tableView.tableColumns[1] { cid = CellIdent.ISENABLED }
        else if tableColumn == tableView.tableColumns[2] { cid = CellIdent.NAME }
        else if tableColumn == tableView.tableColumns[3] { cid = CellIdent.DURATION }
        else if tableColumn == tableView.tableColumns[4] { cid = CellIdent.LANGUAGE }
        else if tableColumn == tableView.tableColumns[5] { cid = CellIdent.INFO }

        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cid), owner: nil) as? NSTableCellView
        {
            if cid == CellIdent.ID
            {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center

                let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: NSColor.gray, .paragraphStyle: paragraphStyle]

                cell.textField?.attributedStringValue = NSAttributedString(string: item.trackID.description, attributes: attributes)
            }
            else if cid == CellIdent.ISENABLED
            {
                let c = cell as! CheckBoxTableCellView

                if item is AVTrackAudio || item is AVTrackVideo
                {
                    c.checkbox.tag = row
                    c.checkbox.isHidden = false
                    c.checkbox.intValue = item.isEnabled ? 1 : 0
                }
                else { c.checkbox.isHidden = true }
            }
            else if cid == CellIdent.NAME { cell.textField?.stringValue = item.trackInfo.name }
            else if cid == CellIdent.DURATION
            {
                if item is AVTrackVideo
                {
                    let t = item as! AVTrackVideo
                    let fr = t.frameRate!
                    
                    let time = Float(CMTimeGetSeconds(t.duration))
                    let frame = Int(time * fr)
                    let FF = Int(Float(frame).truncatingRemainder(dividingBy: fr))
                    let seconds = Int(Float(frame - FF) / fr)
                    let SS = seconds % 60
                    let MM = (seconds % 3600) / 60
                    let HH = seconds / 3600

                    cell.textField?.stringValue = String(format: "%02i:%02i:%02i:%02i", HH, MM, SS, FF)
               }
               else { cell.textField?.stringValue = item.duration.durationText }
            }
            else if cid == CellIdent.LANGUAGE { cell.textField?.stringValue = item.language }
            else if cid == CellIdent.INFO { cell.textField?.stringValue = item.trackInfo.info }

            return (cell)
        }
    
        return (nil)
    }
}
