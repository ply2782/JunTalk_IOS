//
//  ReelsModel.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/08/10.
//

import Foundation

struct ReelsModel : Codable{
    
    
    
    var lils_Uuid : String?;
    var lils_Index : Int?;
    var userId: String?;
    var fromUser_Index : Int?;
    var user_Index : Int?;
    var lils_LikeClick : Bool?;
    var userMainPhoto : String?;
    var regDate : String?;
    var content : String?;
    var hashTagList : String?;
    var likeCount : Int?;
    var replyCount : Int?;
    var videoUrl : String?;
    var lils_videoUrl : String?;
    var isDelete : Bool?;
    var isBlock : String?;
    var replyList : [String]?;
    var heartList : [String]?;
    
    
    init() throws {
        
        self.lils_Uuid = ""
        self.lils_Index = -1
        self.userId = ""
        self.fromUser_Index = -1
        self.user_Index = -1
        self.lils_LikeClick = false
        self.userMainPhoto = ""
        self.regDate = ""
        self.content = ""
        self.hashTagList = "";        
        self.likeCount = -1
        self.replyCount = -1
        self.videoUrl = ""
        self.lils_videoUrl = ""
        self.isDelete = false
        self.isBlock = "0"
        self.replyList = [];
        self.heartList = [];
        
    }
    
}
