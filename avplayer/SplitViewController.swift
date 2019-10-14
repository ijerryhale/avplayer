/**
    SplitViewController.swift
    avplayer

    Created by Jerry Hale on 10/10/19
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

class SplitViewController: NSSplitViewController
{
    private let playerViewHght:CGFloat = 220.0
    private let propertyViewHght:CGFloat = 220.0
    
    override func viewWillAppear()
    { super.viewWillAppear(); print("SplitViewController viewWillAppear")

        splitView.dividerStyle = .paneSplitter
        //  splitViewItems[1].canCollapse = true

        let playerView = splitViewItems[0].viewController.view
        let propertyView = splitViewItems[1].viewController.view
        
        //  set up playerView and propertyView Constraints
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.addConstraint(NSLayoutConstraint(item: playerView, attribute: .height,
                        relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height,
                        multiplier: 1.0, constant: playerViewHght / 2.0))
        
        let UNIMPED_SPLITTER = true

        if UNIMPED_SPLITTER
        {
            propertyView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
        else
        {
            propertyView.translatesAutoresizingMaskIntoConstraints = false
            propertyView.addConstraint(NSLayoutConstraint(item: propertyView, attribute: .height,
                         relatedBy: .lessThanOrEqual, toItem: nil, attribute: .height,
                         multiplier: 1.0, constant: propertyViewHght))
        }
    }
}
