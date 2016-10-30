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
    
    lazy var stoppedMaskView: UIView = {
        // ex. player init background
        let view = UIImageView(image: UIImage(named: "background"))
        view.contentMode = .ScaleAspectFit
        return view
    }()
    
    lazy var startingMaskView: UIView = {
       // ex. support AD
       return UIView()
    }()
    
    lazy var failedMaskView: UIView = {
        // ex. support retry
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.8, green: 0, blue: 0, alpha: 0.5)
        
        let label = UILabel()
        label.textColor = UIColor.yellowColor()
        label.text = "failed. (ex. support retry)"
        label.textAlignment = .Center
        view.df_addSubViewEquirotal(label)
        
        return view
    }()
    
    lazy var playingMaskView: UIView = {
        // ex. support bullet screen
        return UIView()
    }()
    
    lazy var pausedMaskView: UIView = {
        // ex. support AD
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0.3, blue: 0, alpha: 0.5)
        
        let label = UILabel()
        label.textColor = UIColor.yellowColor()
        label.text = "pause. (ex. support AD)"
        label.textAlignment = .Center
        view.df_addSubViewEquirotal(label)
        
        return view
    }()
    
    lazy var timeoutMaskView: UIView = {
        // ex. support retry
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.5, green: 0, blue: 0, alpha: 0.5)
        
        let label = UILabel()
        label.textColor = UIColor.yellowColor()
        label.text = "timeout. (ex. support retry)"
        label.textAlignment = .Center
        view.df_addSubViewEquirotal(label)

        return view
    }()

    lazy var finishedMaskView: UIView = {
        // ex. support replay
        let view = UIView()
        view.backgroundColor = UIColor.blackColor()
        let button = UIButton()
        button.setImage(UIImage(named: "to_replay"), forState: .Normal)
        button.addAction({ (_) in
            self.delegate?.didReplayButtonTap()
            }, forControlEvents: .TouchUpInside)
        view.df_addSubViewEquirotal(button)
        
        return view
    }()
    
    weak var delegate: PlayerMasterDelegate?
}

extension PlayerMasker: DFPlayerMaskable {
}


