//
//  AppDelegate.swift
//  DFPlayer
//
//  Created by Difff on 16/10/13.
//  Copyright © 2016年 Difff. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        if let wdn = window {
            wdn.backgroundColor = UIColor.whiteColor()
            wdn.makeKeyAndVisible()
            wdn.rootViewController = DFNavigationController(rootViewController: MainViewController())
        }
        return true
    }
}

class RootCtrlSettings {
    static var shouldAutorotate: Bool = false
    static var prefersStatusBarHidden: Bool = false
}

class DFNavigationController: UINavigationController {
    override func shouldAutorotate() -> Bool {
        return RootCtrlSettings.shouldAutorotate
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return RootCtrlSettings.prefersStatusBarHidden
    }
}

