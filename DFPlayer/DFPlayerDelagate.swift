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
    func playerStatusDidChange(status: DFPlayerState)
    func durationSeconds(second: Int)
    func loadedSecondsDidChange(seconds: Int)
    func currentSecondDidChange(seconds: Int)
    func startLoading()
    func stopLoading()
    func didPlay()
    func didPause()
    func didStart()
    func didStop()
}

// DFPlayerDelagate: Default Implementaion
extension DFPlayerDelagate {
    func playerStatusDidChange(status: DFPlayerState) {}
    func durationSeconds(seconds: Int) {}
    func loadedSecondsDidChange(seconds: Int) {}
    func currentSecondDidChange(second: Int) {}
    func startLoading() {}
    func stopLoading() {}
    func didPlay() {}
    func didPause() {}
    func didStart() {}
    func didStop() {}
}



