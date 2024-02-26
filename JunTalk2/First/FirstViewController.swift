//
//  TestFirstViewViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/06/25.
//

import UIKit
import Alamofire
import SwiftyJSON
import Lottie
import CoreData
import Kingfisher
import KakaoSDKAuth
import KakaoSDKUser


extension Notification.Name {
    static let mainRefresh = Notification.Name("mainRefresh");
    static let logOutRefresh = Notification.Name("logOutRefresh");
    static let joinOutRefresh = Notification.Name("joinOutRefresh");
}



protocol ClickProtocal{
    func clickItems(at index:IndexPath)
}

protocol DeliverData {
    func deliverData(type:String);
}



class FirstViewController: UIViewController, DeliverData {
    
    func deliverData(type: String) {
        print("type \(type)");
    }
    
    
    @IBOutlet var myOptionImageView: UIImageView!
    
    @IBOutlet weak var birthDayCollectionView: UICollectionView!
    @IBOutlet weak var uploadCollectionView: UICollectionView!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var friendListTableView: UITableView!
    
    
    
    @IBOutlet weak var uploadView: UIView!
    @IBOutlet weak var birthdayView: UIView!
    @IBOutlet weak var wholeViewHeight: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var noticeImageView: UIImageView!
    @IBOutlet weak var myNickNameLabel: UILabel!
    @IBOutlet weak var myPictureImageView: UIImageView!
    
    var container : NSPersistentContainer!
    var formatter = DateFormatter();
    
