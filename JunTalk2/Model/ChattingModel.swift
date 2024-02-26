//
//  ChattingModel.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/05/08.
//

import Foundation
import UIKit

struct Chat: Codable {
            
    var userToken : String?;
    var room_Uuid: String?;
    var today: String?;
    var room_Index : Int?;
    var userId : String?;
    var currentState : String?;
    var userImage : String?;
    var userConversation : String?;
    var room_JoinPeopleName :String?;
    var room_JoinPeopleImage: [String]?;
    var userJoinCount:Int?;
    var imageUrl:String?;
    var videoUrl:String?;
    var uploadUrl:String?;
    var userState:String?;
    var userConversationTime:String?;
    var currentActualTime:String?;
    var userMessageType:String?;
    var chatting_VideoFile:String?;
    var chatting_ImageFile:String?;
    var actualTime : Int64?;
    var unReadCount : Int?;
    var isDelete : Bool?;
    var is_sent_by_me: Bool?
}
