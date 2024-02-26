//
//  CoreDataManager.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/05/05.
//

import Foundation
import UIKit
import CoreData

class CoreDataManager {
    static let shared: CoreDataManager = CoreDataManager()
    
    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    lazy var context = appDelegate?.persistentContainer.viewContext
    
    let modelName: String = "User"
        
    
    func getUsers(ascending: Bool = false) -> [User] {
        var models: [User] = [User]()
        
        if let context = context {
            let idSort: NSSortDescriptor = NSSortDescriptor(key: "id", ascending: ascending)
            let fetchRequest: NSFetchRequest<NSManagedObject>
                = NSFetchRequest<NSManagedObject>(entityName: modelName)
            fetchRequest.sortDescriptors = [idSort]
            
            do {
                if let fetchResult: [User] = try context.fetch(fetchRequest) as? [User] {
                    models = fetchResult
                }
            } catch let error as NSError {
                print("Could not fetch🥺: \(error), \(error.userInfo)")
            }
        }
        return models
    }
    
    func saveUser(firebaseToken: String,
                  user_Index: Int64,
                  userBirthDay: String,
                  userJoinDate: String,
                  user_Introduce: String,
                  userId: String,
                  userName: String,
                  userMainPhoto: String,
                  user_lastLogin: String,
                  userKakaoOwnNumber: Int64,
                  onSuccess: @escaping ((Bool) -> Void)) {
        if let context = context,
           let entity: NSEntityDescription
            = NSEntityDescription.entity(forEntityName: modelName, in: context) {
            
            if let user: User = NSManagedObject(entity: entity, insertInto: context) as? User {
                
                user.firebaseToken = firebaseToken;
                user.user_Index = user_Index;
                user.userBirthDay = userBirthDay;
                user.userJoinDate = userJoinDate;
                user.user_Introduce = user_Introduce;
                user.userId = userId;
                user.userName = userName;
                user.userMainPhoto = userMainPhoto;
                user.user_lastLogin = user_lastLogin;
                user.userKakaoOwnNumber = userKakaoOwnNumber;
                
                
                contextSave { success in
                    onSuccess(success)
                }
            }
        }
    }
    
    func deleteUser(id: Int64, onSuccess: @escaping ((Bool) -> Void)) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = filteredRequest(id: id)
        
        do {
            if let results: [User] = try context?.fetch(fetchRequest) as? [User] {
                if results.count != 0 {
                    context?.delete(results[0])
                }
            }
        } catch let error as NSError {
            print("Could not fatch🥺: \(error), \(error.userInfo)")
            onSuccess(false)
        }
        
        contextSave { success in
            onSuccess(success)
        }
    }
}

extension CoreDataManager {
    fileprivate func filteredRequest(id: Int64) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
            = NSFetchRequest<NSFetchRequestResult>(entityName: modelName)
        fetchRequest.predicate = NSPredicate(format: "id = %@", NSNumber(value: id))
        return fetchRequest
    }
    
    fileprivate func contextSave(onSuccess: ((Bool) -> Void)) {
        do {
            try context?.save()
            onSuccess(true)
        } catch let error as NSError {
            print("Could not save🥶: \(error), \(error.userInfo)")
            onSuccess(false)
        }
    }
}
