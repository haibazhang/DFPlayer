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
    case Stop = "Stop"
    case Start = "Start"
    case ReadyToPlay = "ReadyToPlay"
    case Failed = "Failed"
    case Playing = "Playing"
    case PauseByBuffer = "PauseByBuffer"
    case PauseByUser = "PauseByUser"
}

private let status = "status"
private let loadedTimeRanges = "loadedTimeRanges"

class DFPlayer: NSObject {
    
    internal var playerItem: AVPlayerItem!
    internal let playerView = DFPlayerView()
    
    // configure
    internal var minimumBufferDurationToPlay: Int = 1
    internal var autoStart: Bool = true

    
    private var _state: DFPlayerState = .Stop
    private(set) var state: DFPlayerState {
        set {
            guard _state != newValue else { return }
            
            print("DFPlayer: status = \(newValue)")

            let oldValue = _state
            
            _state = newValue
            
            delegate?.playerStatusDidChange(newValue)
            
            
            dispatch_async(dispatch_get_main_queue(), {
                // for buffering
                if newValue == .Start {
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue(), {
                        if self.state == .Start {
                            self.delegate?.startBuffering()
                        }
                    })
                } else if newValue == .PauseByBuffer {
                    self.delegate?.startBuffering()
                } else {
                    self.delegate?.stopBuffering()
                }
                
                
                if oldValue == .Start && newValue == .PauseByUser {
                    self.delegate?.stopBuffering()
                }
                
                // for play|pause
                if newValue == .Playing || newValue == .Start {
                    self.delegate?.didPlay()
                } else {
                    self.delegate?.didPause()
                }
                
            })
        }
        
        
        get {
            return _state
        }
    }
    
    private(set) var durationSeconds: Int = 0
    private(set) var loadedSeconds: Int = 0
    private(set) var currentSecond: Int = 0
    
    
    private weak var delegate: DFPlayerDelagate?
    
    private var timeObserverToken: AnyObject?
    
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
        
        if autoStart {
            start()
        } else {
            stop()
        }
    }
    
    internal func play() {
        playerView.player?.play()
        state = .Playing
    }
    
    internal func pause() {
        playerView.player?.pause()
        state = .PauseByUser
    }
    
    internal func stop() {
        playerView.player?.replaceCurrentItemWithPlayerItem(nil)
        state = .Stop
    }
    
    internal func start() {
        if playerView.player?.currentItem == nil {
            playerView.player?.replaceCurrentItemWithPlayerItem(playerItem)
        }
        state = .Start
    }
    
    private func addObserverForPlayItem() {
        playerItem.addObserver(self, forKeyPath: status, options: [.Initial, .New], context: nil)
    }
    
    private func removeObserverForPlayItem() {
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
                state = .ReadyToPlay


                durationSeconds = Int(playerItem.duration.value) / Int(playerItem.duration.timescale)

                delegate?.durationSeconds(durationSeconds)
                
                play()
                
                playerItem.addObserver(self, forKeyPath: loadedTimeRanges, options: [.Initial, .New], context: nil)
                addPeriodicTimeObserver(playerItem)
                
                break
            case .Failed:
                state = .Failed
                break
            }
            
        } else if keyPath == loadedTimeRanges {
            
            loadedSeconds = countLoadedSecond()
            
            delegate?.loadedSecondsDidChange(loadedSeconds)
            
            if currentSecond != 0 && currentSecond >= loadedSeconds {
                state = .PauseByBuffer
            } else if loadedSeconds - currentSecond >= minimumBufferDurationToPlay {
                if state == .PauseByBuffer {
                    play()
                }
            }
        }
    }
    
    private func addPeriodicTimeObserver(playerItem: AVPlayerItem) {
        timeObserverToken = self.playerView.player?.addPeriodicTimeObserverForInterval(CMTime(value: 1, timescale: 1), queue: nil, usingBlock: { [weak self](time) in
            
            guard let _self = self else { return }
            
            _self.currentSecond = Int(playerItem.currentTime().value) / Int(playerItem.currentTime().timescale)
            _self.delegate?.currentSecondDidChange(_self.currentSecond)
            
            if _self.state == .PauseByUser {
                return
            }
            _self.state = .Playing
        })
    }
    
    private func removePeriodicTimeObserver() {
        // If a time observer exists, remove it
        guard let token = timeObserverToken else { return }
        self.playerView.player?.removeTimeObserver(token)
        timeObserverToken = nil
    }
    
    private func countLoadedSecond() -> Int {
        let loadedTimeRanges = playerView.player?.currentItem?.loadedTimeRanges
        guard let timeRange = loadedTimeRanges?.first?.CMTimeRangeValue else { return 0 }

        let startSeconds = Int(CMTimeGetSeconds(timeRange.start))
        let durationSeconds = Int(CMTimeGetSeconds(timeRange.duration))
        
        return startSeconds + durationSeconds
    }
}



