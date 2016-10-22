//
//  DFPlayerStateEyeable.swift
//  DFPlayer
//
//  Created by Difff on 16/10/15.
//  Copyright © 2016年 Difff. All rights reserved.
//

import UIKit
import NVActivityIndicatorView


protocol DFPlayerControlPanelProtocol: class {
    // @required
    var container: UIView { get }
    var playButton: UIButton { get }
    var backButton: UIButton { get }
    var titleLabel: UILabel { get }
    var currentSecondLabel: UILabel { get }
    var durationSecondsLabel: UILabel { get }
    var loadedProgress: UIProgressView { get }
    var playingSlider: UISlider { get }

    var loadingView: NVActivityIndicatorView { get }

    
    // @optional
    func titleForVideo() -> String
    /* for layout & style */
    func setupControlPanel()
}


extension DFPlayerControlPanelProtocol {
    func titleForVideo() -> String {
        return ""
    }
    
    func setupControlPanel() {
        container.df_addSubviews([playButton, backButton, titleLabel, currentSecondLabel, durationSecondsLabel, loadedProgress, playingSlider, loadingView])
        
        backButton.snp_makeConstraints { (make) in
            make.centerY.equalTo(container.snp_top).offset(64/2)
            make.centerX.equalTo(container.snp_left).offset(16+6)
            make.width.height.equalTo(64)
        }
        backButton.setImage(UIImage(named: "back"), forState: .Normal)
        
        titleLabel.snp_makeConstraints { (make) in
            make.centerY.equalTo(backButton)
            make.left.equalTo(backButton.snp_centerX).offset(16)
        }
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = titleForVideo()
        
        playButton.snp_makeConstraints { (make) in
            make.left.equalTo(container).offset(16)
            make.centerY.equalTo(container.snp_bottom).offset(-20)
            make.width.height.equalTo(30)
        }
        playButton.setImage(UIImage(named: "to_play"), forState: .Normal)
        playButton.setImage(UIImage(named: "to_pause"), forState: .Selected)
        playButton.selected = false
        
        
        currentSecondLabel.snp_makeConstraints { (make) in
            make.left.equalTo(playButton.snp_right).offset(5)
            make.centerY.equalTo(playButton)
            make.width.equalTo(35) // must
        }
        currentSecondLabel.font = UIFont.systemFontOfSize(12)
        currentSecondLabel.textColor = UIColor.whiteColor()
        currentSecondLabel.text = "00:00"
        
        durationSecondsLabel.snp_makeConstraints { (make) in
            make.right.equalTo(container).offset(-16)
            make.centerY.equalTo(playButton)
        }
        durationSecondsLabel.font = UIFont.systemFontOfSize(12)
        durationSecondsLabel.textColor = UIColor.whiteColor()
        durationSecondsLabel.text = "00:00"
        
        loadedProgress.snp_makeConstraints { (make) in
            make.left.equalTo(currentSecondLabel.snp_right).offset(5)
            make.right.equalTo(durationSecondsLabel.snp_left).offset(-5)
            make.centerY.equalTo(playButton)
            make.height.equalTo(DFTimeSlider.silderHeight)
        }
        
        loadedProgress.trackTintColor = UIColor.whiteColor()
        loadedProgress.progressTintColor = UIColor.greenColor()
        loadedProgress.progress = 0
        
        playingSlider.snp_makeConstraints { (make) in
            make.edges.equalTo(loadedProgress)
        }
        playingSlider.value = 0
        
        loadingView.snp_makeConstraints { (make) in
            make.center.equalTo(container)
            make.width.height.equalTo(36)
        }
        loadingView.stopAnimation()
    }
}





