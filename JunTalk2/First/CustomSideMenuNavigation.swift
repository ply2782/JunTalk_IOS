//
//  CustomSideMenuNavigation.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/06/01.
//

import Foundation
import UIKit
import SideMenu

class CustomSideMenuNavigation: SideMenuNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.menuWidth = self.view.frame.width * 0.8
        self.presentationStyle = .menuSlideIn
        self.statusBarEndAlpha = 0.0
        self.presentDuration = 0.5
        self.dismissDuration = 0.5
    }
    
}
