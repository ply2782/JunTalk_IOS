//
//  CalendarDetailViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/08/04.
//

import UIKit
import Alamofire
import SwiftyJSON



extension Notification.Name {
    static let CalendarDetailViewControllerRefresh = Notification.Name("CalendarDetailViewControllerRefresh");
}

protocol ClickInterface{
    func isClick(clubItems : Dictionary<String,Any> );
}


class CalendarDetailViewController: UIViewController , ClickInterface {
    
    func isClick(clubItems : Dictionary<String,Any>  ) {
        let sheet = UIAlertController(title: "확인", message: "클럽에 참여하시겠습니까?", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "확인", style: .destructive, handler: { _ in self.joinClub(clubItems: clubItems); }))
        
        sheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(sheet, animated: true)
    }
    
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var clubListTableView: UITableView!
    var clubList : [Dictionary<String,Any>] = [];
    let numberFormatter = NumberFormatter()
    var user_Index : Int = 0;
    var currentDate :String = "";
    var myModel : UserData!;
    var clickDelegaate : ClickInterface!
    
    
    func joinClub(clubItems : Dictionary<String,Any>){
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/clubController/joinClub";
        
        let param: Parameters =
        [
            "userKakaoOwnNumber" : myModel.userKakaoOwnNumber,
            "user_Index" : myModel.user_Index,
            "userId" : myModel.userId,
            "owner_Index" : clubItems["user_Index"]!,
            "ownerId" : clubItems["userId"]!,
            "club_Uuid" : clubItems["club_Uuid"]!,
            "requestResult" : "N",
            "club_Index" : clubItems["club_Index"]!,
            "userMainPhoto" : myModel.userMainPhoto
        ];
        
        
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).response{ response in switch response.result {
        case .success:
            print("success");
            return
        case .failure(let error):
            print(error)
            return
        }
        }
    }
    
    
    
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        
        return control
    }()
    
    @objc func refreshTableView(){
        clubList.removeAll()
        print("currentDate \(currentDate)");
        getChattingList(user_Index: user_Index, currentDate: currentDate);
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clickDelegaate = self;
        numberFormatter.numberStyle = .decimal
        self.clubListTableView.dataSource = self;
        self.clubListTableView.delegate  = self;
        clubListTableView.refreshControl = refreshControl;
        self.clubListTableView.register(UINib(nibName: "ClubListTableViewCell", bundle: nil), forCellReuseIdentifier: "ClubListTableViewCell")
        self.closeButton.setTitle("", for: .normal);
        self.getChattingList(user_Index: user_Index, currentDate: currentDate);
        
        let data = UserDefaults.standard.object(forKey: "myModel")
        if(data != nil){
            let decoder = JSONDecoder()
            self.myModel = try? decoder.decode(UserData.self, from: data as! Data)
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNotification), name: .CalendarDetailViewControllerRefresh, object: nil)
    }
    
    
    @objc func refreshNotification(){
        clubList.removeAll()
        getChattingList(user_Index: user_Index, currentDate: currentDate);
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("CalendarDetailViewController가 Load됨 (viewWillAppear)")
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("CalendarDetailViewController가 사라지기 전 (viewWillDisappear)")
        
        
        
    }
    
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true);
    }
    
    
    func getChattingList(user_Index : Int? , currentDate : String?) -> Void {
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/clubController/loadCurrentDateClubList"
        
        let param: Parameters = [
            "user_Index": user_Index! as Any,
            "currentDate": currentDate! as Any
        ];
        
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).response{ response in
            switch response.result {
            case .success:
                
                do{
                    
                    let json = JSON(response.data!);
                                        
                    let jsonData = json["currentDateClubList"].stringValue.data(using: String.Encoding.utf8);
                    
                    if let jsonArray = try JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments) as? [Dictionary<String,Any>] {
                        for item in jsonArray{
                            self.clubList.append(item);
                        }
                        self.clubListTableView.reloadData()
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
    
    
    func deleteClubList(model : ClubData ){
        do{
            guard let uploadData = try? JSONEncoder().encode(model)
            else {return}
            let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/clubController/deleteClubList");
            
            // URLRequest 객체를 정의
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            // HTTP 메시지 헤더
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // URLSession 객체를 통해 전송, 응답값 처리
            let task = URLSession.shared.uploadTask(with: request, from: uploadData) { (data, response, error) in
                // 서버가 응답이 없거나 통신이 실패
                if let e = error {
                    NSLog("An error has occured: \(e.localizedDescription)")
                    return
                }
                // 응답 처리 로직
                print("comment post success")
                NotificationCenter.default.post(name: .FourthViewControllerRefresh, object: nil)
                NotificationCenter.default.post(name: .UserBulletinBoardViewControllerRefresh, object: nil)
                NotificationCenter.default.post(name: .MyClubListViewControllerRefresh, object: nil)
            }
            // POST 전송
            task.resume()
        }catch{
            
        }
    }
}

extension CalendarDetailViewController : UITableViewDelegate , UITableViewDataSource , FourthViewControllerClickProtocal {
    
    func blockClickItem(index: Int?) {
        
        let myIndex = myModel.user_Index;
        let items = clubList[index!];
        let nickNameText = items["userId"]! as? String;
        let userIndex = items["user_Index"]! as? Int;
        
        if(myIndex == userIndex){
            
//            self.deleteClubList(model: items);
            
        }else{
            
            let alert = self.storyboard?.instantiateViewController(withIdentifier: "BlockDialogViewController") as! BlockDialogViewController
            alert.modalPresentationStyle = .overCurrentContext
            alert.modalTransitionStyle = .crossDissolve
            alert.personUserId = nickNameText!;
            alert.personUserIndex = userIndex!;
            alert.whatType = "clubList";
            alert.clubListModel = items;
            self.present(alert, animated: false, completion: nil)
            
        }
        
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let itemCell = cell as! ClubListTableViewCell
        for cell in itemCell.fileCollectionView.visibleCells {
            let indexPath = itemCell.fileCollectionView.indexPath(for: cell)
            let cellItem = itemCell.fileCollectionView.cellForItem(at: indexPath!) as! ClubListFileCollectionViewCell;
            cellItem.videoPlayerView.player?.play()
            cellItem.videoPlayerView.isPlaying = true;
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let itemCell = cell as! ClubListTableViewCell
        for cell in itemCell.fileCollectionView.visibleCells {
            let indexPath = itemCell.fileCollectionView.indexPath(for: cell)
            let cellItem = itemCell.fileCollectionView.cellForItem(at: indexPath!) as! ClubListFileCollectionViewCell;
            cellItem.videoPlayerView.player?.pause()
            cellItem.videoPlayerView.isPlaying = false;
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.clubList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let clubdetailCell = tableView.dequeueReusableCell(withIdentifier: "ClubListTableViewCell", for: indexPath) as? ClubListTableViewCell else {
            return UITableViewCell();
        }
        
        
        
        let title = self.clubList[indexPath.row]["title"]!;
        let contents = self.clubList[indexPath.row]["clubIntroduce"]!;
        let possibleSumCount = self.clubList[indexPath.row]["currentSumJoinCount"]!;
        let possibleMinAge = self.clubList[indexPath.row]["minAge"]!
        let possibleMaxAge = self.clubList[indexPath.row]["maxAge"]!
        let expectedMoney = self.clubList[indexPath.row]["expectedMoney"]!
        let fileAllUrls = self.clubList[indexPath.row]["allUrls"]!
        let placeInfo = self.clubList[indexPath.row]["place"]!
        let myJoinInfo = self.clubList[indexPath.row]["myJoinInfo"]!
        let userId = self.clubList[indexPath.row]["userId"]!
        
        do{
            clubdetailCell.blockButton.isHidden = false;
            if(userId as! String == myModel.userId){
                clubdetailCell.blockButton.isHidden = true;
            }else{
                clubdetailCell.blockButton.isHidden = false;
            }
            
            clubdetailCell.clickDelegate = self;
            clubdetailCell.indexPath = indexPath;
            clubdetailCell.titleLabel.text = title as! String;
            clubdetailCell.contentsLabel.text = contents as! String;
            clubdetailCell.possibleJoinCountLabel.text =  "\(possibleSumCount as! Int)";
            clubdetailCell.possibleJoinAge.text = "\(possibleMinAge) ~ \(possibleMaxAge)";
            
            let formatPrice = numberFormatter.string(from: NSNumber(value: expectedMoney as! Int))
            
            clubdetailCell.expectedMoney.text = "\(formatPrice!)원";
            clubdetailCell.fileInfoArray = fileAllUrls as! [String];
            
            clubdetailCell.myModel =  self.myModel;
            clubdetailCell.clickInterface = self.clickDelegaate
            clubdetailCell.clubItems = self.clubList[indexPath.row];
            
            print("myJoinInfo \(myJoinInfo)");
            
            let placeInfoJson = JSON(placeInfo);
            let jsonData = placeInfoJson.stringValue.data(using: String.Encoding.utf8);
            
            if let jsonArray = try JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments) as? Dictionary<String,Any> {
                
                let place_name = jsonArray["place_name"];
                clubdetailCell.locationLabel.text = place_name as? String;
            }else{
                print("bad Json");
            }
            
            
        }catch(let error){
            print("error : \(error)");
        }
        return clubdetailCell
    }
    
    
}
