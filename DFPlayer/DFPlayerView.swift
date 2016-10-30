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
    
    let playerLayerView = DFPlayerLayerView()
    
    var player: AVPlayer? {
        get {
            return (playerLayerView.layer as! AVPlayerLayer).player
        }
        set {
            (playerLayerView.layer as! AVPlayerLayer).player = newValue
        }
    }
    
    var loadingView: NVActivityIndicatorView? = nil {
        didSet {
            oldValue?.removeFromSuperview()
            guard let loadingView = self.loadingView else { return }
            self.addSubview(loadingView)
            loadingView.snp_makeConstraints(closure: { (make) in
                make.center.equalTo(self)
                make.width.height.equalTo(36)
            })
        }
    }
    
    internal init() {
        super.init(frame: CGRectZero)
        self.df_addSubViewEquirotal(playerLayerView)
        self.backgroundColor = UIColor.blackColor()
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






