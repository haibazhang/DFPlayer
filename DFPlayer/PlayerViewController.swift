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
        let loadingView = NVActivityIndicatorView(frame: CGRectZero, type: .BallRotateChase, color: UIColor.whiteColor(), padding: 0)
        let player = DFPlayer(playerItem: self.playerItem, delegate: self, loadingView: loadingView)
        player.controlable = self.ctrlPanel
//        player.maskable = self.masker

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
    
    var isSilderTouching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        setupPlayerView()
        setupBackButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        GlobalSettings.shouldAutorotate = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        GlobalSettings.shouldAutorotate = false
    }
    
    func setupPlayerView() {
        let supView = view
        supView.addSubview(player.playerView)
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
}

extension PlayerViewController: DFPlayerDelagate {}

extension PlayerViewController: PlayerControlPanelDelegate {
    func didPlayButtonTap() {
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
    
    func didSliderTouchEnd(sender: UISlider) {
        let endTime = Double(sender.value) * player.itemDurationSeconds
        player.seek(endTime)
    }
}

extension PlayerViewController: PlayerMasterDelegate {
    
}
