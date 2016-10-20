//
//  Extensions.swift
//  DFPlayer
//
//  Created by Difff on 16/10/21.
//  Copyright © 2016年 Difff. All rights reserved.
//

import UIKit

extension UISlider {
    private class UISliderAssociation: NSObject {
        static let sharedInstance = UISliderAssociation()
        private override init() {}
        var touchMovie: Bool = false
    }
    
    var df_touchMovie: Bool {
        get {
            return UISliderAssociation.sharedInstance.touchMovie
        }
        set {
            UISliderAssociation.sharedInstance.touchMovie = newValue
        }
    }
}

