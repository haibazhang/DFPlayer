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
    case Stopped = "Stopped"
    case Starting = "Starting"
    case Failed = "Failed"
    case ReadyToPlay = "ReadyToPlay"
    case Playing = "Playing"
    case Paused = "Paused"
}

private let status = "status"
private let stateQueue = dispatch_queue_create("stateQueue.com", nil)

class DFPlayer: NSObject {


    private(set) var playerItem: AVPlayerItem!
    internal let playerView = DFPlayerView()

    
    // configure
    
    internal var autoStart: Bool = true

    private let minimumBufferRemainToPlay: Double = 1

    private var _state: DFPlayerState = .Stopped
    private(set) var state: DFPlayerState {
        set {
            guard _state != newValue else { return }
            print("DFPlayer: state = \(newValue)")

            dispatch_sync(stateQueue) {
                self._state = newValue
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.delegate?.playerStateDidChange(newValue)
            })
            
            self.isLoading = detectIsLoading(newValue, isWaitingBuffer: self.isWaitingBuffer)
        }
        
        get {
            var state: DFPlayerState = .Stopped
            dispatch_sync(stateQueue) {
                state = self._state
            }
            return state
        }
    }
    
    var _isWaitingBuffer: Bool = false
    private(set) var isWaitingBuffer: Bool {
        set {
            guard _isWaitingBuffer != newValue else { return }

            print("DFPlayer: isWaitingBuffer = \(newValue)")

            _isWaitingBuffer = newValue
            
            dispatch_async(dispatch_get_main_queue()) {
                if newValue {
                    print("DFPlayer: waiting buffer...")
                    self.playerView.player?.pause()
                } else {
                    print("DFPlayer: buffered, begin play")
                    if self.state != .Paused {
                        self.play()
                    }
                }
                self.isLoading = self.detectIsLoading(self.state, isWaitingBuffer: newValue)
            }
        }
        
        get {
            return _isWaitingBuffer
        }
    }
    
    private var _isLoading = false
    private(set) var isLoading: Bool {
        set {
            guard _isLoading != newValue else { return }
            _isLoading = newValue
            print("DFPlayer: isLoading = \(newValue)")
            dispatch_async(dispatch_get_main_queue()) { 
                if self._isLoading {
                    self.delegate?.startLoading()
                } else {
                    self.delegate?.stopLoading()
                }
            }
        }
        get {
            return _isLoading
        }
    }
    
    private var _isFinished: Bool = false
    private(set) var isFinished: Bool {
        set {
            guard _isFinished != newValue else { return }
            _isFinished = newValue
            print("DFPlayer: isFinished = \(newValue)")
            dispatch_async(dispatch_get_main_queue()) { 
                if self._isFinished {
                    self.delegate?.didFinished()
                }
            }
        }
        get {
            return _isFinished
        }
    }
    
    private(set) var seeking = false
    private(set) var itemDurationSeconds: NSTimeInterval = 0
    private(set) var itemLoadedSeconds: NSTimeInterval = 0
    private(set) var itemCurrentSecond: NSTimeInterval = 0
    
    private weak var delegate: DFPlayerDelagate?
    private var timer: NSTimer?

    override init() {
        fatalError("use init(:AVPlayerItem)")
    }
    
    deinit {
        print("deinit: - \(self)")
        removeObserverForPlayItemStatus()
        removeTimer()
    }

    init(playerItem: AVPlayerItem, delegate: DFPlayerDelagate? = nil) {
        super.init()

        self.playerItem = playerItem
        playerView.player = AVPlayer(playerItem: playerItem)
        
        addObserverForPlayItemStatus()
        
        self.delegate = delegate
        
        if autoStart {
            start()
        } else {
            stop()
        }
    }
    
    internal func stop() {
        dispatch_async(dispatch_get_main_queue()) {
            self.playerView.player?.replaceCurrentItemWithPlayerItem(nil)
        }
        state = .Stopped
    }
    
    internal func start() {
        dispatch_async(dispatch_get_main_queue()) {
            if self.playerView.player?.currentItem == nil {
                self.playerView.player?.replaceCurrentItemWithPlayerItem(self.playerItem)
            }
        }
        state = .Starting
    }
    
    internal func play() {
        dispatch_async(dispatch_get_main_queue()) { 
            self.playerView.player?.play()
        }
        state = .Playing
    }
    
    internal func pause() {
        dispatch_async(dispatch_get_main_queue()) {
            self.playerView.player?.pause()
        }
        state = .Paused
    }
    
    private func setFailed() {
        state = .Failed
    }
    
    private func setReadyToPlay() {
        itemDurationSeconds = Double(playerItem.duration.value) / Double(playerItem.duration.timescale)
        dispatch_async(dispatch_get_main_queue(), {
            self.delegate?.durationSeconds(self.itemDurationSeconds)
        })
        state = .ReadyToPlay
        addTimer()
        play()
    }
    
    internal func seek(seekSecond: Double) {
        guard itemDurationSeconds > 0 && seekSecond < itemDurationSeconds else { return }
        print("DFPlayer: >>>>>>>>>seeking begin >>>>>>>>>")
        
        seeking = true
        let time = CMTime(value: Int64(seekSecond), timescale: 1)
        dispatch_async(dispatch_get_main_queue()) {
            self.playerView.player?.seekToTime(time, completionHandler: { [weak self](_) in
                guard let _self = self else { return }
                _self.seeking = false
                print("DFPlayer: >>>>>>>>>seeking end >>>>>>>>>")
            })
        }
    }
    
    private func addTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.3, action: { [weak self](_) in
            guard let _self = self else { return }
                _self.query()
            }, repeats: true)
    }
    
    private func query() {
        updateItemCurrentSecond()
        updateItemLoadedSeconds()
        isWaitingBuffer =
            detectIsWaitingBuffer(currentSecond: itemCurrentSecond, loadedSeconds: itemLoadedSeconds)
        isFinished = detectIsFinished(currentSecond: itemCurrentSecond)
    }
    
    private func removeTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func addObserverForPlayItemStatus() {
        playerItem.addObserver(self, forKeyPath: status, options: [.Initial, .New], context: nil)
    }
    
    private func removeObserverForPlayItemStatus() {
        playerItem.removeObserver(self, forKeyPath: status)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        let playerItem = object as! AVPlayerItem
        if keyPath == status {
            switch playerItem.status {
            case .Unknown:
                break
            case .Failed:
                setFailed()
                break
            case .ReadyToPlay:
                setReadyToPlay()
                break
            }
        }
    }
    
    // itemDurationSeconds > 0 | {currentSecond} => isFinished
    private func detectIsFinished(currentSecond currentSecond: Double) -> Bool {
        guard itemDurationSeconds > 0 else { return false }
        return fabs(itemDurationSeconds-currentSecond) < 1
    }
    
    // {state, isWaitingBuffer} => isLoading
    func detectIsLoading(state: DFPlayerState, isWaitingBuffer: Bool) -> Bool {
        if state == .Starting || (isWaitingBuffer && state == .Playing) {
            return true
        }
        return false
    }
    
    // {currentSecond, loadedSeconds} => isWaitingBuffer
    private func detectIsWaitingBuffer(currentSecond currentSecond: Double, loadedSeconds: Double) -> Bool {
        
        // fix bug
        if seeking {
            return true
        } else {
            // should not return false
        }
        
        guard itemLoadedSeconds > 0 else { return true }
        
        let bufferRemain = itemLoadedSeconds - itemCurrentSecond
        
        print("DFPlayer: bufferRemain - \(bufferRemain)")
        return bufferRemain <= self.minimumBufferRemainToPlay ? true : false
    }
    
    private func updateItemCurrentSecond() {
        let itemCurrentSecond = Double(playerItem.currentTime().value) / Double(playerItem.currentTime().timescale)
        if self.itemCurrentSecond != itemCurrentSecond {
            self.itemCurrentSecond = itemCurrentSecond
            dispatch_async(dispatch_get_main_queue(), {
                self.delegate?.currentSecondDidChange(self.itemCurrentSecond)
            })
        }
    }
    
    private func updateItemLoadedSeconds() {
        let loadedTimeRanges = playerView.player?.currentItem?.loadedTimeRanges
        guard let timeRange = loadedTimeRanges?.first?.CMTimeRangeValue else { return }
        
        let startSeconds = Double(CMTimeGetSeconds(timeRange.start))
        let durationSeconds = Double(CMTimeGetSeconds(timeRange.duration))
        let loadedSecond = startSeconds + durationSeconds
        
        // loadedSecond may lager than itemDurationSeconds a litter bit
        let itemLoadedSeconds = fmin(loadedSecond, itemDurationSeconds)
        
        if self.itemLoadedSeconds != itemLoadedSeconds {
            self.itemLoadedSeconds = itemLoadedSeconds
            dispatch_async(dispatch_get_main_queue(), {
                self.delegate?.loadedSecondsDidChange(self.itemLoadedSeconds)
            })
        }
    }
    

}



