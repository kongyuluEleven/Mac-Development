//
//  KWindow.swift
//  KLyricsAnalysisDemo
//
//  Created by kongyulu on 2020/9/4.
//  Copyright © 2020 wondershare. All rights reserved.
//

import Cocoa

class KWindow: NSWindow {

    @IBOutlet weak var lrcButton: NSButton!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        self.windowController = RootViewController()
    }
}
