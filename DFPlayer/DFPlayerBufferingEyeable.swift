//
//  DFPlayerBufferingEyeable.swift
//  DFPlayer
//
//  Created by Difff on 16/10/17.
//  Copyright © 2016年 Difff. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol DFPlayerBufferingEyeable: class {
    var bf_container: UIView { get }
    var bufferingView: NVActivityIndicatorView { get }
    func setupBufferingView()
}

private class DFAssociation: NSObject {
    static let sharedInstance = DFAssociation()
    private override init() {}
    
    let bufferingView = NVActivityIndicatorView(frame: CGRectZero, type: .BallRotateChase, color: UIColor.whiteColor(), padding: 0)
}

extension DFPlayerBufferingEyeable {
    var bufferingView: NVActivityIndicatorView {
        get {
            return DFAssociation.sharedInstance.bufferingView
        }
    }
    
    func setupBufferingView() {
        bf_container.addSubview(bufferingView)
        bufferingView.snp_makeConstraints { (make) in
            make.center.equalTo(bf_container)
            make.width.height.equalTo(36)
        }
        bufferingView.stopAnimation()
    }
}
