//
//  DFPlayer.swift
//  DFPlayer
//
//  Created by Difff on 16/10/14.
//  Copyright © 2016年 Difff. All rights reserved.
//

import UIKit
import AVFoundation
import NVActivityIndicatorView

enum DFPlayerState: String {
    case Init
    case Stopped
    case Starting
    case Failed
    case Playing
    case Paused
    case Timeout
    case Finished
}

private let status = "status"
private let stateQueue = dispatch_queue_create("com.difff.stateQueue", nil)

class DFPlayer: NSObject {

    private(set) var playerView = DFPlayerView()
    
    private let loopDuration: NSTimeInterval = 0.25
    private let minimumBufferRemainToPlay: NSTimeInterval = 1
    
    private var _state: DFPlayerState = .Init
    private(set) var state: DFPlayerState {
        set {
            guard _state != newValue else { return }
            df_print("DFPlayer: #state# = \(newValue)")

            dispatch_sync(stateQueue) {
                self._state = newValue
            }
            self.maskable?.installMaskView(state: self.state)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.controlable?.playButton.userInteractionEnabled
                    = self.state != .Finished
                self.controlable?.playingSlider.userInteractionEnabled
                    = (self.state == .Playing || self.state == .Paused)
                self.controlable?.playButton.selected
                    = (self.state == .Playing || self.state == .Starting)
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
    
    private(set) var isWaitingBuffer: Bool = false {
        willSet {
            guard isWaitingBuffer != newValue else { return }
            df_print("DFPlayer: isWaitingBuffer = \(newValue)")
            dispatch_async(dispatch_get_main_queue()) {
                if newValue {
                    self.df_print("DFPlayer: >>>>>> waiting buffer...")
                    self.playerView.player?.pause()
                } else {
                    self.df_print("DFPlayer: <<<<<< buffered, likely to play")
                    if self.state != .Paused && self.state != .Finished {
                        self.play()
                    }
                }
                self.isLoading = self.detectIsLoading(self.state, isWaitingBuffer: newValue)
            }
        }
    }
    
    private var timeOutTimer: NSTimer?
    
    private(set) var isLoading: Bool = false {
        willSet {
            guard isLoading != newValue else { return }
            df_print("DFPlayer: isLoading = \(newValue)")
            dispatch_async(dispatch_get_main_queue()) {
                if newValue {
                    self.timeOutTimer = NSTimer.scheduledTimerWithTimeInterval(self.delegate.timeoutInterval(), action: { [weak self](_) in
                        guard let _self = self else { return }
                        if _self.isLoading {
                            _self.setTimeout()
                        }
                        }, repeats: false)
                    self.playerView.loadingView?.startAnimation()
                    self.delegate?.startLoading()
                } else {
                    self.timeOutTimer?.invalidate()
                    self.playerView.loadingView?.stopAnimation()
                    self.delegate?.stopLoading()
                }
            }
        }
    }
    
    private(set) var isFinished: Bool = false {
        willSet {
            guard isFinished != newValue else { return }
            df_print("DFPlayer: isFinished = \(newValue)")
            self.isWaitingBuffer = false

            if newValue {
                self.pause()
                self.setFinished()
                self.delegate?.didFinished()
            }
        }
    }
    
    private(set) var itemDurationSeconds: NSTimeInterval = 0 {
        willSet {
            guard itemCurrentSecond != newValue else { return }
            dispatch_async(dispatch_get_main_queue(), {
                let duration = self.itemDurationSeconds
                self.df_print("DFPlayer: duration = \(duration) seconds")
                self.controlable?.durationSecondsLabel.text = Int(duration).df_toHourFormat()
                self.delegate?.durationSeconds(duration)
            })
        }
    }
    
    private(set) var itemLoadedSeconds: NSTimeInterval = 0 {
        willSet {
            guard itemLoadedSeconds != newValue else { return }
            dispatch_async(dispatch_get_main_queue(), {
                let loaded = self.itemLoadedSeconds
                self.df_print("DFPlayer: loaded = \(loaded) seconds")
                let duration = self.itemDurationSeconds
                guard loaded >= 0 && duration > 0 else { return }
                let progress = Float(loaded)/Float(duration)
                self.controlable?.loadedProgress.setProgress(progress, animated: true)
                self.delegate?.loadedSecondsDidChange(loaded)
            })
        }
    }
    
    private(set) var itemCurrentSecond: NSTimeInterval = 0 {
        willSet {
            guard itemCurrentSecond != newValue else { return }
            dispatch_async(dispatch_get_main_queue(), {
                let current = self.itemCurrentSecond
                self.df_print("DFPlayer: current = \(current) second")
                if let ctrlPanel = self.controlable {
                    ctrlPanel.currentSecondLabel.text = Int(current).df_toHourFormat()
                    if !ctrlPanel.isSliderTouching && !self.seeking {
                        ctrlPanel.playingSlider.value = Float(current/self.itemDurationSeconds)
                    }
                }
                self.delegate?.currentSecondDidChange(self.itemCurrentSecond)
            })
        }
    }
    private(set) var itemBufferRemainSeconds: NSTimeInterval = 0 {
        willSet {
            guard itemBufferRemainSeconds != newValue else { return }
            df_print("DFPlayer: bufferRemain = \(self.itemBufferRemainSeconds) seconds")
        }
    }

    private(set) var seeking = false
    
    private weak var delegate: DFPlayerDelagate!
    
    internal weak var controlable: DFPlayerControlable? {
        willSet {
            controlable?.container.removeFromSuperview()
        }
        didSet {
            guard let container = controlable?.container else { return }
            playerView.df_addSubViewEquirotal(container)
            playerView.bringSubviewToFront(container)
        }
    }
    internal weak var maskable: DFPlayerMaskable? {
        willSet {
            maskable?.container.removeFromSuperview()
        }
        didSet {
            guard let container = maskable?.container else { return }
            playerView.df_addSubViewEquirotal(container)
            playerView.sendSubviewToBack(container)
            playerView.sendSubviewToBack(playerView.playerLayerView)
            /* view Cascading Relation:
             --------controlable?.container---------
             ---------maskable?.contrainer----------
             -------playView.playerLayerView--------
             */
        }
    }
    
    internal var loadingView: NVActivityIndicatorView?
    
    internal var playerItem: AVPlayerItem? = nil {
        willSet {
            removeObserverForPlayItemStatus()
        }
        
        didSet {
            addObserverForPlayItemStatus()
            
            guard let playerItem = self.playerItem else { return }
            playerView.player = AVPlayer(playerItem: playerItem)
            playerView.loadingView = loadingView
            if delegate.shouldAutoPlay() {
                start()
            } else {
                stop()
            }
        }
    }

    
    private var timer: NSTimer?

    override init() {
        fatalError("use init(:AVPlayerItem)")
    }
    
    deinit {
        print("deinit: - \(self)")
        removeObserverForPlayItemStatus()
        removeTimer()
    }

    init(delegate: DFPlayerDelagate) {
        super.init()
        self.delegate = delegate
    }
    
    internal func stop() {
        dispatch_async(dispatch_get_main_queue()) {
            self.playerView.player?.replaceCurrentItemWithPlayerItem(nil)
        }
        state = .Stopped
    }
    
    
    internal func start() {
        isFinished = false
        if self.playerItem == nil {
            setFailed()
            return
        }
        dispatch_async(dispatch_get_main_queue()) {
            if self.playerView.player?.currentItem == nil {
                self.playerView.player?.replaceCurrentItemWithPlayerItem(self.playerItem)
            }
        }
        state = .Starting
    }
    
    internal func play() {
        isFinished = false
        if self.playerItem == nil {
            setFailed()
            return
        }
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
    
    internal func seek(seekSecond: Int) {
        guard itemDurationSeconds > 0 && seekSecond <= Int(itemDurationSeconds) else { return }
        df_print("DFPlayer: >>>>>> seeking begin - \(seekSecond) second")
        seeking = true
        let time = CMTime(value: Int64(seekSecond), timescale: 1)
//        dispatch_async(dispatch_get_main_queue()) {
//        }
        
        
//        self.playerView.player?.seekToTime(time, completionHandler: { [weak self](_) in
//            guard let _self = self else { return }
//            _self.seeking = false
//            _self.df_print("DFPlayer: <<<<<< seeking end")
//            })

        self.playerView.player?.seekToTime(time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimePositiveInfinity, completionHandler: { [weak self](_) in
            guard let _self = self else { return }
            _self.seeking = false
            _self.df_print("DFPlayer: <<<<<< seeking end")
        })

    }
    internal func replay() {
        isFinished = false
        seek(0)
        play()
    }
    
    private func setFailed() {
        state = .Failed
    }
    
    private func setFinished() {
        state = .Finished
    }
    
    private func setTimeout() {
        dispatch_async(dispatch_get_main_queue()) {
            self.playerView.player?.replaceCurrentItemWithPlayerItem(nil)
        }
        state = .Timeout
    }
    
    
    private func addTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(loopDuration, action: { [weak self](_) in
            guard let _self = self else { return }
                _self.track()
            }, repeats: true)
    }
    
    private func removeTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func addObserverForPlayItemStatus() {
        playerItem?.addObserver(self, forKeyPath: status, options: [.Initial, .New], context: nil)
    }
    
    private func removeObserverForPlayItemStatus() {
        playerItem?.removeObserver(self, forKeyPath: status)
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
                countItemDurationSeconds()
                addTimer()
                play()
                break
            }
        }
    }
    
