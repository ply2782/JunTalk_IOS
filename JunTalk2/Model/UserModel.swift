//
//  Structurer.swift
//  Test
//
//  Created by 바틀 on 2022/03/14.
//

import Foundation

struct UserData : Codable {
    
    var firebaseToken: String;
    var user_Index: Int;
    var userId: String;
    var userIdentity: String;
    var userGender: String
    var userName: String
    var userKakaoId: String;
    var userPassword: String;
    var userPhoneNumber: String
    var userMainPhoto: String
    
    var user_Introduce: String
    var userJoinDate: String
    var userBirthDay: String
    var userKakaoOwnNumber: Int;
    var user_lastLogin: String;
    var userDeleteDate: String;
    var delete: Bool
    
    init() throws {
        
        self.firebaseToken = ""
        self.user_Index = 0
        self.userId = ""
        self.userIdentity=""
        self.userGender=""
        self.userName=""
        self.userKakaoId=""
        self.userPassword=""
        self.userPhoneNumber=""
        self.userMainPhoto=""
        
        self.user_Introduce=""
        self.userJoinDate=""
        self.userBirthDay=""
        self.userKakaoOwnNumber=0
        self.user_lastLogin=""
        self.userDeleteDate=""
        self.delete=false
        
    }
    
    
}


   
   
