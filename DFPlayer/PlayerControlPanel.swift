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
    let silderTipLabel = UILabel()
    let currentSecondLabel = UILabel()
    let durationSecondsLabel = UILabel()
    let loadedProgress = UIProgressView()
    
    let playingSlider: UISlider = {
        return DFTimeSlider()
    }()
    
    var isSliderTouching = false {
        didSet {
            if isSliderTouching {
                self.removeTimer()
            } else {
                self.addTimer()
            }
        }
    }
    var alreadyShow = true {
        didSet {
            if alreadyShow {
                self.addTimer()
            } else {
                self.removeTimer()
            }
        }
    }
    
    weak var delegate: PlayerControlPanelDelegate?

    
    private var beganLocation = CGPointZero
    private var beginSliderValue: Float = 0
    
    var movieDuration: NSTimeInterval = 0
    
    var autoDismissTimeInterval: NSTimeInterval = 4
    
    private var dismissTimer: NSTimer?
    
    func addTimer() {
        dismissTimer = NSTimer.scheduledTimerWithTimeInterval(self.autoDismissTimeInterval, action: { [weak self](_) in
            guard let _self = self else { return }
            if _self.alreadyShow {
                _self.dismiss()
            }
            }, repeats: false)
    }
    
    func removeTimer() {
        dismissTimer?.invalidate()
    }

    func clear() {
        playButton.selected = false
        fullScreenButton.selected = false
        currentSecondLabel.text = "00:00"
        durationSecondsLabel.text = "00:00"
        loadedProgress.progress = 0
        playingSlider.value = 0
    }
    
    var tapGR: UITapGestureRecognizer!
    var panGR: UIPanGestureRecognizer!

    override init() {
        super.init()
        setup()
        clear()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PlayerControlPanel: DFPlayerControlable {
    
    func setup() {
        tapGR = UITapGestureRecognizer { [weak self](_) in
            guard let _self = self else { return }
            if _self.alreadyShow {
                _self.dismiss()
            } else {
                _self.show()
            }
            _self.delegate?.didControlPanelTap()
        }
        container.addGestureRecognizer(tapGR)
        
        panGR = UIPanGestureRecognizer { [weak self](gesture) in
            guard let _self = self where _self.playingSlider.userInteractionEnabled else { return }
            if gesture.state == .Began {
                _self.beganLocation = gesture.locationInView(_self.container)
                _self.beginSliderValue = _self.playingSlider.value
                _self.slideBegan()
            } else if gesture.state == .Changed {
                gesture.locationInView(_self.container)
                let curLocation = gesture.locationInView(_self.container)
                let gap = curLocation.x - _self.beganLocation.x
                if fabs(gap) > 0 {
                    let rate = gap/_self.container.bounds.width
                    let newValue = _self.beginSliderValue + Float(0.2*rate)
                    _self.playingSlider.value = newValue < 1 ? newValue : 1
                }
                _self.slideMovie()
            } else if gesture.state == .Ended {
                _self.slideEnded()
            }
        }
        container.addGestureRecognizer(panGR)
        
        tapGR.requireGestureRecognizerToFail(panGR)

        
        container.df_addSubviews([playButton, fullScreenButton, titleLabel, silderTipLabel, currentSecondLabel, durationSecondsLabel, loadedProgress, playingSlider])
        
        playButton.snp_makeConstraints { (make) in
            make.left.equalTo(container).offset(16)
            make.centerY.equalTo(container.snp_bottom).offset(-20)
            make.width.height.equalTo(30)
        }
        playButton.setImage(UIImage(named: "to_play"), forState: .Normal)
        playButton.setImage(UIImage(named: "to_pause"), forState: .Selected)
        playButton.addAction({ [weak self](_) in
            guard let _self = self else { return }
            _self.removeTimer()
            }, forControlEvents: .TouchDown)
        playButton.addAction({ [weak self](_) in
            guard let _self = self else { return }
            _self.addTimer()
            _self.delegate?.didPlayButtonTap()
            }, forControlEvents: .TouchUpInside)
        
        
        fullScreenButton.snp_makeConstraints { (make) in
            make.right.equalTo(container).offset(-16)
            make.centerY.equalTo(playButton)
            make.width.height.equalTo(30)
        }
        fullScreenButton.setImage(UIImage(named: "to_landscape"), forState: .Normal)
        fullScreenButton.setImage(UIImage(named: "to_portrait"), forState: .Selected)
        
        fullScreenButton.addAction({ [weak self](_) in
            guard let _self = self else { return }
            _self.removeTimer()
            }, forControlEvents: .TouchDown)
        fullScreenButton.addAction({ [weak self](sender) in
            guard let _self = self else { return }
            _self.addTimer()
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
        
        titleLabel.snp_makeConstraints { (make) in
            make.centerY.equalTo(container.snp_top).offset(64/2)
            make.centerX.equalTo(container)
            make.left.equalTo(container).offset(60)
            make.right.equalTo(container).offset(-60)
        }
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        
        silderTipLabel.snp_makeConstraints { (make) in
            make.center.equalTo(container)
        }
        silderTipLabel.font = UIFont.boldSystemFontOfSize(20)
        silderTipLabel.textColor = UIColor.whiteColor()
        silderTipLabel.textAlignment = .Center
        
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
            _self.slideBegan()
            }, forControlEvents: .TouchDown)
        
        
        playingSlider.addAction({ [weak self](sender) in
            guard let _self = self else { return }
            _self.slideMovie()
            }, forControlEvents: .ValueChanged)
        
        playingSlider.addAction({ [weak self](sender) in
            guard let _self = self else { return }
            _self.slideEnded()
            }, forControlEvents: [.TouchUpInside, .TouchUpOutside])
    }
    
    func show() {
        alreadyShow = true
        UIView.animateWithDuration(0.3) {
            self.container.subviews.forEach({ $0.alpha = 1 })
        }
    }
    
    func dismiss() {
        alreadyShow = false
        UIView.animateWithDuration(0.3) {
            self.container.subviews.forEach({ $0.alpha = 0 })
            self.silderTipLabel.alpha = 1
        }
    }

    private func slideBegan() {
        container.removeGestureRecognizer(tapGR)
        isSliderTouching = true
        silderTipLabel.hidden = false
        delegate?.didSliderTouchBegin(playingSlider)
    }
    
    private func slideMovie() {
        silderTipLabel.text = Int(Double(playingSlider.value) * movieDuration).df_toHourFormat()
        delegate?.didSliderTouchMovie(playingSlider)
    }
    
    private func slideEnded() {
        container.addGestureRecognizer(tapGR)
        isSliderTouching = false
        silderTipLabel.hidden = true
        delegate?.didSliderTouchEnd(playingSlider)
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
        return self.df_containsPoint(bounds, point: point)
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
        return self.df_containsPoint(bounds, point: point)
    }

}

