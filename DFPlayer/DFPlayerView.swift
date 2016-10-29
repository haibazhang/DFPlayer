//
//  DFPlayerView.swift
//  DFPlayer
//
//  Created by Difff on 16/10/13.
//  Copyright © 2016年 Difff. All rights reserved.
//

import UIKit
import AVFoundation
import NVActivityIndicatorView

class DFPlayerView: UIView {
    deinit {
        print("deinit: - \(self)")
    }
    
    private(set) var loadingView: NVActivityIndicatorView?
    
    let playerLayerView = DFPlayerLayerView()
    
    private(set) var player: AVPlayer? {
        get {
            return (playerLayerView.layer as! AVPlayerLayer).player
        }
        set {
            (playerLayerView.layer as! AVPlayerLayer).player = newValue
        }
    }
    
//    override class func layerClass() -> AnyClass {
//        return AVPlayerLayer.self
//    }

    
    internal init(player: AVPlayer, loadingView: NVActivityIndicatorView?) {
        super.init(frame: CGRectZero)
        
        self.df_addMaskView(playerLayerView)
        
        self.player = player
        self.loadingView = loadingView
        self.backgroundColor = UIColor.blackColor()
        
        if let ldView = loadingView {
            self.addSubview(ldView)
            ldView.snp_makeConstraints(closure: { (make) in
                make.center.equalTo(self)
                make.width.height.equalTo(36)
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DFPlayerLayerView: UIView {
    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }
}






