//
//  DFPlayerMaskable.swift
//  DFPlayer
//
//  Created by Difff on 16/10/25.
//  Copyright © 2016年 Difff. All rights reserved.
//

import UIKit

enum DFPlayerMaskViewType: String {
    case Stopped = "Stopped"
    case Finished = "Finished"
    case Error = "Failed"
    case Timeout = "Timeout"
    case Normal = "Normal"
}

protocol DFPlayerMaskable: class {
//    var playerView: DFPlayerView { get }
    var container: UIView { get }
    var stoppedMaskView: UIView { get }
    var startingMaskView: UIView { get }
    var failedMaskView: UIView { get }
    var playingMaskView: UIView { get }
    var pausedMaskView: UIView { get }
    var timeoutMaskView: UIView { get }
    var finishedMaskView: UIView { get }
    
    func installMaskView(state state: DFPlayerState)
}

extension DFPlayerMaskable {
    
    func installMaskView(state state: DFPlayerState) {
        let map: [DFPlayerState: UIView] =
                    [.Stopped: stoppedMaskView,
                     .Starting: startingMaskView,
                     .Failed: failedMaskView,
                     .Playing: playingMaskView,
                     .Paused: pausedMaskView,
                     .Timeout: timeoutMaskView,
                     .Finished: finishedMaskView,
                     ]
        container.subviews.forEach { $0.removeFromSuperview() }
        container.df_addSubViewEquirotal(map[state] ?? UIView())
    }
}



