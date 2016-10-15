//
//  DFPlayer.swift
//  DFPlayer
//
//  Created by Difff on 16/10/14.
//  Copyright © 2016年 Difff. All rights reserved.
//

import UIKit
import AVFoundation

enum DFPlayerState: String {
    case Init = "Init"
    case ReadyToPlay = "ReadyToPlay"
    case Failed = "Failed"
    case Playing = "Playing"
    case PauseByBuffer = "PauseByBuffer"
}

private let status = "status"
private let loadedTimeRanges = "loadedTimeRanges"

class DFPlayer: NSObject {
    
    internal var playerItem: AVPlayerItem!
    internal let playerView = DFPlayerView()
    
    // configure
    var minimumBufferDurationToPlay: Int = 1
    var autoPlay: Bool = true
    
    private weak var delegate: DFPlayerDelagate?
    private var durationSeconds: Int = 0
    private var loadedSeconds: Int = 0
    private var currentSecond: Int = 0
    
    var timeObserverToken: AnyObject?
    
    override init() {
        fatalError("use init(:AVPlayerItem)")
    }
    
    deinit {
        print("deinit: - \(self)")

        removeObserverForPlayItem()

        // Releasing the observer object without a call to -removeTimeObserver: will result in undefined behavior.
        removePeriodicTimeObserver()
    }


    init(playerItem: AVPlayerItem, delegate: DFPlayerDelagate? = nil) {
        super.init()

        self.playerItem = playerItem
        playerView.player = AVPlayer(playerItem: playerItem)
        
        addObserverForPlayItem()
        
        self.delegate = delegate
        delegate?.playerStatusDidChange(.Init)
    }
    
    func itemDurationSeconds() -> Int {
        return durationSeconds
    }
    
    func addObserverForPlayItem() {
        playerItem.addObserver(self, forKeyPath: status, options: [.Initial, .New], context: nil)
        playerItem.addObserver(self, forKeyPath: loadedTimeRanges, options: [.Initial, .New], context: nil)
    }
    
    func removeObserverForPlayItem() {
        playerItem.removeObserver(self, forKeyPath: status)
        playerItem.removeObserver(self, forKeyPath: loadedTimeRanges)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        let playerItem = object as! AVPlayerItem
        
        if keyPath == status {
            switch playerItem.status {
            case .Unknown:
                break
            case .ReadyToPlay:
                delegate?.playerStatusDidChange(.ReadyToPlay)

                durationSeconds = Int(playerItem.duration.value) / Int(playerItem.duration.timescale)

                delegate?.durationSeconds(durationSeconds)
                
                if (autoPlay) {
                    playerView.player?.play()
                }
                
                addPeriodicTimeObserver(playerItem)
                
                break
            case .Failed:
                delegate?.playerStatusDidChange(.Failed)
                break
            }
            
        } else if keyPath == loadedTimeRanges {
            
            loadedSeconds = self.countLoadedSecond()
            
            delegate?.loadedSecondsDidChange(loadedSeconds)
            
            if currentSecond >= loadedSeconds {
                delegate?.playerStatusDidChange(.PauseByBuffer)
            } else if loadedSeconds - currentSecond >= minimumBufferDurationToPlay {
                // auto play
                playerView.player?.play()
            }
        }
    }
    
    func addPeriodicTimeObserver(playerItem: AVPlayerItem) {
        timeObserverToken = self.playerView.player?.addPeriodicTimeObserverForInterval(CMTime(value: 1, timescale: 1), queue: nil, usingBlock: { [weak self](time) in
            
            guard let _self = self else { return }
            
            _self.currentSecond = Int(playerItem.currentTime().value) / Int(playerItem.currentTime().timescale)
            _self.delegate?.currentSecondDidChange(_self.currentSecond)
            
            _self.delegate?.playerStatusDidChange(.Playing)
        })
    }
    
    func removePeriodicTimeObserver() {
        // If a time observer exists, remove it
        guard let token = timeObserverToken else { return }
        self.playerView.player?.removeTimeObserver(token)
        timeObserverToken = nil
    }
    
    func countLoadedSecond() -> Int {
        let loadedTimeRanges = playerView.player?.currentItem?.loadedTimeRanges
        guard let timeRange = loadedTimeRanges?.first?.CMTimeRangeValue else { return 0 }

        let startSeconds = Int(CMTimeGetSeconds(timeRange.start))
        let durationSeconds = Int(CMTimeGetSeconds(timeRange.duration))
        
        return startSeconds + durationSeconds
    }
}



