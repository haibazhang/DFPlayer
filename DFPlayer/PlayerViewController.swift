//
//  PlayerViewController.swift
//  DFPlayer
//
//  Created by Difff on 16/10/13.
//  Copyright © 2016年 Difff. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

let testURLString1 = "http://www.html5videoplayer.net/videos/toystory.mp4"
let testURLString2 = "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4"

class PlayerViewController: UIViewController {

    deinit {
        print("deinit: - \(self)")
    }
    
    lazy var playerItem: AVPlayerItem = {
        return AVPlayerItem(URL: NSURL(string: testURLString1)!)
    }()
    
    lazy var player: DFPlayer = {
        return DFPlayer(playerItem: self.playerItem, delegate: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        setupPlayerView()
        
        setupLoadingView()
        
        setupControlPanel()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setupPlayerView() {
        let supView = view
        supView.addSubview(player.playerView)
        player.playerView.snp_makeConstraints { (make) in
            make.top.left.equalTo(supView)
            make.width.equalTo(screenWidth)
            make.height.equalTo(screenWidth*(screenWidthHeightRate))
        }
        player.playerView.backgroundColor = UIColor.blackColor()
    }
}

extension PlayerViewController: DFPlayerLoadingEyeable {
    var lv_container: UIView {
        get {
            return self.player.playerView
        }
    }
}

extension PlayerViewController: DFPlayerControlEyeable {
    var cp_container: UIView {
        get {
            return self.player.playerView
        }
    }
}

extension PlayerViewController: DFPlayerDelagate {
    func durationSeconds(seconds: NSTimeInterval) {
        print("duration: - \(seconds) seconds")
        
        durationSecondsLabel.text = Int(seconds).toHourFormat()
    }
    
    func currentSecondDidChange(second: NSTimeInterval) {
        print("current: - \(second) second")
        
        currentSecondLabel.text = Int(second).toHourFormat()
        
        if !playingSlider.df_touchMovie && !player.seeking {
            playingSlider.value = Float(second/player.itemDurationSeconds)
        }
    }
    
    
    func loadedSecondsDidChange(seconds: NSTimeInterval) {
        print("loaded: - \(seconds) seconds")
        
        if seconds > player.itemDurationSeconds {
            fatalError("loaded > duration!!!")
        }
        
        let duration = player.itemDurationSeconds
        guard seconds >= 0 && duration > 0 else { return }
        let progress = Float(seconds)/Float(duration)
        loadedProgress.setProgress(progress, animated: true)
    }
    
    
    func didTapBackButton() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func titleForVideo() -> String {
        return "video title"
    }
    
    func startLoading() {
        loadingView.hidden = false
        loadingView.startAnimation()
    }
    
    func stopLoading() {
        loadingView.hidden = true
        loadingView.stopAnimation()
    }
    
    func playerStateDidChange(state: DFPlayerState) {
        playButton.selected = (state == .Playing || state == .Starting)
    }
    
    func didTapPlayButton() {
        if player.state == .Starting {
            player.stop()
        } else if player.state == .Stopped || player.state == .Failed {
            player.start()
        } else if player.state == .Playing {
            player.pause()
        } else {
            player.play()
        }
    }
    
    func didPlayingSliderTouchEnd(sender: UISlider) {
        
        let endTime = Double(sender.value * Float(player.itemDurationSeconds))
        
        player.seek(endTime)
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