    var mainFriendArrayCopy : [Dictionary<String,Any>] = [];
    var todayUploadArrayCopy :[Dictionary<String,Any>] = [];
    var birthDayArrayCopy :[Dictionary<String,Any>] = [];
    
    
    var deliverDelegate : DeliverData?
    let cornerImageProcessor = RoundCornerImageProcessor(cornerRadius: 20)
    let retryStrategy = DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(3))
    let myUserDefaults = UserDefaults.standard;
    var myModel : UserData!;
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNotification), name: .mainRefresh, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(logOutRefreshNotification), name: .logOutRefresh, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(joinOutRefreshNotification), name: .joinOutRefresh, object: nil)
        
        
        let data = UserDefaults.standard.object(forKey: "myModel")
        if(data != nil){
            let decoder = JSONDecoder()
            self.myModel = try? decoder.decode(UserData.self, from: data as! Data)
        }
        
        getMyModel(userKakaoOwnNumber: self.myModel.userKakaoOwnNumber);
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        let current_date_string = formatter.string(from: Date())
        mainList(_userKakaoOwnNumber: self.myModel.userKakaoOwnNumber, _today: current_date_string, _category: "pray")
        let appDeletegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDeletegate.persistentContainer;
        
        
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(imageTapped))
        self.noticeImageView.isUserInteractionEnabled = true
        self.noticeImageView.addGestureRecognizer(tapGestureRecognizer)
        
        
        let tapGestureRecognizer2 = UITapGestureRecognizer(target:self, action:#selector(myOptionImageButton))
        self.myOptionImageView.isUserInteractionEnabled = true
        self.myOptionImageView.addGestureRecognizer(tapGestureRecognizer2)
        
        settingMyPicImage();
        
    }
    
    
    
    func deleteAccount(userKakaoOwnNumber : Int? ){
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/userController/deleteAccount";
        
        let param: Parameters =
        [
            "userKakaoOwnNumber" : userKakaoOwnNumber as! Any,
        ];
        
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).response{ response in switch response.result {
        case .success:
            
            do{
                
                let alert = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                alert.modalPresentationStyle = .overCurrentContext
                alert.modalTransitionStyle = .crossDissolve
                self.present(alert, animated: false, completion: nil)
                
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
    
    
    
    @objc func joinOutRefreshNotification() {
        let alert = UIAlertController(title: "# 회원탈퇴", message: "정말 회원탈퇴 하시겠습니까?", preferredStyle: .alert)
        alert.view.tintColor =  UIColor(ciColor: .black)
        let alertAction = UIAlertAction(title: "확인", style: .default) { (_) in
            
            self.deleteAccount(userKakaoOwnNumber: self.myModel.userKakaoOwnNumber);
        }
        alert.addAction(alertAction)
        let cancle = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(cancle)
        
    }
    
    
    
    @objc func logOutRefreshNotification() {
        UserApi.shared.unlink {(error) in
            if let error = error {
                print(error)
            } else {
                print("unlink() success.")
                
                let alert = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                alert.modalPresentationStyle = .overCurrentContext
                alert.modalTransitionStyle = .crossDissolve
                self.present(alert, animated: false, completion: nil)
                
            }
        }
        
    }
    
    
    @objc func refreshNotification() {
        getMyModel(userKakaoOwnNumber: self.myModel.userKakaoOwnNumber);
        
    }
    
    
    
    
    @objc private func myOptionImageButton() {
        
        let userId = self.myModel.userId
        let userMainPhoto = self.myModel.userMainPhoto;
        let user_Introduce = self.myModel.user_Introduce
        let userBirthday = self.myModel.userBirthDay
        let user_lastLogin = self.myModel.user_lastLogin
        let user_Index = self.myModel.user_Index;
        let myId = self.myModel.userId;
        let myIndex = self.myModel.user_Index;
        let myMainPhoto = self.myModel.userMainPhoto;
        let personUserToken = self.myModel.firebaseToken
        let isHost = true;
        
        let profileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileViewController.modalPresentationStyle = .overCurrentContext
        profileViewController.modalTransitionStyle = .crossDissolve
        profileViewController.nickNameString = userId;
        profileViewController.personImageViewUrl = userMainPhoto
        profileViewController.introduceString = user_Introduce
        profileViewController.userBirthday = userBirthday
        profileViewController.last_Login = user_lastLogin
        profileViewController.userIndex = user_Index
        profileViewController.myId = myId;
        profileViewController.myIndex = myIndex;
        profileViewController.myMainPhoto = myMainPhoto
        profileViewController.personUserToken = personUserToken
        profileViewController.isHost = isHost
        
        self.present(profileViewController, animated: false, completion: nil)
    }
    
    
    @objc private func imageTapped() {
        let noticeViewController = self.storyboard?.instantiateViewController(withIdentifier: "NoticeViewController") as! NoticeViewController
        noticeViewController.modalPresentationStyle = .overCurrentContext
        noticeViewController.modalTransitionStyle = .crossDissolve
        self.present(noticeViewController, animated: false, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view가 Load됨 (viewWillAppear)")
        
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
    }
    
    
    
    func getMyModel(userKakaoOwnNumber : Int?){
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/userController/isExistOfId";
        let param: Parameters =
        [
            "userKakaoOwnNumber": userKakaoOwnNumber! as Any,
        ];
        AF.request(
            apiURL,
            method: .get,
            parameters: param,
            headers: ["Content-Type":"application/json", "Accept":"application/json; charset=utf-8"])
        .validate(statusCode: 200..<300)
        .responseDecodable(of:UserData.self){ response in
            switch response.result {
            case .success:
                
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(response.value!)
                {
                    UserDefaults.standard.set(encoded, forKey: "myModel")
                }
                
                let userId = response.value!.userId as Any
                let userMainPhoto = response.value!.userMainPhoto as Any
                
                let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/userController/profileImageShow?imageName=\(userMainPhoto)");
                
                
                
                self.myPictureImageView.load(url: url!)
                self.myNickNameLabel.text = userId as? String
                
                let data = UserDefaults.standard.object(forKey: "myModel")
                if(data != nil){
                    let decoder = JSONDecoder()
                    self.myModel = try? decoder.decode(UserData.self, from: data as! Data)
                }
                
                return
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileSegue"{
            if let destination = segue.destination as?
                ProfileViewController {
                if let selectdeIndex =
                    self.friendListTableView.indexPathForSelectedRow?.row {
                    destination.nickNameString = mainFriendArrayCopy[selectdeIndex]["userId"] as? String;
                    
                    destination.personImageViewUrl =
                    mainFriendArrayCopy[selectdeIndex]["userMainPhoto"] as? String;
                    
                    destination.introduceString =
                    mainFriendArrayCopy[selectdeIndex]["user_Introduce"] as? String;
                    
                    destination.userBirthday = mainFriendArrayCopy[selectdeIndex]["userBirthDay"] as? String;
                    
                    destination.last_Login = mainFriendArrayCopy[selectdeIndex]["user_lastLogin"] as? String;
                    
                    destination.userIndex = mainFriendArrayCopy[selectdeIndex]["user_Index"] as? Int;
                    
                    destination.myId = self.myModel.userId;
                    destination.myIndex = self.myModel.user_Index;
                    destination.myMainPhoto = self.myModel.userMainPhoto;
                    
                    
                    destination.personUserToken = mainFriendArrayCopy[selectdeIndex]["userToken"] as? String;
                    
                    destination.isHost = self.myModel.user_Index == mainFriendArrayCopy[selectdeIndex]["user_Index"] as? Int ? true : false;
                }
            }
        } 
    }
    
    
    
    func settingMyPicImage(){
        self.friendListTableView.dataSource = self;
        self.friendListTableView.delegate = self;
        self.friendListTableView.tableFooterView = UIView(frame: .zero)
        
        self.uploadCollectionView.dataSource = self;
        self.uploadCollectionView.delegate = self;
        self.uploadCollectionView.alwaysBounceHorizontal = true;
        
        self.birthDayCollectionView.dataSource = self;
        self.birthDayCollectionView.delegate = self;
        self.birthDayCollectionView.alwaysBounceHorizontal = true;
        
        
        myPictureImageView.layer.cornerRadius = myPictureImageView.frame.height/2
        myPictureImageView.layer.borderWidth = 1
        myPictureImageView.layer.borderColor = UIColor.clear.cgColor
        myPictureImageView.clipsToBounds = true
    }
    
    
    
    func mainList(_userKakaoOwnNumber:Int? , _today : String? , _category : String?) {
        
        
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/userController/mainList";
        let param: Parameters =
        [
            "userKakaoOwnNumber": _userKakaoOwnNumber! as Any,
            "today" : _today! as Any,
            "category" : _category! as Any
        ];
        AF.request(
            apiURL,
            method: .get,
            parameters: param,
            headers: ["Content-Type":"application/json", "Accept":"application/json; charset=utf-8"])
        .validate(statusCode: 200..<300)
        .response{ response in
            switch response.result {
            case .success:
                let json = JSON(response.data!);
                
                self.mainFriendArrayCopy = [];
                self.todayUploadArrayCopy = [];
                self.birthDayArrayCopy = [] ;
                
                
                
                do{
                    let data = json["mainFriendModel"].stringValue.data(using: String.Encoding.utf8);
                    
                    if let jsonArray = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [Dictionary<String,Any>]
                    {
                        
                        for item in jsonArray{
                            self.mainFriendArrayCopy.append(item);
                        }
                        
                        
                    }else{
                        print("bad Json");
                    }
                    
                }catch(let error){
                    print("error : \(error)");
                }
                
                
                do{
                    let todayUploadData = json["userPrayRequestList"].stringValue.data(using: String.Encoding.utf8);
                    if let jsonArray = try JSONSerialization.jsonObject(with: todayUploadData!, options: .allowFragments) as? [Dictionary<String,Any>] {
                        
                        for item in jsonArray{
                            self.todayUploadArrayCopy.append(item);
                        }
                        
                    }else{
                        print("bad Json");
                    }
                }catch(let error){
                    print("error : \(error)");
                }
                
                
                
                
                do{
                    let birthDayData = json["friendBirthdayModel"].stringValue.data(using: String.Encoding.utf8);
                    if let jsonArray = try JSONSerialization.jsonObject(with: birthDayData!, options: .allowFragments) as? [Dictionary<String,Any>] {
                        
                        for item in jsonArray{
                            self.birthDayArrayCopy.append(item);
                        }
                        
                    }else{
                        print("bad Json");
                    }
                }catch(let error){
                    print("error : \(error)");
                }
                
                
                self.friendListTableView.reloadData();
                self.uploadCollectionView.reloadData();
                self.birthDayCollectionView.reloadData();
                
                
                let height = UIScreen.main.bounds.size.height
                self.tableViewHeight.constant = CGFloat(Int(self.mainFriendArrayCopy.count) * 118)
                
                self.wholeViewHeight.constant = self.tableViewHeight.constant
                
                self.friendListTableView.layer.backgroundColor = UIColor.white.cgColor;
                
                
                if(self.birthDayArrayCopy.count == 0){
                    self.birthdayView.isHidden = true;
                }else{
                    self.birthdayView.isHidden = false;
                }
                
                if(self.todayUploadArrayCopy.count == 0){
                    self.uploadView.isHidden = true;
                }else{
                    self.uploadView.isHidden = false;
                }
                
                
                
                return
            case .failure(let error):
                print(error)
                return
            }
        }
    }
}

class FriendListCell : UITableViewCell {
    
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var talkButton: UIButton!
    @IBOutlet weak var personNickNameLabel: UILabel!
    
    var delegate:ClickProtocal!
    var indexPath:IndexPath!
    
    
    @IBAction func blockPerson(_ sender: Any) {
        self.delegate?.clickItems(at: indexPath);
    }
    
    override func awakeFromNib(){
        super.awakeFromNib();
    }
    
    
    override func prepareForReuse() {
        self.personImageView.image = nil;
        self.personNickNameLabel.text = nil;
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
}

class UploadCell : UICollectionViewCell{
    
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var personNickNameLabel: UILabel!
    
    
    override func awakeFromNib(){
        super.awakeFromNib();
        
    }
    
    
    override func prepareForReuse() {
        self.personImageView.image = nil;
        self.personNickNameLabel.text = nil;
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}



class BirthDayPersonCell : UICollectionViewCell{
    
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var personNickNameLabel: UILabel!
    
    
    override func awakeFromNib(){
        super.awakeFromNib();
        
    }
    
    
    override func prepareForReuse() {
        self.personImageView.image = nil;
        self.personNickNameLabel.text = "";
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}





extension FirstViewController :  UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    
    
    // 선택 안한 부분 스타일 커스텀
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        
    }
    
    //  선택 한 부분 스타일 커스텀
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    // CollectionView item 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(collectionView == uploadCollectionView){
            
            return self.todayUploadArrayCopy.count;
            
        }else if(collectionView == birthDayCollectionView){
            
            return self.birthDayArrayCopy.count;
            
        }else{
            return 0;
        }
        
    }
    
    
    // CollectionView Cell의 Object
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == uploadCollectionView){
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UploadCell", for: indexPath) as? UploadCell else {
                return UICollectionViewCell()
            }
            let userMainPhoto = self.todayUploadArrayCopy[indexPath.row]["userMainPhoto"]! as Any;
            let nickname = self.todayUploadArrayCopy[indexPath.row]["userId"]! as Any;
            let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/userController/profileImageShow?imageName=\(userMainPhoto)");
            
            cell.personNickNameLabel.text = nickname as? String;
            cell.personNickNameLabel.sizeToFit();
            
            cell.personImageView.layer.borderColor = UIColor.clear.cgColor
            cell.personImageView.clipsToBounds = true
            cell.personImageView.layer.cornerRadius = cell.personImageView.frame.height/2
            cell.personImageView?.kf.indicatorType = .activity
            cell.personImageView?.kf.setImage(
                with: url,
                placeholder: nil,
                options: [
                    .retryStrategy(retryStrategy),
                    .transition(.fade(1.2)),
                    .forceTransition,
                    .processor(cornerImageProcessor)
                ],
                completionHandler: nil)
            
            
            
            return cell;
            
        }else if(collectionView == birthDayCollectionView){
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BirthDayPersonCell", for: indexPath) as? BirthDayPersonCell else {
                return UICollectionViewCell()
            }
            
            let userMainPhoto = self.birthDayArrayCopy[indexPath.row]["userMainPhoto"]! as Any;
            let nickname = self.birthDayArrayCopy[indexPath.row]["userId"]! as Any;
            let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/userController/profileImageShow?imageName=\(userMainPhoto)");
            
            cell.personNickNameLabel.text = nickname as? String;
            cell.personNickNameLabel.sizeToFit();
            
            cell.personImageView.layer.borderColor = UIColor.clear.cgColor
            cell.personImageView.clipsToBounds = true
            cell.personImageView.layer.cornerRadius = cell.personImageView.frame.height/2
            cell.personImageView?.kf.indicatorType = .activity
            cell.personImageView?.kf.setImage(
                with: url,
                placeholder: nil,
                options: [
                    .retryStrategy(retryStrategy),
                    .transition(.fade(1.2)),
                    .forceTransition,
                    .processor(cornerImageProcessor)
                ],
                completionHandler: nil)
            
            
            
            return cell;
            
        }else{
            
            return  UICollectionViewCell();
            
        }
        
        
    }
    
    
    
    
    // CollectionView Cell의 Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        return CGSize(width: 100, height: 100)
        
    }
    
    // CollectionView Cell의 위아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1.0
    }
    
    // CollectionView Cell의 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    
}


