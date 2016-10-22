//
//  PlayerControlPanel.swift
//  DFPlayer
//
//  Created by Difff on 16/10/22.
//  Copyright © 2016年 Difff. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class PlayerControlPanel: UIView {
    let container = UIView()
    let playButton = UIButton()
    let backButton = UIButton()
    let titleLabel = UILabel()
    let currentSecondLabel = UILabel()
    let durationSecondsLabel = UILabel()
    let loadedProgress = UIProgressView()
    
    let loadingView = NVActivityIndicatorView(frame: CGRectZero, type: .BallRotateChase, color: UIColor.whiteColor(), padding: 0)

    
    private var _slider = DFTimeSlider()
    var playingSlider: UISlider {
        get {
            return _slider
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupControlPanel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension PlayerControlPanel: DFPlayerControlPanelProtocol {
    func titleForVideo() -> String {
        return "video title"
    }
}


class DFTimeSlider: UISlider {
    static let silderHeight: CGFloat = 2.5
    // custom height
    override func trackRectForBounds(bounds: CGRect) -> CGRect {
        super.trackRectForBounds(bounds)
        return CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: DFTimeSlider.silderHeight))
    }
    
    // increase click area("hot spot")
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let widthDelta = fmax(44 - bounds.width, 0)
        let heightDelta = fmax(44 - bounds.height, 0)
        return CGRectContainsPoint(CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta), point)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setThumbImage(UIImage(named: "slider_thumb"), forState: .Normal)
        maximumTrackTintColor = UIColor.clearColor()
        minimumTrackTintColor = UIColor.orangeColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



