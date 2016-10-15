//
//  MainViewController.swift
//  DFPlayer
//
//  Created by Difff on 16/10/14.
//  Copyright © 2016年 Difff. All rights reserved.
//

import UIKit
import SnapKit
import ReactiveUI

class MainViewController: UIViewController {
    
    lazy var demoButton: UIButton = {
        let button = UIButton()
        button.setTitle("DFPlayer", forState: .Normal)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.addAction({ (_) in
            let playerCtrl = PlayerViewController()
            self.navigationController?.pushViewController(playerCtrl, animated: true)
            }, forControlEvents: .TouchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        setupDemoButton()
    }
    
    func setupDemoButton() {
        view.addSubview(demoButton)
        demoButton.snp_makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.height.equalTo(80)
        }
    }
    
}
