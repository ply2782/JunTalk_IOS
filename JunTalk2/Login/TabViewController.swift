//
//  TabViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/04/26.
//

import UIKit
import Alamofire
import SwiftyJSON


class TabViewController: UITabBarController {
    var userModel = UserData?.self;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        self.selectedIndex=0;
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view가 Load됨 (viewWillAppear)")
        
        
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
    
    
    
    
    // 새로운 유저 등록
    fileprivate func saveNewUser(firebaseToken: String?,
                                 user_Index: Int64?,
                                 userBirthDay: String?,
                                 userJoinDate: String?,
                                 user_Introduce: String?,
                                 userId: String?,
                                 userName: String?,
                                 userMainPhoto: String?,
                                 user_lastLogin: String?,
                                 userKakaoOwnNumber: Int64?) {
        
        CoreDataManager.shared.saveUser(
            firebaseToken: firebaseToken!,
            user_Index: user_Index!,
            userBirthDay: userBirthDay!,
            userJoinDate: userJoinDate!,
            user_Introduce: user_Introduce!,
            userId: userId!,
            userName: userName!,
            userMainPhoto: userMainPhoto!,
            user_lastLogin: user_lastLogin!,
            userKakaoOwnNumber: userKakaoOwnNumber!) {
            onSuccess in
            print("saved = \(onSuccess)")
        }
        
    }
    
    fileprivate func deleteUser(_ id: Int64) {
        CoreDataManager.shared.deleteUser(id: id) { onSuccess in
            print("deleted = \(onSuccess)")
        }
    }
    
}
