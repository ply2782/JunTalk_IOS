//
//  ProfileViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/05/01.
//

import UIKit
import Alamofire



protocol UpdateProtocal{
    
    func updateInfo();
}


class ProfileViewController: UIViewController , UpdateProtocal {
    
    func updateInfo() {
        getMyModel(userKakaoOwnNumber: myModel.userKakaoOwnNumber)
    }
    
    
    
    var myModel : UserData!;
    var updateProtocalDelegate : UpdateProtocal!;
    @IBOutlet var updateMyInfoButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var introduceTextView: UITextView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    var personImageViewUrl :String?
    var nickNameString : String?
    var introduceString : String?
    var last_Login : String?
    var userBirthday : String?
    var userIndex : Int?
    var myMainPhoto : String?
    var personUserToken : String?
    var myId : String?
    var myIndex : Int?
    var isHost: Bool = false;
    let nameList = ["# 정보", "# 게시물", "# 채팅" , "# Junes"];
    var isHiddenBoolean = true;
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let data = UserDefaults.standard.object(forKey: "myModel")
        if(data != nil){
            let decoder = JSONDecoder()
            self.myModel = try? decoder.decode(UserData.self, from: data as! Data)
        }
        
        updateProtocalDelegate = self;
        if(isHost){
            updateMyInfoButton.isHidden = false;
        }else{
            updateMyInfoButton.isHidden = true;
        }
        
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
                let user_Introduce = response.value!.user_Introduce as Any;
                
                let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/userController/profileImageShow?imageName=\(userMainPhoto)");
                
