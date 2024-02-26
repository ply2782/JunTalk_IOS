//
//  WholeController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/04/24.
//

import UIKit
import MaterialComponents.MaterialBottomNavigation
import MaterialComponents.MDCBottomNavigationBar

class WholeController: UIViewController{

    var bottomNavBar = MDCBottomNavigationBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("메모리에 View가 Load됨 (viewDidLoad)")
            
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view가 Load됨 (viewWillAppear)")
        
        let size = bottomNavBar.sizeThatFits(view.bounds.size)
         let bottomNavBarFrame = CGRect(x: 0,
           y: view.bounds.height - size.height,
           width: size.width,
           height: size.height
         )
         bottomNavBar.frame = bottomNavBarFrame
        bottomNavBar.titleVisibility = MDCBottomNavigationBarTitleVisibility.selected
        bottomNavBar.alignment = MDCBottomNavigationBarAlignment.justifiedAdjacentTitles
        view.addSubview(bottomNavBar)
        
        let homeItem = UITabBarItem(
            title: "Home",
            image: UIImage(named: "ic_blockpeople"),
            tag: 0)
        let messagesItem = UITabBarItem(
            title: "Messages",
            image: UIImage(named: "ic_email"),
            tag: 0)
        messagesItem.badgeValue = "8"
        let favoritesItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(named: "ic_favorite"),
            tag: 0)
        favoritesItem.badgeValue = ""
        let readerItem = UITabBarItem(
            title: "Reader",
            image: UIImage(named: "ic_reader"),
            tag: 0)
        readerItem.badgeValue = "88"

        let birthdayItem = UITabBarItem(
            title: "ic_birthday",
            image: UIImage(named: "ic_cake"),
            tag: 0)
        birthdayItem.badgeValue = "888+"
        bottomNavBar.items = [homeItem, messagesItem, favoritesItem, readerItem, birthdayItem]
        bottomNavBar.selectedItem = messagesItem
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("view가 화면에 나타남 (viewDidAppear)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("view가 사라지기 전 (viewWillDisappear)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("view가 사라짐 (viewDidDisappear)")
    }

}
