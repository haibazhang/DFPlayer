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
    
    var controlPanel: DFPlayerControlPanelProtocol?
    
    var isSilderTouching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        setupPlayerView()
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
    
    func setupControlPanel() {
        let cp = PlayerControlPanel()
        player.playerView.addSubview(cp.container)
        cp.container.snp_makeConstraints { (make) in
            make.edges.equalTo(player.playerView)
        }
        
        cp.playingSlider.addAction({ [weak self](sender) in
            guard let _self = self else { return }
            _self.isSilderTouching = true
        }, forControlEvents: .TouchDown)

        cp.playingSlider.addAction({ [weak self](sender) in
            guard let _self = self else { return }
            guard let slider = sender as? UISlider else { return }
            let endTime = Double(slider.value) * _self.player.itemDurationSeconds
            _self.player.seek(endTime)
            _self.isSilderTouching = false
            }, forControlEvents: .TouchUpInside)
        
        cp.backButton.addAction({ [weak self](_) in
            guard let _self = self else { return }
            _self.navigationController?.popViewControllerAnimated(true)
            }, forControlEvents: .TouchUpInside)
        
        cp.playButton.addAction({ [weak player](_) in
            guard let _player = player else { return }
            if _player.state == .Starting {
                _player.stop()
            } else if _player.state == .Stopped || _player.state == .Failed {
                _player.start()
            } else if _player.state == .Playing {
                _player.pause()
            } else {
                _player.play()
            }
            }, forControlEvents: .TouchUpInside)
        self.controlPanel = cp
    }
}

extension PlayerViewController: DFPlayerDelagate {
    func durationSeconds(seconds: NSTimeInterval) {
        print("duration: - \(seconds) seconds")
        controlPanel?.durationSecondsLabel.text = Int(seconds).df_toHourFormat()
    }
    
    func currentSecondDidChange(second: NSTimeInterval) {
        print("current: - \(second) second")
        controlPanel?.currentSecondLabel.text = Int(second).df_toHourFormat()
        if !isSilderTouching && !player.seeking {
            controlPanel?.playingSlider.value = Float(second/player.itemDurationSeconds)
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
        controlPanel?.loadedProgress.setProgress(progress, animated: true)
    }
    
    func playerStateDidChange(state: DFPlayerState) {
        controlPanel?.playButton.selected = (state == .Playing || state == .Starting)
    }
    
    func startLoading() {
        controlPanel?.loadingView.hidden = false
        controlPanel?.loadingView.startAnimation()
    }
    
    func stopLoading() {
        controlPanel?.loadingView.hidden = true
        controlPanel?.loadingView.stopAnimation()
    }
}
