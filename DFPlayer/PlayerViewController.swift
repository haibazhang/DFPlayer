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
        
        setupPlayerStateUI()
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

extension PlayerViewController: DFPlayerStateEyeable {
    var container: UIView {
        get {
            return self.player.playerView
        }
    }
}

extension PlayerViewController: DFPlayerDelagate {
    func playerStatusDidChange(status: DFPlayerState) {
        print("status: - \(status.rawValue)")
    }
    
    func durationSeconds(seconds: Int) {
        print("duration: - \(seconds) seconds")
        
        setDurationSeconds(seconds)
    }
    
    func loadedSecondsDidChange(seconds: Int) {
        print("loaded: - \(seconds) seconds")
        
        setLoadedSeconds(seconds, duration: player.itemDurationSeconds())
    }
    
    func currentSecondDidChange(second: Int) {
        print("current: - \(second) second")
        
        setCurrentSecond(second, duration: player.itemDurationSeconds())
    }
    
    func didTapBackButton() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func titleForVideo() -> String {
        return "video title"
    }
}


