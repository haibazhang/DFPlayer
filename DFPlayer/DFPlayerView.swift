//
//  DFPlayerView.swift
//  DFPlayer
//
//  Created by Difff on 16/10/13.
//  Copyright © 2016年 Difff. All rights reserved.
//

import UIKit
import AVFoundation

class DFPlayerView: UIView {
    deinit {
        print("deinit: - \(self)")
    }
    
    internal var player: AVPlayer? {
        get {
            return (self.layer as! AVPlayerLayer).player
        }
        
        set {
            (self.layer as! AVPlayerLayer).player = newValue
        }
    }
    
    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }
}







