//
//  PlayerPreviewView.swift
//  RealtimeMatte
//
//  Created by ws on 2020/9/11.
//  Copyright © 2020 ws. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerPreviewView: UIView {
    
    var player: AVPlayer? {
        get { return (layer as! AVPlayerLayer).player }
        set { (layer as! AVPlayerLayer).player = newValue }
    }
    
    var videoGravity: AVLayerVideoGravity {
        get { return  (layer as! AVPlayerLayer).videoGravity }
        set {  (layer as! AVPlayerLayer).videoGravity = newValue }
    }

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

}
