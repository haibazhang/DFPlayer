//
//  PlayerMaskView.swift
//  DFPlayer
//
//  Created by Difff on 16/10/25.
//  Copyright © 2016年 Difff. All rights reserved.
//

import UIKit

class PlayerMasker: NSObject {
    let container = UIView()
    
    lazy var stoppedStateView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.blueColor()
        return view
    }()
    
    var finishedStateView = UIView()
    var errorStateView  = UIView()
    var timeoutStateView = UIView()
    
    lazy var pausedStateView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0.3, blue: 0, alpha: 0.5)
        return view
    }()
    
    lazy var playingStateView: UIView = {
        let view = UIView()
//        let label = UILabel()
//        view.addSubview(label)
//        label.textColor = UIColor.whiteColor()
//        label.font = UIFont.systemFontOfSize(13)
//        label.text = "wow~ supporting bullet screen!!!"
//        view.addSubview(label)
//        label.snp_makeConstraints(closure: { (make) in
//            make.centerY.equalTo(view)
//            make.left.equalTo(view.snp_right)
//            
//        })
//        NSTimer.scheduledTimerWithTimeInterval(3, action: { (_) in
//            UIView.animateWithDuration(2) {
//                label.snp_updateConstraints(closure: { (make) in
//                    make.right.equalTo(view.snp_left)
//                })
//                view.layoutIfNeeded()
//            }
//            }, repeats: true)
//        
        
        view.backgroundColor = UIColor(red: 0.3, green: 0, blue: 0, alpha: 0.5)
        return view
    }()
    
    
    weak var delegate: PlayerMasterDelegate?
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PlayerMasker: DFPlayerMaskable {
}
