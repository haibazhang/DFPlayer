//
//  Extensions.swift
//  DFPlayer
//
//  Created by Difff on 16/10/21.
//  Copyright © 2016年 Difff. All rights reserved.
//

import UIKit

extension UIView {
    func df_addSubviews(subviews: [UIView]) {
        for view in subviews {
            self.addSubview(view)
        }
    }
}

extension Int {
    func df_toHourFormat() -> String {
        let hour = self/3600
        let minute = self%3600/60
        let second = self%3600%60
        
        if (hour > 0) {
            return String(format: "%02d:%02d:%02d", hour, minute, second)
        } else {
            return String(format: "%02d:%02d", minute, second)
        }
    }
}


