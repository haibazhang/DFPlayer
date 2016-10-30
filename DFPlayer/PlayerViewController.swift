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
import ReactiveUI
import NVActivityIndicatorView

let movies: [(String, String)] = [
    ("http://www.html5videoplayer.net/videos/toystory.mp4", "Toy Story"),
    ("http://techslides.com/demos/sample-videos/small.mp4", "Short Test"),
    ("https://media.w3.org/2010/05/sintel/trailer.mp4", "Unknown"),
    ("http://demo.codesamplez.com/html5/video/sample.mp4", "Fail/Timeout Test")
]

class PlayerViewController: UIViewController {
    deinit {
        print("deinit: - \(self)")
    }
    
    var movieIndex = -1 {
        didSet {
            self.player.playerItem = AVPlayerItem(URL: NSURL(string: movies[self.movieIndex].0)!)
            self.ctrlPanel.titleLabel.text = movies[self.movieIndex].1
        }
    }
    
    lazy var player: DFPlayer = {
        let player = DFPlayer(delegate: self)
        player.controlable = self.ctrlPanel
        player.maskable = self.masker
        player.loadingView = NVActivityIndicatorView(frame: CGRectZero, type: .BallRotateChase, color: UIColor.whiteColor(), padding: 0)
        return player
    }()
    
    lazy var ctrlPanel: PlayerControlPanel = {
        let panel = PlayerControlPanel()
        panel.delegate = self
        return panel
    }()
    
    lazy var masker: DFPlayerMaskable = {
        let masker = PlayerMasker()
        masker.delegate = self
        return masker
    }()
    
    let backButton = UIButton()
    let nextMovie = UIButton()
    var autoPlay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        setupPlayerView()
        setupBackButton()
        setupNextMovieButton()
        
        movieIndex = 0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        RootCtrlSettings.shouldAutorotate = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        RootCtrlSettings.shouldAutorotate = false
    }
    
    func setupPlayerView() {
        let supView = view
        supView.addSubview(player.playerView)
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        player.playerView.snp_makeConstraints { (make) in
            make.top.left.right.equalTo(supView)
            make.height.equalTo(supView.snp_width).multipliedBy(screenWidth/screenHeight)
        }
    }
    
    func setupBackButton() {
        let supView = player.playerView
        supView.addSubview(backButton)
        backButton.snp_makeConstraints { (make) in
            make.centerY.equalTo(supView.snp_top).offset(64/2)
            make.centerX.equalTo(supView.snp_left).offset(16+6)
            make.width.height.equalTo(64)
        }
        backButton.setImage(UIImage(named: "back"), forState: .Normal)
        
        backButton.addAction({ [weak self](_) in
            guard let _self = self else { return }
            if UIDevice.df_isLandscape() {
                UIDevice.df_toPortrait()
            } else {
                _self.navigationController?.popViewControllerAnimated(true)
            }
            }, forControlEvents: .TouchUpInside)
    }
    
    func setupNextMovieButton() {
        
        view.addSubview(nextMovie)
        nextMovie.snp_makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(44)
        }
        nextMovie.setTitleColor(UIColor.blueColor(), forState: .Normal)
        nextMovie.setTitle("next movie", forState: .Normal)
        nextMovie.addAction({ [weak self](_) in
            guard let _self = self else { return }
            _self.autoPlay = true
            _self.movieIndex = (_self.movieIndex+1) % movies.count
            _self.ctrlPanel.clear()
            }, forControlEvents: .TouchUpInside)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        nextMovie.hidden = UIDevice.df_isLandscape()
    }
}

extension PlayerViewController: DFPlayerDelagate {
    func shouldAutoPlay() -> Bool {
        return autoPlay
    }
    
    func shouldLog() -> Bool {
        return true
    }

    func playerStateDidChange(state: DFPlayerState) {
        self.ctrlPanel.container.hidden = (state == .Finished)
    }
    
    func durationSeconds(second: NSTimeInterval) {
        self.ctrlPanel.movieDuration = second
    }
}

extension PlayerViewController: PlayerMasterDelegate {
    func didReplayButtonTap() {
        self.player.replay()
    }
}

extension PlayerViewController: PlayerControlPanelDelegate {
    func didPlayButtonTap() {
        if player.state == .Starting {
            player.stop()
        } else if player.state == .Stopped || player.state == .Failed || player.state == .Timeout {
            player.start()
        } else if player.state == .Playing {
            player.pause()
        } else {
            player.play()
        }
    }
    
    func didSliderTouchEnd(sender: UISlider) {
        let endTime = Int(Double(sender.value) * player.itemDurationSeconds)
        player.seek(endTime)
    }
}




