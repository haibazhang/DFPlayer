//
//  DFPlayerControlPanelDelegate.swift
//  DFPlayer
//
//  Created by Difff on 16/10/22.
//  Copyright © 2016年 Difff. All rights reserved.
//

import UIKit

protocol PlayerControlPanelDelegate: class {
    func didControlPanelTap()
    func didPlayButtonTap()
    func didFullScreenTap(sender: UIButton)
    func didSliderTouchBegin(sender: UISlider)
    func didSliderTouchMovie(sender: UISlider)
    func didSliderTouchEnd(sender: UISlider)
}

extension PlayerControlPanelDelegate {
    func didControlPanelTap() {}
    func didPlayButtonTap() {}
    func didFullScreenTap(sender: UIButton) {}
    func didSliderTouchBegin(sender: UISlider) {}
    func didSliderTouchMovie(sender: UISlider) {}
    func didSliderTouchEnd(sender: UISlider) {}
}