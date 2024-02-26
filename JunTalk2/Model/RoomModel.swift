//
//  RoomModel.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/05/06.
//

import Foundation

struct RoomData : Codable {
    
    var room_Index: Int;
    var room_Conversation: String;
    var room_joinCount: Int;
    var room_RegDate: String;
    var room_Title: String;
    var room_Uuid: String;
    var unreadCount: Int;
    var alarm: String;
    var roomType: String;
    var conversationTime: String;
    var joinPeopleImageList: [String];
    var mainRoomPhoto: String;
    var roomHashTag: [String];
    var userKakaoOwnNumber: Int;
    var joinRoomContent: String;
    
}