                self.personImageView.load(url: url!)
                self.nickNameLabel.text = userId as? String
                self.introduceTextView.text = user_Introduce as? String;
                return
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    
    @IBAction func menuClick(_ sender: Any) {
        if(isHiddenBoolean == true){
            self.collectionView.layer.isHidden = true;
            isHiddenBoolean = false;
        }else{
            self.collectionView.layer.isHidden = false;
            isHiddenBoolean = true;
        }
        
        
    }
    func settingCollectionView(){
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("view가 화면에 나타남 (viewDidAppear)")
        settingCollectionView();
        settingMyPicImage();
        settingNickNameLabel();
        settingIntroduceTextView();
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updateMyInfoSegue"{
            if let destination = segue.destination as?
                UpdateInfoPopUpViewController {
                destination.myIndex = myIndex;
                destination.myId = myId;
                destination.myStatus = introduceString;
                destination.updateProtocalDelegate = self.updateProtocalDelegate;
            }
        }
    }
    
    func correctAges(dict: Dictionary<String,Any> , room_Index : Int? , room_Uuid  : String? )-> Dictionary<String,Any> {
        
        var mutatedDict = dict
        for (key,  value) in mutatedDict {
            if(key == "room_Uuid"){
                mutatedDict[key] = room_Uuid!
                mutatedDict["room_Index"] = room_Index!
            }
        }
        return mutatedDict
    }
    
    func settingMyPicImage(){
        
        let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/userController/profileImageShow?imageName=\(personImageViewUrl!)");
        
        personImageView.layer.cornerRadius = personImageView.frame.height/2
        personImageView.layer.borderWidth = 1
        personImageView.layer.borderColor = UIColor.clear.cgColor
        personImageView.clipsToBounds = true
        personImageView.load(url: url!)
    }
    
    func settingNickNameLabel(){
        nickNameLabel.text = nickNameString!
        nickNameLabel.textAlignment = .center
    }
    
    func settingIntroduceTextView(){
        introduceTextView.text = introduceString!
        introduceTextView.textAlignment = .center
        if(introduceString! == "null"){
            introduceTextView.isHidden = true;
        }else{
            introduceTextView.isHidden = false;
        }
    }
    
    @IBAction func closeViewController(_ sender: Any) {
        print("closeClick");
        dismiss(animated: true, completion: nil)
        
    }
    
    
    func createRoomList(type:String? , model : Dictionary<String,Any>  ){
        
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/roomController/createRoomList";
        
        
        let param: Parameters =
        [
            "roomType" : "P",
            "room_JoinPeopleName" : model["room_JoinPeopleName"]!,
            "room_RegDate" : model["room_RegDate"]!,
            "room_Uuid" : model["room_Uuid"]!,
            "otherUserId" : model["otherUserId"]!,
            "toUser" : model["toUser"]!,
            "fromUser" : model["fromUser"]!,
        ];
        
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).response{ response in switch response.result {
            
        case .success:
            
            do{
                
                if let jsonData = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? Dictionary<String,Any> {
                    
                    let room_Index = jsonData["room_Index"]!;
                    let room_Uuid = jsonData["room_Uuid"]!;
                    
                    
                    let newModel = self.correctAges(dict: model, room_Index: Int(room_Index as! String)!, room_Uuid: room_Uuid as! String);
                    
                    NotificationCenter.default.post(name:.chattingRefresh, object: nil)
                    
                    let alert = self.storyboard?.instantiateViewController(withIdentifier: "CustomChattingViewController") as! CustomChattingViewController
                    alert.modalPresentationStyle = .overCurrentContext
                    alert.modalTransitionStyle = .crossDissolve
                    alert.roomModel = newModel;
                    alert.userId = model["fromUser"] as! String;
                    self.present(alert, animated: false, completion: nil)

                    
                    
                }else{
                    print("bad Json");
                }
                
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
}



class InfoClass : UICollectionViewCell{
    
    @IBOutlet weak var cellLabel: UILabel!
    
}




extension ProfileViewController : UICollectionViewDelegate{
    // collectionView(_:didSelectItemAt:) : 지정된 셀이 선택되었음을 알리는 메서드
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        print("indexPath : \(indexPath.row)");
        
        switch indexPath.row {
            
        case 0 :
            let alert = UIAlertController(title: "# 정보창", message: "아이디 : \(nickNameString!) \n\n생일 \(userBirthday!) \n\n최근 로그인 : \(last_Login!)", preferredStyle: .actionSheet)
            alert.view.tintColor =  UIColor(ciColor: .black)
            let alertAction = UIAlertAction(title: "확인", style: .default) { (_) in
            }
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
            
            break;
        case 1 :
            
            let alert = self.storyboard?.instantiateViewController(withIdentifier: "UserBulletinBoardViewController") as! UserBulletinBoardViewController
            alert.modalPresentationStyle = .overCurrentContext
            alert.modalTransitionStyle = .crossDissolve
            alert.personUserId = nickNameString!
            as! String;
            alert.personUserIndex = userIndex!
            alert.myId = self.myId;
            alert.myIndex = self.myIndex;
            self.present(alert, animated: false, completion: nil)
            
            break;
        case 2 :
            
            if(isHost){
                
                
                let alert = UIAlertController(title: "# 정보창", message: "서비스 준비중입니다..", preferredStyle: .actionSheet)
                alert.view.tintColor =  UIColor(ciColor: .black)
                let alertAction = UIAlertAction(title: "확인", style: .default) { (_) in
                }
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
                
                
            }else{
                
                var roomModel : Dictionary<String,Any> = [:];
                let nowDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd (E) aa HH시 mm분"
                let today = dateFormatter.string(from: nowDate)
                roomModel["room_Uuid"] = UUID().uuidString;
                roomModel["room_JoinPeopleName"] = myId!;
                roomModel["room_JoinPeopleImage"] = myMainPhoto;
                roomModel["room_RegDate"] = today;
                roomModel["otherUserId"] = nickNameString!;
                roomModel["userToken"] = personUserToken;
                roomModel["fromUser"] = myId!;
                roomModel["toUser"] = nickNameString!
                roomModel["room_JoinCount"] = 1
                self.createRoomList(type: "P", model: roomModel);
                
            }
            
            break;
        case 3 :
            
            let alert = self.storyboard?.instantiateViewController(withIdentifier: "ReelsViewController") as! ReelsViewController
            alert.modalPresentationStyle = .overCurrentContext
            alert.modalTransitionStyle = .crossDissolve
            alert.userId = myId!;
            alert.user_Index = myIndex!;
            self.present(alert, animated: false, completion: nil)
            break;
            
        default:
            break;
        }
    }
    
}

extension ProfileViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemSpacing: CGFloat = 10 // 가로에서 cell과 cell 사이의 거리
        let textAreaHeight: CGFloat = 15 // textLabel이 차지하는 높이
        let width: CGFloat = (collectionView.bounds.width - itemSpacing)/2
        let height: CGFloat = (collectionView.bounds.height - itemSpacing)/2
        
        return CGSize(width: width, height: height)
    }
}



extension ProfileViewController : UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nameList.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let InfoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoCell", for: indexPath) as? InfoClass else {
            return UICollectionViewCell()
        }
        
        
        InfoCell.cellLabel.text = nameList[indexPath.row];
        
        return InfoCell
    }
    
    
    
}
