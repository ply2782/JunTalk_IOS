//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by 바틀 on 2022/10/22.
//

import UserNotifications
import Firebase

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
//    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
//        self.contentHandler = contentHandler
//        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
//
//        if let bestAttemptContent = bestAttemptContent {
//            // Modify the notification content here...
//
//            let apsData = request.content.userInfo["aps"] as! [String : Any]
//            let alertData = apsData["alert"] as! [String : Any]
//            let imageData = request.content.userInfo["fcm_options"] as! [String : Any]
//            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
//            bestAttemptContent.body = "\(bestAttemptContent.body) [modified]"
//
//            guard let urlImageString = imageData["image"] as? String else {
//                contentHandler(bestAttemptContent)
//                return
//            }
//            if let newsImageUrl = URL(string: urlImageString) {
//
//                guard let imageData = try? Data(contentsOf: newsImageUrl) else {
//                    contentHandler(bestAttemptContent)
//                    return
//                }
//                guard let attachment = UNNotificationAttachment.saveImageToDisk(identifier: "8eb70cfb-c268-4db0-9161-6b96cdc616fc_JunTalk.jpg", data: imageData, options: nil) else {
//                    contentHandler(bestAttemptContent)
//                    return
//                }
//                bestAttemptContent.attachments = [ attachment ]
//            }
//            contentHandler(bestAttemptContent)
//        }
//    }

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        // 🔥 FirebaseMessaging
        guard let bestAttemptContent = bestAttemptContent else { return }
        FIRMessagingExtensionHelper().populateNotificationContent(bestAttemptContent, withContentHandler: contentHandler)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
}

extension UNNotificationAttachment {
    static func saveImageToDisk(identifier: String, data: Data, options: [AnyHashable : Any]? = nil) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true)!

        do {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            let fileURL = folderURL.appendingPathExtension(identifier)
            try data.write(to: fileURL)
            let attachment = try UNNotificationAttachment(identifier: identifier, url: fileURL, options: options)
            return attachment
        } catch {
            print("saveImageToDisk error - \(error)")
        }
        return nil
    }
}
