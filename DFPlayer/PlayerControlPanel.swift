//
//  PlayerControlPanel.swift
//  DFPlayer
//
//  Created by Difff on 16/10/22.
//  Copyright © 2016年 Difff. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class PlayerControlPanel: NSObject {
    let container = UIView()
    let playButton: UIButton = {
        return DFButton()
    }()
    let backButton: UIButton = {
        return DFButton()
    }()
    let fullScreenButton: UIButton = {
        return DFButton()
    }()
    
    let titleLabel = UILabel()
    let currentSecondLabel = UILabel()
    let durationSecondsLabel = UILabel()
    let loadedProgress = UIProgressView()
    
    let playingSlider: UISlider = {
        return DFTimeSlider()
    }()
    
    var isSliderTouching = false
    var alreadyShow = true
    
    weak var delegate: PlayerControlPanelDelegate?
    
    override init() {
        super.init()
        setup()
        clear()
    }
    
    func clear() {
        playButton.selected = false
        fullScreenButton.selected = false
        currentSecondLabel.text = "00:00"
        durationSecondsLabel.text = "00:00"
        loadedProgress.progress = 0
        playingSlider.value = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PlayerControlPanel: DFPlayerControlable {
    
    func setup() {
        container.df_addSubviews([playButton, fullScreenButton, titleLabel, currentSecondLabel, durationSecondsLabel, loadedProgress, playingSlider])
        
//                let tapGR = UITapGestureRecognizer { [weak self](_) in
//                    guard let _self = self else { return }
//                    if _self.alreadyShow {
//                        _self.dismiss()
//                    } else {
//                        _self.show()
//                    }
//                    _self.delegate?.didControlPanelTap()
//                }
//                container.addGestureRecognizer(tapGR)
        
        
        
        titleLabel.snp_makeConstraints { (make) in
            make.centerY.equalTo(container.snp_top).offset(64/2)
            make.centerX.equalTo(container)
            make.left.equalTo(container).offset(60)
            make.right.equalTo(container).offset(-60)
        }
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        
        
        playButton.snp_makeConstraints { (make) in
            make.left.equalTo(container).offset(16)
            make.centerY.equalTo(container.snp_bottom).offset(-20)
            make.width.height.equalTo(30)
        }
        playButton.setImage(UIImage(named: "to_play"), forState: .Normal)
        playButton.setImage(UIImage(named: "to_pause"), forState: .Selected)
        playButton.addAction({ [weak self](_) in
            guard let _self = self else { return }
            _self.delegate?.didPlayButtonTap()
            }, forControlEvents: .TouchUpInside)
        
        
        fullScreenButton.snp_makeConstraints { (make) in
            make.right.equalTo(container).offset(-16)
            make.centerY.equalTo(playButton)
            make.width.height.equalTo(30)
        }
        fullScreenButton.setImage(UIImage(named: "to_landscape"), forState: .Normal)
        fullScreenButton.setImage(UIImage(named: "to_portrait"), forState: .Selected)
        
        fullScreenButton.addAction({ [weak self](sender) in
            guard let _self = self else { return }
            guard let button = sender as? UIButton else { return }
            _self.delegate?.didFullScreenTap(button)
            if !sender.selected {
                UIDevice.df_toLandscape()
            } else {
                UIDevice.df_toPortrait()
            }
            
            _self.delegate?.didFullScreenTap(button)
            
            sender.selected = !sender.selected
            
            }, forControlEvents: .TouchUpInside)
        
        currentSecondLabel.snp_makeConstraints { (make) in
            make.left.equalTo(playButton.snp_right).offset(5)
            make.centerY.equalTo(playButton)
            make.width.equalTo(35) // must
        }
        currentSecondLabel.font = UIFont.systemFontOfSize(12)
        currentSecondLabel.textColor = UIColor.whiteColor()
        
        durationSecondsLabel.snp_makeConstraints { (make) in
            make.right.equalTo(fullScreenButton.snp_left).offset(-5)
            make.centerY.equalTo(playButton)
        }
        durationSecondsLabel.font = UIFont.systemFontOfSize(12)
        durationSecondsLabel.textColor = UIColor.whiteColor()
        
        loadedProgress.snp_makeConstraints { (make) in
            make.left.equalTo(currentSecondLabel.snp_right).offset(5)
            make.right.equalTo(durationSecondsLabel.snp_left).offset(-5)
            make.centerY.equalTo(playButton)
            make.height.equalTo(DFTimeSlider.silderHeight)
        }
        
        loadedProgress.trackTintColor = UIColor.whiteColor()
        loadedProgress.progressTintColor = UIColor.greenColor()
        
        playingSlider.snp_makeConstraints { (make) in
            make.edges.equalTo(loadedProgress)
        }
        
        
        playingSlider.addAction({ [weak self](sender) in
            guard let _self = self else { return }
            guard let slider = sender as? UISlider else { return }
            _self.isSliderTouching = true
            _self.delegate?.didSliderTouchBegin(slider)
            
            }, forControlEvents: .TouchDown)
        
        playingSlider.addAction({ [weak self](sender) in
            guard let _self = self else { return }
            guard let slider = sender as? UISlider else { return }
            _self.delegate?.didSliderTouchMovie(slider)
            }, forControlEvents: .ValueChanged)
        
        playingSlider.addAction({ [weak self](sender) in
            guard let _self = self else { return }
            guard let slider = sender as? UISlider else { return }
            _self.isSliderTouching = false
            _self.delegate?.didSliderTouchEnd(slider)
            }, forControlEvents: .TouchUpInside)
        
    }
    
    func show() {
        alreadyShow = true
        UIView.animateWithDuration(0.5) {
            self.container.subviews.forEach({ $0.alpha = 1 })
        }
    }
    
    func dismiss() {
        alreadyShow = false
        UIView.animateWithDuration(0.5) {
            self.container.subviews.forEach({ $0.alpha = 0 })
        }
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
        return df_containsPoint(bounds, point: point)
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

class DFButton: UIButton {
    // increase click area("hot spot")
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return df_containsPoint(bounds, point: point)
    }
}

