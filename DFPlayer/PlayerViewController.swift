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
        
        setupPlayerControlPanel()
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
    func durationSeconds(seconds: Int) {
        print("duration: - \(seconds) seconds")
        
        durationSecondsLabel.text = seconds.toHourFormat()
    }
    
    func currentSecondDidChange(second: Int) {
        print("current: - \(second) second")
        
        currentSecondLabel.text = second.toHourFormat()
        playingSlider.value = Float(second)/Float(player.durationSeconds)
    }
    
    func loadedSecondsDidChange(seconds: Int) {
        print("loaded: - \(seconds) seconds")

        
        if seconds > player.durationSeconds {
            fatalError("loaded > duration!!!")
        }
        
        let duration = player.durationSeconds
        guard seconds > 0 && seconds <= duration else { return }
        let progress = Float(seconds)/Float(duration)
        loadedProgress.setProgress(progress, animated: false)
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
    
    func didPlay() {
        playButton.selected = true
    }
    func didPause() {
        playButton.selected = false
    }
    func didStart() {
        playButton.selected = true
    }
    func didStop() {
        playButton.selected = false
    }
    
    func didTapPlayButton() {
        if player.state == .Start {
            player.stop()
        } else if player.state == .Stop {
            player.start()
        } else if player.state == .Playing {
            player.pause()
        } else {
            player.play()
        }
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

