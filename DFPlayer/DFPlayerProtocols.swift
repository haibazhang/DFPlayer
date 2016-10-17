//
//  Protocol.swift
//  DFPlayer
//
//  Created by Difff on 16/10/15.
//  Copyright © 2016年 Difff. All rights reserved.
//

import UIKit

protocol DFPlayerDelagate: class {
    // @optional
    func playerStatusDidChange(status: DFPlayerState)
    func durationSeconds(second: Int)
    func loadedSecondsDidChange(seconds: Int)
    func currentSecondDidChange(seconds: Int)
}

// DFPlayerDelagate: Default Implementaion
extension DFPlayerDelagate {
    func playerStatusDidChange(status: DFPlayerState) {}
    func durationSeconds(seconds: Int) {}
    func loadedSecondsDidChange(seconds: Int) {}
    func currentSecondDidChange(second: Int) {}
}


protocol DFPlayerStateEyeable: class {
    // @required
    var container: UIView { get }
    
    // @optional
    var backButton: UIButton { get }
    var titleLabel: UILabel { get }
    var currentSecondLabel: UILabel { get }
    var durationSecondsLabel: UILabel { get }
    var loadedProgress: UIProgressView { get }
    var playingSlider: UISlider { get }
    
    /* for layout & style */
    func setupPlayerStateUI()
    
    func setDurationSeconds(seconds: Int)
    func setCurrentSecond(second: Int, duration: Int)
    func setLoadedSeconds(seconds: Int, duration: Int)
    
    func didTapBackButton()
    func titleForVideo() -> String
}

// DFPlayerStateEyeable: Default Implementaion
private class DFAssociation: NSObject {
    static let sharedInstance = DFAssociation()
    private override init() {}
    let backButton = UIButton()
    let titleLabel = UILabel()
    let currentSecondLabel = UILabel()
    let durationSecondsLabel = UILabel()
    let loadedProgress = UIProgressView()
    let playingSlider = DFTimeSlider()
}

extension DFPlayerStateEyeable {
    var backButton: UIButton {
        get {
            return DFAssociation.sharedInstance.backButton
        }
    }
    
    var titleLabel: UILabel {
        get {
            return DFAssociation.sharedInstance.titleLabel
        }
    }
    
    var currentSecondLabel: UILabel {
        get {
            return DFAssociation.sharedInstance.currentSecondLabel
        }
    }
    
    var durationSecondsLabel: UILabel {
        get {
            return DFAssociation.sharedInstance.durationSecondsLabel
        }
    }
    
    var loadedProgress: UIProgressView {
        get {
            return DFAssociation.sharedInstance.loadedProgress
        }
    }
    
    var playingSlider: UISlider {
        get {
            return DFAssociation.sharedInstance.playingSlider
        }
    }
    
    func setupPlayerStateUI() {
        
        container.df_addSubviews([backButton, titleLabel, currentSecondLabel, durationSecondsLabel, loadedProgress, playingSlider])
        
        backButton.snp_makeConstraints { (make) in
            make.centerY.equalTo(container.snp_top).offset(64/2)
            make.centerX.equalTo(container.snp_left).offset(16+6)
            make.width.height.equalTo(64)
        }
        backButton.setImage(UIImage(named: "back"), forState: .Normal)
        backButton.addAction({ [weak self](_) in
            guard let _self = self else { return }
            _self.didTapBackButton()
            }, forControlEvents: .TouchUpInside)
        
        titleLabel.snp_makeConstraints { (make) in
            make.centerY.equalTo(backButton)
            make.left.equalTo(backButton.snp_centerX).offset(16)
        }
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = titleForVideo()
        
        currentSecondLabel.snp_makeConstraints { (make) in
            make.left.equalTo(container).offset(16)
            make.centerY.equalTo(container.snp_bottom).offset(-20)
            make.width.equalTo(35) // must
        }
        currentSecondLabel.font = UIFont.systemFontOfSize(12)
        currentSecondLabel.textColor = UIColor.whiteColor()
        currentSecondLabel.text = "00:00"
        
        durationSecondsLabel.snp_makeConstraints { (make) in
            make.right.equalTo(container).offset(-16)
            make.centerY.equalTo(currentSecondLabel)
        }
        durationSecondsLabel.font = UIFont.systemFontOfSize(12)
        durationSecondsLabel.textColor = UIColor.whiteColor()
        durationSecondsLabel.text = "00:00"
        
        
        loadedProgress.snp_makeConstraints { (make) in
            make.left.equalTo(currentSecondLabel.snp_right).offset(5)
            make.right.equalTo(durationSecondsLabel.snp_left).offset(-5)
            make.centerY.equalTo(currentSecondLabel)
            make.height.equalTo(2.5)
        }
        
        loadedProgress.trackTintColor = UIColor.whiteColor()
        loadedProgress.progressTintColor = UIColor.greenColor()
        loadedProgress.progress = 0
        
        playingSlider.snp_makeConstraints { (make) in
            make.edges.equalTo(loadedProgress)
        }

        playingSlider.value = 0
    }

    
    func setDurationSeconds(seconds: Int) {
        durationSecondsLabel.text = seconds.toHourFormat()
    }
    
    func setCurrentSecond(second: Int, duration: Int) {
        currentSecondLabel.text = second.toHourFormat()
        playingSlider.value = Float(second)/Float(duration)
    }
    
    func setLoadedSeconds(seconds: Int, duration: Int) {
        guard seconds > 0 && seconds <= duration else { return }
        let progress = Float(seconds)/Float(duration)
        loadedProgress.setProgress(progress, animated: false)
    }
    
    func didTapBackButton() {}
    
    func titleForVideo() -> String {
        return ""
    }
}


private extension Int {
    func toHourFormat() -> String {
        let hour = self/3600
        let minute = self%3600/60
        let second = self%3600%60
        
        if (hour > 0) {
            return String(format: "%02d:%02d:%02d", hour, minute, second)
        } else {
            return String(format: "%02d:%02d", minute, second)
        }
    }
}

private extension UIView {
    func df_addSubviews(subviews: [UIView]) {
        for view in subviews {
            self.addSubview(view)
        }
    }
}


private class DFTimeSlider: UISlider {
    override func trackRectForBounds(bounds: CGRect) -> CGRect {
        // change height
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 2.5))
        super.trackRectForBounds(customBounds)
        return customBounds
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setThumbImage(UIImage(named: "slider_thumb"), forState: .Normal)
        self.maximumTrackTintColor = UIColor.clearColor()
        self.minimumTrackTintColor = UIColor.orangeColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}






