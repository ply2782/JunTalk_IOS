//
//  User+CoreDataProperties.swift
//  
//
//  Created by 바틀 on 2022/05/05.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var simState: String?
    @NSManaged public var firebaseToken: String?
    @NSManaged public var userDeleteDate: String?
    @NSManaged public var user_Index: Int64
    @NSManaged public var simOperator: String?
    @NSManaged public var networkOperator: String?
    @NSManaged public var userBirthDay: String?
    @NSManaged public var userPassword: String?
    @NSManaged public var userJoinDate: String?
    @NSManaged public var simCountryIso: String?
    @NSManaged public var networkOperatorName: String?
    @NSManaged public var userKakaoId: String?
    @NSManaged public var user_Introduce: String?
    @NSManaged public var currentState: String?
    @NSManaged public var userId: String?
    @NSManaged public var android_id: String?
    @NSManaged public var networkCountryIso: String?
    @NSManaged public var delete: Bool
    @NSManaged public var simOperatorName: String?
    @NSManaged public var userPhoneNumber: String?
    @NSManaged public var userName: String?
    @NSManaged public var userMainPhoto: String?
    @NSManaged public var user_lastLogin: String?
    @NSManaged public var userGender: String?
    @NSManaged public var userKakaoOwnNumber: Int64

}
