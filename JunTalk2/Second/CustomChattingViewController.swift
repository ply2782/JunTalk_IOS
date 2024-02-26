//
//  CustomChattingViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/06/13.
//

import UIKit
import Alamofire
import StompClientLib
import Kingfisher
import Lottie
import AVFoundation
import AVKit
import MobileCoreServices





protocol ExitChattingRoom : AnyObject{
    func exitChattingRoom(itemModel : Dictionary<String,Any>);
}


class CustomChattingViewController: UIViewController , UITextFieldDelegate, ExitChattingRoom {
    
    func exitChattingRoom(itemModel: Dictionary<String, Any>) {
        exitChattingRoom(roomModel: itemModel);
    }
    
    let photo = UIImagePickerController()
    var userMainPhotoName :String = ""
    @IBOutlet weak var fileUploadImageView: UIImageView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet var wholeView: UIView!
    
    let fileArray : [Dictionary<String,Any>] = [];
    let url = NSURL(string: "ws://ply2782ply2782.cafe24.com:8080/chatting/websocket")
    var socketClient = StompClientLib()
    var chatsArray: [Chat] = []
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var alarmSettingSegButton: UISegmentedControl!
    @IBOutlet weak var chattingTableView: UITableView!
    var originalKeyBoardHeight : CGFloat?
    var myModel : UserData!;
    var roomModel :Dictionary<String,Any> = [:];
    
