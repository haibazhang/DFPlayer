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
    var stoppedStateView: UIView { get }
    var finishedStateView: UIView { get }
    var errorStateView: UIView { get }
    var timeoutStateView: UIView { get }
    var playingStateView: UIView { get }
    var pausedStateView: UIView { get }
    
    func setup()
    
    func installMaskView(state state: DFPlayerState)
}

extension DFPlayerMaskable {
    
    func setup() {}
    
    func installMaskView(state state: DFPlayerState) {
        func removeAllMaskView() {
            [stoppedStateView, finishedStateView, errorStateView, timeoutStateView, playingStateView].forEach { $0.removeFromSuperview() }
        }

        removeAllMaskView()
        switch state {
        case .Stopped:
            container.df_addMaskView(stoppedStateView)
            break
        case .Failed:
            container.df_addMaskView(errorStateView)
            break
        case .Playing:
            container.df_addMaskView(playingStateView)
            break
        case .Paused:
            container.df_addMaskView(pausedStateView)
            break
        case .Starting:
            break
        case .Init:
            break
        }
    }
}



