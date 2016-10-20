//
//  DFPlayerLoadingEyeable.swift
//  DFPlayer
//
//  Created by Difff on 16/10/17.
//  Copyright © 2016年 Difff. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol DFPlayerLoadingEyeable: class {
    var lv_container: UIView { get }
    var loadingView: NVActivityIndicatorView { get }
    
    /* for layout & style */
    func setupLoadingView()
}

private class DFAssociation: NSObject {
    static let sharedInstance = DFAssociation()
    private override init() {}
    
    let loadingView = NVActivityIndicatorView(frame: CGRectZero, type: .BallRotateChase, color: UIColor.whiteColor(), padding: 0)
}

extension DFPlayerLoadingEyeable {
    var loadingView: NVActivityIndicatorView {
        get {
            return DFAssociation.sharedInstance.loadingView
        }
    }
    
    func setupLoadingView() {
        lv_container.addSubview(loadingView)
        loadingView.snp_makeConstraints { (make) in
            make.center.equalTo(lv_container)
            make.width.height.equalTo(36)
        }
        loadingView.stopAnimation()
    }
}
