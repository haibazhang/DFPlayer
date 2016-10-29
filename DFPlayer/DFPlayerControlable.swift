//
//  DFPlayerStateEyeable.swift
//  DFPlayer
//
//  Created by Difff on 16/10/15.
//  Copyright © 2016年 Difff. All rights reserved.
//

import UIKit
import NVActivityIndicatorView


protocol DFPlayerControlable: class {
    // @required
    var container: UIView { get }
    var playButton: UIButton { get }
    var fullScreenButton: UIButton { get }
    var titleLabel: UILabel { get }
    var currentSecondLabel: UILabel { get }
    var durationSecondsLabel: UILabel { get }
    var loadedProgress: UIProgressView { get }
    var playingSlider: UISlider { get }
    var isSliderTouching: Bool { get set }
    var alreadyShow: Bool { get set }

    /* for layout & style */
    func setup()
    func show()
    func dismiss()
    
    // @optional
    func titleForVideo() -> String
}

extension DFPlayerControlable {
    func titleForVideo() -> String {
        return ""
    }
}

