//
//  InViteDialogViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/07/04.
//

import UIKit
import Alamofire
import Kingfisher


protocol ClickIndexProtocal{
    func clickIndex(index : Int?);
}

class InViteDialogViewController: UIViewController , ClickIndexProtocal {
    
    
    func clickIndex(index: Int?) {
        
        clickIndex = index!;
    }
    
    var myModel : UserData!;
    var clickIndex : Int? = 0;
    var clickIndexProtocalDelegate : ClickIndexProtocal!;
    @IBOutlet weak var inViteTableView: UITableView!
    var currentJoinListArray : [Dictionary<String,Any>] = [];
    let cornerImageProcessor = RoundCornerImageProcessor(cornerRadius: 30)
    let retryStrategy = DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(3))
    var room_Index : Int? = 0;
    var room_Uuid : String? = "";
    var userId : String? = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let data = UserDefaults.standard.object(forKey: "myModel")
        if(data != nil){
            let decoder = JSONDecoder()
            self.myModel = try? decoder.decode(UserData.self, from: data as! Data)
        }
        clickIndexProtocalDelegate = self;
        self.inViteTableView.dataSource = self;
        self.inViteTableView.delegate = self;
        loadCurrentJoinListUser(room_Uuid: room_Uuid, userId: userId);
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        self.view.endEditing(true)
        self.dismiss(animated: true);
    }
    
    @IBAction func inviteAction(_ sender: Any) {
        
        inviteApi();
    }
    
    
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0)) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    
    
    
    func inviteApi(){
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/roomController/addFriendInRoom"
        
        
        let joinListItem = self.currentJoinListArray[self.clickIndex!];
        
        let nowDate = Date()
        let todayDateFormatter = DateFormatter()
        todayDateFormatter.dateFormat = "yy/MM/dd (E) aa HH:mm"
        todayDateFormatter.locale = Locale(identifier:"ko_KR")
        let today = todayDateFormatter.string(from: nowDate)
        
        let param: Parameters = [
            "roomType": "P",
            "myMainPhoto": myModel.userMainPhoto,
            "userId" : joinListItem["userId"] as Any,
            "fireBaseToken" : joinListItem["fireBaseToken"] as Any,
            "fromUser" : myModel.userId,
            "toUser" : joinListItem["userId"] as Any,
            "userState" : "NULL",
            "room_Index" : room_Index as Any,
            "friend_Index" : myModel.user_Index,
            "friendId" : myModel.userId,
            "room_Uuid" : room_Uuid as Any,
            "userKakaoOwnNumber" : joinListItem["userKakaoOwnNumber"] as Any,
            "userMainPhoto" : joinListItem["userMainPhoto"] as Any,
            "notice_RegDate" : today,
            
        ];
        
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).response {
            response in
            switch response.result {
            case .success:
                self.showToast(message: "초대가 완료되었습니다.");
                self.dismiss(animated: true);
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    func loadCurrentJoinListUser(room_Uuid : String? , userId : String?){
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/roomController/currentRoomJoinPeopleList"
        
        let param: Parameters = [
            "room_Uuid": room_Uuid! as Any,
            "userId": userId! as Any
        ];
        
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).response{ response in
            switch response.result {
            case .success:
                do{
                    if let jsonArray = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [Dictionary<String,Any>] {
                        for item in jsonArray{
                            self.currentJoinListArray.append(item);
                        }
                        self.inViteTableView.reloadData()
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

class WaitingForInvitedList : UITableViewCell{
    
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    
}

extension InViteDialogViewController : UITableViewDelegate  , UITableViewDataSource{
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        clickIndexProtocalDelegate.clickIndex(index: indexPath.row);
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentJoinListArray.count
    }
    
    func prefetchCellData(_ indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: indexPath.row, section: 0) // 로드할 인덱스 패스
        }
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            
            print("prefetchRowsAt \(indexPath.row)")
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            print("cancelPrefetchingForRowsAt \(indexPath.row)")
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let joinListItem = self.currentJoinListArray[indexPath.item]
        
        guard let waitingForInvitedPersonListCell = tableView.dequeueReusableCell(withIdentifier: "WaitingForInvitedList", for: indexPath) as? WaitingForInvitedList else {
            return UITableViewCell();
        }
        
        waitingForInvitedPersonListCell.nickNameLabel.text = joinListItem["userId"] as! String
        
        
        let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/userController/profileImageShow?imageName=\(joinListItem["userMainPhoto"] as! String)");
        
        waitingForInvitedPersonListCell.personImageView.layer.borderColor = UIColor.clear.cgColor
        waitingForInvitedPersonListCell.personImageView.clipsToBounds = true
        waitingForInvitedPersonListCell.personImageView.layer.cornerRadius = waitingForInvitedPersonListCell.personImageView.frame.height/2
        waitingForInvitedPersonListCell.personImageView?.kf.indicatorType = .activity
        waitingForInvitedPersonListCell.personImageView?.kf.setImage(
            with: url,
            placeholder: nil,
            options: [
                .retryStrategy(retryStrategy),
                .transition(.fade(1.2)),
                .forceTransition,
                .processor(cornerImageProcessor)
            ],
            completionHandler: nil)
        
        return waitingForInvitedPersonListCell;
    }
}
