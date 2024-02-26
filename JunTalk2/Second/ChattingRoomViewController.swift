//
//  ChattingRoomViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/05/06.
//

import UIKit
import StompClientLib
import SwiftyJSON
import Alamofire
class ChattingRoomViewController: UIViewController {
    
    
    var conversation : String?
    let url = NSURL(string: "ws://ply2782ply2782.cafe24.com:8080/chatting/websocket")
    var socketClient = StompClientLib()
    var chatsArray: [Chat] = []
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var chatCollView: UICollectionView!
    @IBOutlet weak var inputViewContainerBottomConstraint: NSLayoutConstraint!
    var room_Uuid : String? = "";
    var userId : String? = "";
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerSockect();
        self.assignDelegates()
        self.manageInputEventsForTheSubViews()        
        self.loadChattingConversation(room_Uuid: room_Uuid, userId: userId );
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view가 Load됨 (viewWillAppear)")
        fetchChatData();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("view가 화면에 나타남 (viewDidAppear)")
        
    }
    
    @IBAction func sendButton(_ sender: Any) {
        sendMessage();
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("view가 사라지기 전 (viewWillDisappear)")
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("view가 사라짐 (viewDidDisappear)")
        disconnect();
    }
    
    
    @IBAction func closeViewController(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func registerSockect() {
        socketClient.openSocketWithURLRequest(request: NSURLRequest(url: url! as URL), delegate: self)
    }
    
    func subscribe() {
        socketClient.subscribe(destination: "/send/chatting/1")
    }
    
    func disconnect() {
        socketClient.disconnect()
    }
    
    
    func loadChattingConversation(room_Uuid : String? , userId : String?){
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/roomController/loadChattingConversation"
        
        let param: Parameters = [
            "room_Uuid": room_Uuid! as Any,
            "userId": userId! as Any
        ];
        
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).responseDecodable(of:[Chat].self){
            response in
            switch response.result {
            case .success:
                for item in response.value!{
                    self.chatsArray.append(item);
                }
                self.chatCollView.reloadData()
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    
    private func fetchChatData() {
        if let url = Bundle.main.url(forResource: "chat", withExtension: "json") {
            
            do {
                let data = try Data.init(contentsOf: url)
                let decoder = JSONDecoder.init()
                self.chatsArray = try decoder.decode([Chat].self, from: data)
                
                self.chatCollView.reloadData()
                
            } catch let err {
                print(err.localizedDescription)
            }
            
        }
    }
    
    private func manageInputEventsForTheSubViews() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChangeNotfHandler(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChangeNotfHandler(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardFrameChangeNotfHandler(_ notification: Notification) {
        
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            inputViewContainerBottomConstraint.constant = isKeyboardShowing ? keyboardFrame.height : 0
            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                
                if isKeyboardShowing {
                    let lastItem = self.chatsArray.count - 1
                    let indexPath = IndexPath(item: lastItem, section: 0)
                    self.chatCollView.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
            })
        }
    }
    
    private func assignDelegates() {
        
        self.chatCollView.register(ChatCell.self, forCellWithReuseIdentifier: ChatCell.identifier)
        self.chatCollView.dataSource = self
        self.chatCollView.delegate = self
        self.messageTextField.delegate = self
    }
    
    @IBAction func onSendChat(_ sender: UIButton?) {
        
        guard let chatText = messageTextField.text, chatText.count >= 1 else { return }
        messageTextField.text = ""
        self.chatCollView.reloadData()
        let lastItem = self.chatsArray.count - 1
        let indexPath = IndexPath(item: lastItem, section: 0)
        //        self.chatCollView.insertItems(at: [indexPath])
        self.chatCollView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    
    // Publish Message
    func sendMessage() {
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "aa HH:mm"
        let todayFormat = dateFormatter.string(from: nowDate)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let today = dateFormatter.string(from: nowDate)
        let chatInit = Chat.init(
            userToken: "dr9MNk7KRtaIMwnZpFIC1e:APA91bHIvcJQb1IO9qJv6vH6-AJGfPJMSejgIAi9fgdQJovboW39sKlKHs6jVzaPXIvvutKdNrM9L8Fgl4v0MLvQOdF34CGcPx7lP5bn27IIc0v9YVBw7gSxy--bRa9hiqlVob1LE5VB",
            room_Uuid: "75ee3152-6f8c-42f2-a48a-2d4dc499d3d9",
            today: todayFormat,
            room_Index: 1,
            userId: "푸르릉",
            currentState: "IN",
            userImage: "0c3289c0-1848-42c9-b8fc-502688bc331d_JunTalk.jpg",
            userConversation: messageTextField.text!,
            room_JoinPeopleName: "푸르릉",
            room_JoinPeopleImage: ["0c3289c0-1848-42c9-b8fc-502688bc331d_JunTalk.jpg"],
            userJoinCount: 0,
            imageUrl: "",
            videoUrl: "",
            uploadUrl: "0c3289c0-1848-42c9-b8fc-502688bc331d_JunTalk.jpg",
            userState: "IN",
            userConversationTime: todayFormat,
            currentActualTime: today,
            userMessageType: "CONVERSATION",
            chatting_VideoFile: "",
            chatting_ImageFile: "0c3289c0-1848-42c9-b8fc-502688bc331d_JunTalk.jpg",
            actualTime: 0,
            unReadCount: 0,
            isDelete: false,
            is_sent_by_me: false
        )
        
//        self.chatsArray.append(chatInit);
        
        let payloadObject : [String : Any] =
            
            [
                "userToken" : "dr9MNk7KRtaIMwnZpFIC1e:APA91bHIvcJQb1IO9qJv6vH6-AJGfPJMSejgIAi9fgdQJovboW39sKlKHs6jVzaPXIvvutKdNrM9L8Fgl4v0MLvQOdF34CGcPx7lP5bn27IIc0v9YVBw7gSxy--bRa9hiqlVob1LE5VB",
                "room_Uuid": "75ee3152-6f8c-42f2-a48a-2d4dc499d3d9",
                "today" : todayFormat,
                "room_Index" : 1,
                "userId" : "푸르릉",
                "currentState"  : "IN",
                "userImage" :
                    "0c3289c0-1848-42c9-b8fc-502688bc331d_JunTalk.jpg",
                "userConversation" : messageTextField.text! as Any,
                "room_JoinPeopleName" : "JunTalk",
                "userConversationTime" :todayFormat,
                //                "actualTime" : "\(nowDate)",
                "currentActualTime" : today,
                "userMessageType" : "CONVERSATION",
            ];
        socketClient.sendJSONForDict(
            dict: payloadObject as AnyObject,
            toDestination: "/comingIn/messageShare")
        
        self.chatCollView.reloadData()
        messageTextField.text = "";
    }
}



extension ChattingRoomViewController : StompClientLibDelegate{
    
    func jsonToNSData(json: AnyObject) -> NSData?{
        do {
            return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) as NSData
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil;
        
    }
    
    func stompClientJSONBody(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: String?, withHeader header: [String : String]?, withDestination destination: String) {
        print("DESTINATION : \(destination)")
        print("String JSON BODY : \(String(describing: jsonBody))")
    }
    
    
    
    
    func stompClient(client: StompClientLib!,
                     didReceiveMessageWithJSONBody jsonBody: AnyObject?, akaStringBody stringBody: String?,
                     withHeader header: [String : String]?,
                     withDestination destination: String) {
            
            do{
                
                if let jsonArray = try JSONSerialization.data(withJSONObject: jsonBody!, options: .prettyPrinted) as? Data
                {
                    
                    let decoder = JSONDecoder.init()
                    let chatsArray_Copy = try decoder.decode(Chat.self, from: jsonArray)
                    
                    self.chatsArray.append(chatsArray_Copy)
                    self.chatCollView.reloadData()
                    
                }else{
                    print("bad Json");
                }
                
            }catch(let error){
                print("error : \(error)");
            }
        
    }
    
    func stompClientDidDisconnect(client: StompClientLib!) {
        print("Stomp socket is disconnected")
    }
    
    func stompClientDidConnect(client: StompClientLib!) {
        subscribe();
    }
    
    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        print("Error send : " + description)
        print("Receipt : \(receiptId)")
        
    }
    
    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        print(description);
        socketClient.disconnect()
        registerSockect();
        
    }
    
    func serverDidSendPing() {
        print("Server ping")
    }
}


extension ChattingRoomViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return chatsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = chatCollView.dequeueReusableCell(withReuseIdentifier: ChatCell.identifier, for: indexPath) as? ChatCell {
            
            let chat = chatsArray[indexPath.item]
            
            cell.messageTextView.text = chat.userConversation
            cell.nameLabel.text = chat.userId
            cell.profileImageURL = URL.init(string: chat.userImage!)!
            
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            var estimatedFrame = NSString(string: chat.userConversation!).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], context: nil)
            estimatedFrame.size.height += 18
            
            let nameSize = NSString(string: chat.userId!).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)], context: nil)
            
            let maxValue = max(estimatedFrame.width, nameSize.width)
            estimatedFrame.size.width = maxValue
            
            
            if chat.userId == "JunTalk" {
                cell.nameLabel.textAlignment = .left
                cell.profileImageView.frame = CGRect(x: 8, y: estimatedFrame.height - 8, width: 30, height: 30)
                let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/userController/profileImageShow?imageName=\(String(describing: cell.profileImageURL))");
                cell.profileImageView.load(url: url!)
                cell.nameLabel.frame = CGRect(x: 48 + 8, y: 0, width: estimatedFrame.width + 16, height: 18)
                cell.messageTextView.frame = CGRect(x: 48 + 8, y: 12, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.textBubbleView.frame = CGRect(x: 48 - 10, y: -4, width: estimatedFrame.width + 16 + 8 + 16 + 12, height: estimatedFrame.height + 20 + 6)
                cell.bubbleImageView.image = ChatCell.grayBubbleImage
                cell.bubbleImageView.tintColor = UIColor(white: 0.95, alpha: 1)
                cell.messageTextView.textColor = UIColor.black
                
            } else {
                
                cell.nameLabel.textAlignment = .right
                cell.profileImageView.frame = CGRect(x: self.chatCollView.bounds.width - 38, y: estimatedFrame.height - 8, width: 30, height: 30)
                let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/userController/profileImageShow?imageName=\(String(describing: cell.profileImageURL))");
                cell.profileImageView.load(url: url!)
                cell.nameLabel.frame = CGRect(x: collectionView.bounds.width - estimatedFrame.width - 16 - 16 - 8 - 30 - 12, y: 0, width: estimatedFrame.width + 16, height: 18)
                cell.messageTextView.frame = CGRect(x: collectionView.bounds.width - estimatedFrame.width - 16 - 16 - 8 - 30, y: 12, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.textBubbleView.frame = CGRect(x: collectionView.frame.width - estimatedFrame.width - 16 - 8 - 16 - 10 - 30, y: -4, width: estimatedFrame.width + 16 + 8 + 10, height: estimatedFrame.height + 20 + 6)
                cell.bubbleImageView.image = ChatCell.blueBubbleImage
                cell.bubbleImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                cell.messageTextView.textColor = UIColor.white
            }
            
            return cell
        }
        
        return ChatCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let chat = chatsArray[indexPath.item]
        if let chatCell = cell as? ChatCell {
            chatCell.profileImageURL = URL.init(string: chat.userImage!)!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let chat = chatsArray[indexPath.item]
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        var estimatedFrame = NSString(string: chat.userConversation!).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], context: nil)
        estimatedFrame.size.height += 18
        
        return CGSize(width: chatCollView.frame.width, height: estimatedFrame.height + 20)
    }
    
}

extension ChattingRoomViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let txt = textField.text, txt.count >= 1 {
            textField.resignFirstResponder()
            return true
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        textField.resignFirstResponder()
        onSendChat(nil)
    }
}