    private func track() {
        guard state != .Finished else { return }
        countItemCurrentSecond()
        countItemLoadedSeconds()
        isWaitingBuffer =
            detectIsWaitingBuffer(currentSecond: itemCurrentSecond, loadedSeconds: itemLoadedSeconds)
        isFinished = detectIsFinished(currentSecond: itemCurrentSecond)
    }
    
    // {currentSecond} => isFinished
    private func detectIsFinished(currentSecond currentSecond: Double) -> Bool {
        guard itemDurationSeconds > 0 else { return false }
        return fabs(itemDurationSeconds-currentSecond) <= 1
    }
    
    // {state, isWaitingBuffer} => isLoading
    private func detectIsLoading(state: DFPlayerState, isWaitingBuffer: Bool) -> Bool {
        if state == .Starting || (isWaitingBuffer && state == .Playing) {
            return true
        }
        return false
    }
    
    // {currentSecond, loadedSeconds} => isWaitingBuffer
    private func detectIsWaitingBuffer(currentSecond currentSecond: Double, loadedSeconds: Double) -> Bool {
        // for network throttling case
        if seeking {
            return true // else should not return false
        }
        guard itemLoadedSeconds > 0 else { return true }
        itemBufferRemainSeconds = itemLoadedSeconds - itemCurrentSecond
        return itemBufferRemainSeconds <= self.minimumBufferRemainToPlay ? true : false
    }
    
    private func countItemDurationSeconds() {
        guard let playerItem = self.playerItem else { return }
        itemDurationSeconds = Double(playerItem.duration.value) / Double(playerItem.duration.timescale)
    }
    
    private func countItemCurrentSecond() {
        guard let playerItem = self.playerItem else { return }
        let rawValue = Double(playerItem.currentTime().value) / Double(playerItem.currentTime().timescale)
        itemCurrentSecond = Double(round(1000*rawValue)/1000)
    }
    
    private func countItemLoadedSeconds() {
        let loadedTimeRanges = playerView.player?.currentItem?.loadedTimeRanges
        guard let timeRange = loadedTimeRanges?.first?.CMTimeRangeValue else { return }
        
        let startSecond = Double(CMTimeGetSeconds(timeRange.start))
        let durationSeconds = Double(CMTimeGetSeconds(timeRange.duration))
        let loadedSeconds = startSecond + durationSeconds
        
        // loadedSeconds may a little bit bigger than itemDurationSeconds
        itemLoadedSeconds = fmin(loadedSeconds, itemDurationSeconds)
    }
}

extension DFPlayer {
    func df_print(str: String) {
        if delegate.shouldLog() {
            print(str)
        }
    }
}



