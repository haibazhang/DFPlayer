//
//  DFPlayerDelagate.swift
//  DFPlayer
//
//  Created by Difff on 16/10/17.
//  Copyright © 2016年 Difff. All rights reserved.
//

import UIKit

protocol DFPlayerDelagate: class {
    // @optional
    func shouldAutoPlay() -> Bool
    func shouldLog() -> Bool
    func timeoutInterval() -> NSTimeInterval
    func playerStateDidChange(state: DFPlayerState)
    func durationSeconds(second: NSTimeInterval)
    func loadedSecondsDidChange(seconds: NSTimeInterval)
    func currentSecondDidChange(seconds: NSTimeInterval)
    func startLoading()
    func stopLoading()
}

extension DFPlayerDelagate {
    func shouldAutoPlay() -> Bool {
        return false
    }
    func shouldLog() -> Bool {
        return true
    }
    func timeoutInterval() -> NSTimeInterval {
        return 15
    }
    func playerStateDidChange(state: DFPlayerState) {}
    func durationSeconds(seconds: NSTimeInterval) {}
    func loadedSecondsDidChange(seconds: NSTimeInterval) {}
    func currentSecondDidChange(second: NSTimeInterval) {}
    func startLoading() {}
    func stopLoading() {}
}



