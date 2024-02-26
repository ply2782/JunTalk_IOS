//
//  ClubModel.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/05/08.
//

import Foundation

struct ClubData  : Codable {
    
    var club_Index : Int?
    var club_Uuid : String?
    var userKakaoOwnNumber : Int?
    var user_Index : Int?
    var isDelete : Bool?
    var userId : String?
    var title : String?
    var userNickName : String?
    var limitJoinCount : Int?
    var minAge : Int?
    var maxAge : Int?
    var expectedMoney : Int?
    var currentSumJoinCount : Int?
    var place : String?
    var clubIntroduce : String?
    var regDate : String?
    var clubListFile : String?
    var hashTagList : String?
    var allUrls : [String]?
    var myJoinInfo :  [MyJoinClubInfo]?
//    var clubBlockInfo :  Array<Dictionary<String, Any>>?
    var blockReportContent : String?
    
    init() throws {
        
        self.club_Index = -1;
        self.club_Uuid = "";
        self.userKakaoOwnNumber = -1;
        self.user_Index = -1;
        self.isDelete = false;
        self.userId = ""
        self.title = ""
        self.userNickName = ""
        self.limitJoinCount = -1;
        self.minAge = -1;
        self.maxAge = -1;
        self.expectedMoney = -1;
        self.currentSumJoinCount = -1;
        self.place = ""
        self.clubIntroduce = ""
        self.regDate = "";
        self.clubListFile = "";
        self.hashTagList = "";
        self.allUrls = [];
        self.myJoinInfo = [try MyJoinClubInfo.init()];
//        self.clubBlockInfo = [[:]];
        self.blockReportContent = "";
    }
    
}



struct MyJoinClubInfo  : Codable {
    
    var club_Index : Int?
    var club_Uuid : String?
    var userKakaoOwnNumber : Int?
    var user_Index : Int?
    var isDelete : Bool?
    var userId : String?
    var title : String?
    var userNickName : String?
    var limitJoinCount : Int?
    var minAge : Int?
    var maxAge : Int?
    var expectedMoney : Int?
    var currentSumJoinCount : Int?
    var place : String?
    var clubIntroduce : String?
    var regDate : String?
    var clubListFile : String?
    var hashTagList : String?
    var allUrls : [String]?
    var blockReportContent : String?
    
    init() throws {
        
        self.club_Index = -1;
        self.club_Uuid = "";
        self.userKakaoOwnNumber = -1;
        self.user_Index = -1;
        self.isDelete = false;
        self.userId = ""
        self.title = ""
        self.userNickName = ""
        self.limitJoinCount = -1;
        self.minAge = -1;
        self.maxAge = -1;
        self.expectedMoney = -1;
        self.currentSumJoinCount = -1;
        self.place = ""
        self.clubIntroduce = ""
        self.regDate = "";
        self.clubListFile = "";
        self.hashTagList = "";
        self.allUrls = [];
    
        self.blockReportContent = "";
    }
    
}
