//
//  Structurer.swift
//  Test
//
//  Created by 바틀 on 2022/03/14.
//

import Foundation

struct BulletinBoardModel : Codable {
    
    
    var category :String;
    
    var userId : String;
    
    var bulletin_isUserLike : Bool;
    
    var user_Index : Int;
    
    var bulletin_Content : String;
    
    var allUrls : [String];
    
    var userMainPhoto : String;
    
    var bulletin_Uuid : String;
    
    var bulletin_LikeCount : Int;
    
    var bulletin_CommentCount : Int;
    
    var bulletin_RegDate : String;
    
    var isBlock : Bool;

    
    init() throws {
        
        category = "";
        userId = "";
        bulletin_Uuid = "";
        bulletin_isUserLike = false;
        user_Index = 0;
        bulletin_Content = "";
        allUrls = [];
        userMainPhoto = "";
        bulletin_LikeCount = 0;
        bulletin_CommentCount = 0;
        bulletin_RegDate = "";
        isBlock = false;
        
    }
    
    
}


   
   