    //    @IBOutlet weak var inputKeyboardHeight: NSLayoutConstraint!
    var room_Uuid : String? = "";
    var userId : String? = "";
    let cornerImageProcessor = RoundCornerImageProcessor(cornerRadius: 30)
    let retryStrategy = DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(3))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
        
        let data = UserDefaults.standard.object(forKey: "myModel")
        if(data != nil){
            let decoder = JSONDecoder()
            self.myModel = try? decoder.decode(UserData.self, from: data as! Data)
        }
        
        
        chattingTableView.delegate = self;
        chattingTableView.dataSource  = self;
        self.chattingTableView.register(UINib(nibName: "ChattingYouCell", bundle: nil), forCellReuseIdentifier: "ChattingYouCell")
        self.chattingTableView.register(UINib(nibName: "ChattingMeCell", bundle: nil), forCellReuseIdentifier: "ChattingMeCell")
        self.chattingTableView.register(UINib(nibName: "ChattingOtherCell", bundle: nil), forCellReuseIdentifier: "ChattingOtherCell")
        
        
        
        
        registerSockect();
        
        self.loadChattingConversation(room_Uuid: roomModel["room_Uuid"] as! String, userId: userId );
        self.chattingTableView.estimatedRowHeight = 50;
        self.chattingTableView.rowHeight = UITableView.automaticDimension;
        
        
        
        
        self.messageTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        //        let animationView = AnimationView(name:"skyintheballon")
        //        self.backgroundImageView.addSubview(animationView)
        //        animationView.frame = animationView.superview!.bounds
        //        animationView.contentMode = .scaleToFill
        //        //애니메이션 재생(애니메이션 재생모드 미 설정시 1회)
        //        animationView.play()
        //        //애니메이션 재생모드( .loop = 애니메이션 무한재생)
        //        animationView.loopMode = .loop
        
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(imageTapped))
        self.fileUploadImageView.isUserInteractionEnabled = true
        self.fileUploadImageView.addGestureRecognizer(tapGestureRecognizer)
        
        
        photo.delegate = self
    }
    
    
    
    
    func exitChattingRoom(roomModel : Dictionary<String, Any> ){
        
        let nowDate = Date()
        let todayDateFormatter = DateFormatter()
        todayDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        todayDateFormatter.locale = Locale(identifier:"ko_KR")
        let today = todayDateFormatter.string(from: nowDate)
        
        let conversationDateFormatter = DateFormatter()
        conversationDateFormatter.locale = Locale(identifier:"ko_KR")
        conversationDateFormatter.dateFormat = "aa HH:mm";
        let conversationTimeFormat = conversationDateFormatter.string(from: nowDate);
        
        
        let payloadObject : [String : Any] =
        
        [
            "userToken" : myModel.firebaseToken,
            "room_Uuid": roomModel["room_Uuid"]!,
            "room_Index" : roomModel["room_Index"]!,
            "userId" : myModel.userId,
            "userState"  : "OUT",            
            "userImage" :
                myModel.userMainPhoto,
            "userConversationTime" :conversationTimeFormat,
            "currentActualTime" : today,
            "actualTime" : nowDate.timeIntervalSinceNow,
            "userMessageType" : "EXIT",
        ];
        socketClient.sendJSONForDict(
            dict: payloadObject as AnyObject,
            toDestination: "/comingIn/messageShare")
        
        NotificationCenter.default.post(name:.chattingRefresh, object: nil)
//        self.navigationController?.popViewController(animated: true)
        self.presentingViewController?.dismiss(animated: true)
//        performSegue(withIdentifier: "unwindCRViewController", sender: self)
        
    }
    
    
    
    @objc private func videoTapped(sender : MyTapGesture){
        let videoUrl = sender.videoUrl!
        // AVPlayerController의 인스턴스 생성
        let playerController = AVPlayerViewController()
        // 비디오 URL로 초기화된 AVPlayer의 인스턴스 생성
        let player = AVPlayer(url: videoUrl)
        // AVPlayerViewController의 player 속성에 위에서 생성한 AVPlayer 인스턴스를 할당
        playerController.player = player
        self.present(playerController, animated: true){
            player.play() // 비디오 재생
        }
    }
    
    @objc private func zoomImageTapped(sender : MyTapGesture){
        let imageUrl = sender.imageUrl!
        let imageZoomViewController = self.storyboard?.instantiateViewController(withIdentifier: "ImageZoomViewController") as! ImageZoomViewController
        imageZoomViewController.modalPresentationStyle = .overCurrentContext
        imageZoomViewController.modalTransitionStyle = .crossDissolve
        imageZoomViewController.imageUrl = imageUrl
        self.present(imageZoomViewController, animated: true, completion: nil)
    }
    
    
    @objc private func imageTapped() {
        self.openLibrary();
    }
    
    func openLibrary(){
        photo.sourceType = .photoLibrary
        photo.mediaTypes = ["public.movie" , "public.image"];
        present(photo, animated: false, completion: nil)
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            photo.sourceType = .camera
            present(photo, animated: false, completion: nil)
        }
        else{
            print("Camera not available")
        }
    }
    
    private func updateProfileImage(_ image : UIImage){
        
        
        let imageData = image.jpegData(compressionQuality: 1)!
        let url = "http://ply2782ply2782.cafe24.com:8080/fileController/saveFileImage"
        
        upload(image: imageData, to: url)
        
    }
    //end of function
    func upload(image: Data, to url: String) {
        
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        let uuid = UIDevice.current.identifierForVendor?.uuidString.lowercased() ?? "";
        userMainPhotoName = "\(uuid)_JunTalk.jpg";
        
        AF.upload(multipartFormData:{ multiPart in
            multiPart.append(
                image, withName: "imageFiles",
                fileName: self.userMainPhotoName,
                mimeType: "image/jpeg")
            
        }, to: url , headers: headers)
        .uploadProgress(queue: .main, closure: { progress in
            //Current upload progress of file
            print("Upload Progress: \(progress.fractionCompleted)")
        }).response{ response in
            switch response.result {
            case .success:
                do{
                    let nowDate = Date()
                    let todayDateFormatter = DateFormatter()
                    todayDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    todayDateFormatter.locale = Locale(identifier:"ko_KR")
                    let today = todayDateFormatter.string(from: nowDate)
                    
                    let conversationDateFormatter = DateFormatter()
                    conversationDateFormatter.locale = Locale(identifier:"ko_KR")
                    conversationDateFormatter.dateFormat = "aa HH:mm";
                    let conversationTimeFormat = conversationDateFormatter.string(from: nowDate);
                    
                    
                    let payloadObject : [String : Any] =
                    
                    [
                        "userToken" : self.myModel.firebaseToken,
                        "room_Uuid": self.roomModel["room_Uuid"]!,
                        "room_Index" : self.roomModel["room_Index"]!,
                        "userId" : self.myModel.userId,
                        "currentState"  : "IN",
                        "userJoinCount" : self.roomModel["room_JoinCount"]!,
                        "userImage" :
                            self.myModel.userMainPhoto,
                        "userConversation" : self.messageTextField.text! as Any,
                        "userConversationTime" :conversationTimeFormat,
                        "chatting_ImageFile" :self.userMainPhotoName,
                        "currentActualTime" : today,
                        "actualTime" : nowDate.timeIntervalSinceNow,
                        "userMessageType" : "CONVERSATION",
                    ];
                    self.socketClient.sendJSONForDict(
                        dict: payloadObject as AnyObject,
                        toDestination: "/comingIn/messageShare")
                    self.chattingTableView.reloadData()
                    self.messageTextField.text = "";
                    
                    
                    
                }catch(let error){
                    print("error : \(error)");
                }
                return
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    
    
    
    
    private func updateVideoImage(_ video : URL){
        let url = "http://ply2782ply2782.cafe24.com:8080/fileController/saveFileImage"
        uploadVideo(video: video, to: url)
    }
    
    func uploadVideo(video: URL, to url: String) {
        
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        let uuid = UIDevice.current.identifierForVendor?.uuidString.lowercased() ?? "";
        userMainPhotoName = "\(uuid)_JunTalk.mp4";
        
        AF.upload(multipartFormData:{ multiPart in
            multiPart.append(
                video, withName: "videoFiles",
                fileName: self.userMainPhotoName,
                mimeType: "video/mp4")
            
        }, to: url , headers: headers)
        .uploadProgress(queue: .main, closure: { progress in
            //Current upload progress of file
            print("Upload Progress: \(progress.fractionCompleted)")
        }).response{ response in
            switch response.result {
            case .success:
                do{
                    let nowDate = Date()
                    let todayDateFormatter = DateFormatter()
                    todayDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    todayDateFormatter.locale = Locale(identifier:"ko_KR")
                    let today = todayDateFormatter.string(from: nowDate)
                    
                    let conversationDateFormatter = DateFormatter()
                    conversationDateFormatter.locale = Locale(identifier:"ko_KR")
                    conversationDateFormatter.dateFormat = "aa HH:mm";
                    let conversationTimeFormat = conversationDateFormatter.string(from: nowDate);
                    
                    let payloadObject : [String : Any] =
                    
                    [
                        "userToken" : self.myModel.firebaseToken,
                        "room_Uuid": self.roomModel["room_Uuid"]!,
                        "room_Index" : self.roomModel["room_Index"]!,
                        "userId" : self.myModel.userId,
                        "currentState"  : "IN",
                        "userJoinCount" : self.roomModel["room_JoinCount"]!,
                        "userImage" :
                            self.myModel.userMainPhoto,
                        "userConversation" : self.messageTextField.text! as Any,
                        "userConversationTime" : conversationTimeFormat,
                        "chatting_VideoFile" :self.userMainPhotoName,
                        "currentActualTime" : today,
                        "actualTime" : nowDate.timeIntervalSinceNow,
                        "userMessageType" : "CONVERSATION",
                    ];
                    self.socketClient.sendJSONForDict(
                        dict: payloadObject as AnyObject,
                        toDestination: "/comingIn/messageShare")
                    self.chattingTableView.reloadData()
                    self.messageTextField.text = "";
                    
                    
                    
                }catch(let error){
                    print("error : \(error)");
                }
                return
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    
    func imagePreview(from moviePath: URL, in seconds: Double) -> UIImage? {
        let timestamp = CMTime(seconds: seconds, preferredTimescale: 60)
        let asset = AVURLAsset(url: moviePath)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        guard let imageRef = try? generator.copyCGImage(at: timestamp, actualTime: nil) else {
            return nil
        }
        return UIImage(cgImage: imageRef)
    }
    
    
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            if(self.chatsArray.count > 0){
                let indexPath = IndexPath(row: (self.chatsArray.count - 1), section: 0)
                self.chattingTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
            
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        self.view.endEditing(true)
        self.messageTextField.resignFirstResponder() // TextField 비활성화
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   self.messageTextField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        
        let bounds = UIScreen.main.bounds
        //        let height = bounds.size.height
        UIView.animate(withDuration: 1) {
            self.view.window?.frame.origin.y = 0
        }
        
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        let userInfo:NSDictionary = sender.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.size.height
        originalKeyBoardHeight = keyboardHeight;
        UIView.animate(withDuration: 1) {
            self.view.window?.frame.origin.y = (-self.originalKeyBoardHeight! + 40)
        }
        self.scrollToBottom();
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("view가 사라지기 전 (viewWillDisappear)")
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("view가 사라짐 (viewDidDisappear)")
        
        sendCurrentState_out();
        disconnect();
        
    }
    
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
        
    }
    
    
    
    @IBAction func openOptionButton(_ sender: Any) {
        let alert = self.storyboard?.instantiateViewController(withIdentifier: "ChattingRoomMenuDialogViewController") as! ChattingRoomMenuDialogViewController
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        alert.roomModel = self.roomModel;
        alert.userId = myModel.userId;
        alert.exitDelegate = self;
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func sendMeesageButton(_ sender: Any) {
        sendMessage();
    }
    
    
    func enterInMessage(){
        
        
        let nowDate = Date()
        let todayDateFormatter = DateFormatter()
        todayDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        todayDateFormatter.locale = Locale(identifier:"ko_KR")
        let today = todayDateFormatter.string(from: nowDate)
        
        let conversationDateFormatter = DateFormatter()
        conversationDateFormatter.locale = Locale(identifier:"ko_KR")
        conversationDateFormatter.dateFormat = "aa HH:mm";
        let conversationTimeFormat = conversationDateFormatter.string(from: nowDate);
        
                
        let payloadObject : [String : Any] =
        
        [
            "userToken" : myModel.firebaseToken,
            "room_Uuid": roomModel["room_Uuid"]!,
            "room_Index" : roomModel["room_Index"]!,
            "userId" : myModel.userId,
            "userImage" :
                myModel.userMainPhoto,
            "userConversationTime" :conversationTimeFormat,
            "currentActualTime" : today,
            "actualTime" :  nowDate.timeIntervalSinceNow,
            "userMessageType" : "ENTER",
        ];
        
        
        socketClient.sendJSONForDict(
            dict: payloadObject as AnyObject,
            toDestination: "/comingIn/messageShare")
    }
    
    
    
    func sendCurrentState_in(){
        
        
        let nowDate = Date()
        let todayDateFormatter = DateFormatter()
        todayDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        todayDateFormatter.locale = Locale(identifier:"ko_KR")
        let today = todayDateFormatter.string(from: nowDate)
        
        let conversationDateFormatter = DateFormatter()
        conversationDateFormatter.locale = Locale(identifier:"ko_KR")
        conversationDateFormatter.dateFormat = "aa HH:mm";
        let conversationTimeFormat = conversationDateFormatter.string(from: nowDate);
        
        
        let payloadObject : [String : Any] =
        
        [
            "room_Uuid": roomModel["room_Uuid"]!,
            "room_Index" : roomModel["room_Index"]!,
            "userId" : myModel.userId,
            "currentState"  : "IN",
            "currentActualTime" : today,
            "actualTime" :  nowDate.timeIntervalSinceNow,
        ];
        
        
        socketClient.sendJSONForDict(
            dict: payloadObject as AnyObject,
            toDestination: "/comingIn/updateCurrentState")
        
        
    }
    
    
    func sendCurrentState_out(){
        
        
        let nowDate = Date()
        let todayDateFormatter = DateFormatter()
        todayDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        todayDateFormatter.locale = Locale(identifier:"ko_KR")
        let today = todayDateFormatter.string(from: nowDate)
        
        let conversationDateFormatter = DateFormatter()
        conversationDateFormatter.locale = Locale(identifier:"ko_KR")
        conversationDateFormatter.dateFormat = "aa HH:mm";
        let conversationTimeFormat = conversationDateFormatter.string(from: nowDate);
        
        
        let payloadObject : [String : Any] =
        
        [
            "room_Uuid": roomModel["room_Uuid"]!,
            "room_Index" : roomModel["room_Index"]!,
            "userId" : myModel.userId,
            "currentState"  : "OUT",
            "currentActualTime" : today,
            "actualTime" :  nowDate.timeIntervalSinceNow,
        ];
        
        
        socketClient.sendJSONForDict(
            dict: payloadObject as AnyObject,
            toDestination: "/comingIn/updateCurrentState")
        
        
    }
    
    func sendMessage() {
        let nowDate = Date()
        let todayDateFormatter = DateFormatter()
        todayDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        todayDateFormatter.locale = Locale(identifier:"ko_KR")
        let today = todayDateFormatter.string(from: nowDate)
        
        let conversationDateFormatter = DateFormatter()
        conversationDateFormatter.locale = Locale(identifier:"ko_KR")
        conversationDateFormatter.dateFormat = "aa HH:mm";
        let conversationTimeFormat = conversationDateFormatter.string(from: nowDate);
        
        let payloadObject : [String : Any] =
        [
            "userToken" : myModel.firebaseToken,
            "room_Uuid": roomModel["room_Uuid"]!,
            "room_Index" : roomModel["room_Index"]!,
            "userId" : myModel.userId,
            "currentState"  : "IN",
            "userJoinCount" : roomModel["room_JoinCount"]!,
            "userImage" :
                myModel.userMainPhoto,
            "userConversation" : messageTextField.text! as Any,
            "userConversationTime" :conversationTimeFormat,
            "currentActualTime" : today,
            "actualTime" :  nowDate.timeIntervalSinceNow,
            "userMessageType" : "CONVERSATION",
        ];
        
        
        socketClient.sendJSONForDict(
            dict: payloadObject as AnyObject,
            toDestination: "/comingIn/messageShare")
        
        self.chattingTableView.reloadData()
        messageTextField.text = "";
    }
    
    
    func registerSockect() {
        
        socketClient.openSocketWithURLRequest(request: NSURLRequest(url: url! as URL), delegate: self)
    }
    
    func subscribe() {
        socketClient.subscribe(destination: "/send/inAndOut/\(roomModel["room_Index"]!)")
        
        
        
        socketClient.subscribe(destination: "/send/chatting/\(roomModel["room_Index"]!)")
        
        
        enterInMessage();
        sendCurrentState_in();
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
                self.chattingTableView.reloadData()
                self.scrollToBottom();
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
                
                self.chattingTableView.reloadData()
                
            } catch let err {
                print(err.localizedDescription)
            }
            
        }
    }
    
}




extension CustomChattingViewController : UITableViewDelegate , UITableViewDataSource,UITableViewDataSourcePrefetching {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatsArray.count
    }
    
    func prefetchCellData(_ indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: indexPath.row, section: 0) // 로드할 인덱스 패스
        }
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            
            print("prefetchRowsAt \(indexPath.row)")
            self.prefetchCellData(indexPath)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            print("cancelPrefetchingForRowsAt \(indexPath.row)")
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let chatItem = chatsArray[indexPath.item]
        
        
        if(chatItem.userMessageType == "ENTER"
           && chatItem.userState == "IN"){
            
            guard let chattingOtherCell = tableView.dequeueReusableCell(withIdentifier: "ChattingOtherCell", for: indexPath) as? ChattingOtherCell else {
                return UITableViewCell();
            }
            
            
            chattingOtherCell.otherLabel.text = chatItem.userConversation;
            
            
            
            return chattingOtherCell;
            
            
            
        }else if(chatItem.userMessageType == "EXIT"
                 && chatItem.userState == "OUT"){
            
            guard let chattingOtherCell = tableView.dequeueReusableCell(withIdentifier: "ChattingOtherCell", for: indexPath) as? ChattingOtherCell else {
                return UITableViewCell();
            }
            
            
            chattingOtherCell.otherLabel.text = chatItem.userConversation;
            
            
            return chattingOtherCell;
            
        }else if(chatItem.userMessageType == "CONVERSATION"){
            
            
            if(chatItem.userId != self.userId){
                
                guard let chattingYouCell = tableView.dequeueReusableCell(withIdentifier: "ChattingYouCell", for: indexPath) as? ChattingYouCell else {
                    return UITableViewCell();
                }
                
                chattingYouCell.videoView.isHidden = true;
                chattingYouCell.fileView.isHidden = true;
                chattingYouCell.conversationView.isHidden = false;
                
                
                
                
                let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/userController/profileImageShow?imageName=\(chatItem.userImage!)");
                
                
                chattingYouCell.userIdLabel.text = chatItem.userId
                chattingYouCell.personImageView.layer.borderColor = UIColor.clear.cgColor
                chattingYouCell.personImageView.clipsToBounds = true
                chattingYouCell.personImageView.layer.cornerRadius = chattingYouCell.personImageView.frame.height/2
                chattingYouCell.personImageView?.kf.indicatorType = .activity
                chattingYouCell.personImageView?.kf.setImage(
                    with: url,
                    placeholder: nil,
                    options: [
                        .retryStrategy(retryStrategy),
                        .transition(.fade(1.2)),
                        .forceTransition,
                        .processor(cornerImageProcessor)
                    ],
                    completionHandler: nil)
                
                
                if(chatItem.userConversation == ""){
                    chattingYouCell.conversationView.isHidden = true;
                }else{
                    chattingYouCell.conversationView.isHidden = false;
                    chattingYouCell.conversationLabel.text = chatItem.userConversation
                    
                }
                
                
                
                chattingYouCell.conversationTimeLabel.text = chatItem.userConversationTime
                chattingYouCell.fileTimeLabel.text = chatItem.userConversationTime
                chattingYouCell.videoTimeLabel.text = chatItem.userConversationTime
                
                
                
                
                
                if(chatItem.chatting_ImageFile != nil && chatItem.chatting_ImageFile != "null"){
                    
                    chattingYouCell.fileView.isHidden = false;
                    chattingYouCell.conversationView.isHidden = true;
                    
                    let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/userController/profileImageShow?imageName=\(chatItem.chatting_ImageFile!)");
                    
                    chattingYouCell.fileImageView.isUserInteractionEnabled = true
                    let tappy = MyTapGesture(target: self, action: #selector(self.zoomImageTapped))
                    chattingYouCell.fileImageView.addGestureRecognizer(tappy)
                    tappy.imageUrl = url;
                    
                    
                    
                    chattingYouCell.fileImageView.layer.borderColor = UIColor.clear.cgColor
                    chattingYouCell.fileImageView.clipsToBounds = true
                    chattingYouCell.fileImageView.layer.cornerRadius = 20
                    chattingYouCell.fileImageView?.kf.indicatorType = .activity
                    chattingYouCell.fileImageView?.kf.setImage(
                        with: url,
                        placeholder: nil,
                        options: [
                            .retryStrategy(retryStrategy),
                            .transition(.fade(1.2)),
                            .forceTransition,
                            .processor(cornerImageProcessor)
                        ],
                        completionHandler: nil)
                    
                }
                
                
                if(chatItem.chatting_VideoFile != nil && chatItem.chatting_VideoFile != "null"){
                    
                    chattingYouCell.videoView.isHidden = false;
                    chattingYouCell.conversationView.isHidden = true;
                    
                    guard let videoUrl = URL(string: "http://ply2782ply2782.cafe24.com:8080/videoController/videoThumbNail?imageName=\(chatItem.chatting_VideoFile!)") else { return UITableViewCell() }
                    
                    
                    chattingYouCell.videoThumbNailImageView.isUserInteractionEnabled = true
                    let tappy = MyTapGesture(target: self, action: #selector(self.videoTapped))
                    chattingYouCell.videoThumbNailImageView.addGestureRecognizer(tappy)
                    tappy.videoUrl = videoUrl
                    
                    
                    
                    
                    chattingYouCell.videoThumbNailImageView.layer.borderColor = UIColor.clear.cgColor
                    chattingYouCell.videoThumbNailImageView.clipsToBounds = true
                    chattingYouCell.videoThumbNailImageView.layer.cornerRadius = 20
                    chattingYouCell.videoThumbNailImageView?.kf.indicatorType = .activity
                    chattingYouCell.videoThumbNailImageView.kf.setImage(with: AVAssetImageDataProvider(assetURL: videoUrl, seconds: 1))
                }
                
                
                
                return chattingYouCell;
                
                
            }else{
                
                guard let chattingMeCell = tableView.dequeueReusableCell(withIdentifier: "ChattingMeCell", for: indexPath) as? ChattingMeCell else {
                    return UITableViewCell();
                }
                
                
                
                chattingMeCell.videoView.isHidden = true;
                chattingMeCell.fileView.isHidden = true;
                chattingMeCell.conversationView.isHidden = false;
                
                
                if(chatItem.userConversation == ""){
                    chattingMeCell.conversationView.isHidden = true;
                }else{
                    chattingMeCell.conversationView.isHidden = false;
                    chattingMeCell.conversationLabel.text = chatItem.userConversation
                }
                
                
                
                
                chattingMeCell.conversationTimeLabel.text = chatItem.userConversationTime
                chattingMeCell.fileTimeLabel.text = chatItem.userConversationTime
                chattingMeCell.videoTimeLabel.text = chatItem.userConversationTime
                
                
                if(chatItem.chatting_ImageFile != nil && chatItem.chatting_ImageFile != "null"){
                    
                    chattingMeCell.fileView.isHidden = false;
                    chattingMeCell.fileTimeLabel.isHidden = false;
                    chattingMeCell.conversationLabelView.isHidden = true;
                    chattingMeCell.conversationTimeLabel.isHidden = true;
                    
                    
                    let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/userController/profileImageShow?imageName=\(chatItem.chatting_ImageFile!)");
                    
                    chattingMeCell.fileImageView.isUserInteractionEnabled = true
                    let tappy = MyTapGesture(target: self, action: #selector(self.zoomImageTapped))
                    chattingMeCell.fileImageView.addGestureRecognizer(tappy)
                    tappy.imageUrl = url;
                    
                    
                    chattingMeCell.fileImageView.layer.borderColor = UIColor.clear.cgColor
                    chattingMeCell.fileImageView.clipsToBounds = true
                    chattingMeCell.fileImageView.layer.cornerRadius = 20
                    chattingMeCell.fileImageView?.kf.indicatorType = .activity
                    chattingMeCell.fileImageView?.kf.setImage(
                        with: url,
                        placeholder: nil,
                        options: [
                            .retryStrategy(retryStrategy),
                            .transition(.fade(1.2)),
                            .forceTransition,
                            .processor(cornerImageProcessor)
                        ],
                        completionHandler: nil)
                    
                }
                
                
                
                
                if(chatItem.chatting_VideoFile != nil && chatItem.chatting_VideoFile != "null"){
                    
                    chattingMeCell.videoView.isHidden = false;
                    chattingMeCell.conversationView.isHidden = true;
                    
                    guard let videoUrl = URL(string: "http://ply2782ply2782.cafe24.com:8080/videoController/videoThumbNail?imageName=\(chatItem.chatting_VideoFile!)") else { return UITableViewCell() }
                    
                    
                    chattingMeCell.videoThumbNailImageView.isUserInteractionEnabled = true
                    let tappy = MyTapGesture(target: self, action: #selector(self.videoTapped))
                    chattingMeCell.videoThumbNailImageView.addGestureRecognizer(tappy)
                    tappy.videoUrl = videoUrl
                    
                    
                    
                    
                    chattingMeCell.videoThumbNailImageView.layer.borderColor = UIColor.clear.cgColor
                    chattingMeCell.videoThumbNailImageView.clipsToBounds = true
                    chattingMeCell.videoThumbNailImageView.layer.cornerRadius = 20
                    chattingMeCell.videoThumbNailImageView?.kf.indicatorType = .activity
                    chattingMeCell.videoThumbNailImageView.kf.setImage(with: AVAssetImageDataProvider(assetURL: videoUrl, seconds: 1))
                }
                
                
                return chattingMeCell;
            }
        }
        return UITableViewCell();
    }
    
    
}

class MyTapGesture: UITapGestureRecognizer {
    var videoUrl = URL(string: "")
    var imageUrl = URL(string: "")
}

extension CustomChattingViewController : StompClientLibDelegate{
    
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
                self.chattingTableView.reloadData()
                self.scrollToBottom();
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



extension CustomChattingViewController : UIImagePickerControllerDelegate,
                                         UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
        
        
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("image \(image)");
            updateProfileImage(image);
        }else if let video = info[UIImagePickerController.InfoKey.mediaURL] {
            print("video \(video)");
            updateVideoImage(video as! URL);
        }
        photo.dismiss(animated: true, completion: nil) //dismiss를 직접 해야함
    }
}