extension FirstViewController : UITableViewDelegate , UITableViewDataSource , ClickProtocal ,AddViewControllerDelegate{
    
    func willDissmiss() {
        print("willDissmiss");
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        let current_date_string = formatter.string(from: Date())
        mainList(_userKakaoOwnNumber: myModel.userKakaoOwnNumber, _today:current_date_string, _category: "pray")
    }
    
    
    func clickItems(at index: IndexPath) {
        let alert = self.storyboard?.instantiateViewController(withIdentifier: "BlockDialogViewController") as! BlockDialogViewController
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        alert.personUserId = self.mainFriendArrayCopy[index.row]["userId"]!
        as! String;
        alert.personUserIndex = self.mainFriendArrayCopy[index.row]["user_Index"]!
        as! Int;
        alert.deliverData(type: "asdasd");
        alert.delegate = self;
        self.present(alert, animated: false, completion: nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mainFriendArrayCopy.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let testCell = tableView.dequeueReusableCell(withIdentifier: "FriendListCell", for: indexPath) as? FriendListCell else {
            return UITableViewCell();
        }
        
        let userMainPhoto = self.mainFriendArrayCopy[indexPath.row]["userMainPhoto"]! as Any;
        let nickname = self.mainFriendArrayCopy[indexPath.row]["userId"]! as Any;
        let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/userController/profileImageShow?imageName=\(userMainPhoto)");
                
        testCell.personNickNameLabel.text = nickname as? String;
        testCell.personNickNameLabel.sizeToFit();
        testCell.personImageView.layer.borderColor = UIColor.clear.cgColor
        
        testCell.personImageView.clipsToBounds = true
        testCell.personImageView.layer.cornerRadius = testCell.personImageView.frame.height/2
        testCell.personImageView?.kf.indicatorType = .activity
        testCell.personImageView?.kf.setImage(
            with: url,
            placeholder: nil,
            options: [
                .retryStrategy(retryStrategy),
                .transition(.fade(1.2)),
                .forceTransition,
                .processor(cornerImageProcessor)
            ],
            completionHandler: nil)
        testCell.delegate = self
        testCell.indexPath = indexPath
        
        
        return testCell;
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100;
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("friendTableView indexPath.row \(indexPath.row)");
    }
    
}



extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async {
            [weak self] in if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
