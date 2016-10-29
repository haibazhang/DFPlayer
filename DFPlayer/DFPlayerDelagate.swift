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
    func playerStateDidChange(state: DFPlayerState)
    func durationSeconds(second: NSTimeInterval)
    func loadedSecondsDidChange(seconds: NSTimeInterval)
    func currentSecondDidChange(seconds: NSTimeInterval)
    func startLoading()
    func stopLoading()
    func didFinished()
}

extension DFPlayerDelagate {
    func playerStateDidChange(state: DFPlayerState) {}
    func durationSeconds(seconds: NSTimeInterval) {}
    func loadedSecondsDidChange(seconds: NSTimeInterval) {}
    func currentSecondDidChange(second: NSTimeInterval) {}
    func startLoading() {}
    func stopLoading() {}
    func didFinished() {}
}



