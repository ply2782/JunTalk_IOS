//
//  MyClubListViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/08/15.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import AVFoundation



extension Notification.Name {
    static let MyClubListViewControllerRefresh = Notification.Name("MyClubListViewControllerRefresh");
}




class MyClubListViewController: UIViewController {
    
    @IBOutlet weak var myClubListTableView: UITableView!
    var myReelsListArray : [Dictionary<String,Any>] = [];
    var myModel : UserData!;
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let data = UserDefaults.standard.object(forKey: "myModel")
        if(data != nil){
            let decoder = JSONDecoder()
            self.myModel = try? decoder.decode(UserData.self, from: data as! Data)
        }
        
        self.initCollection()
        self.clubList(user_Index: myModel.user_Index)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNotification), name: .MyClubListViewControllerRefresh, object: nil)
    }
    
    
    @objc func refreshNotification(){
        clubList(user_Index: myModel.user_Index)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("MyClubListViewController가 Load됨 (viewWillAppear)")
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("MyClubListViewController가 사라지기 전 (viewWillDisappear)")
        
        
    }
    
    
    private func initCollection() {
        self.myClubListTableView.delegate = self
        self.myClubListTableView.dataSource = self
        self.myClubListTableView.register(UINib(nibName: "MyClubListTableViewCell", bundle: nil), forCellReuseIdentifier: "MyClubListTableViewCell")
    }
    
    func clubList(user_Index : Int?){
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/clubController/clubList";
        
        let param: Parameters =
        [
            "user_Index" : user_Index! as Any,
        ];
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).response{ response in switch response.result {
            
        case .success:
            
            do{
                let json = JSON(response.data!);
                self.myReelsListArray = [];
                
                let jsonData = json["clubList"].stringValue.data(using: String.Encoding.utf8);
                
                if let jsonArray = try JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments) as? [Dictionary<String,Any>] {
                    
                    for item in jsonArray{
                        self.myReelsListArray.append(item);
                    }
                    
                    self.myClubListTableView.reloadData()
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
    
    func dictionaryToObject<T:Decodable>(objectType: T.Type,
                                         dictionary: [String:Any] ) -> [T]? {
        
        guard let dictionaries = try? JSONSerialization.data(withJSONObject: dictionary) else { return nil }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let objects = try? decoder.decode([T].self, from: dictionaries) else { return nil }
        return objects
        
    }
    
}

extension MyClubListViewController : UITableViewDelegate , UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let itemCell = cell as! MyClubListTableViewCell
        for cell in itemCell.fileCollectionView.visibleCells {
            let indexPath = itemCell.fileCollectionView.indexPath(for: cell)
            let cellItem = itemCell.fileCollectionView.cellForItem(at: indexPath!) as! ClubListFileCollectionViewCell;
            cellItem.videoPlayerView.player?.play()
            cellItem.videoPlayerView.isPlaying = true;
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let itemCell = cell as! MyClubListTableViewCell
        for cell in itemCell.fileCollectionView.visibleCells {
            let indexPath = itemCell.fileCollectionView.indexPath(for: cell)
            let cellItem = itemCell.fileCollectionView.cellForItem(at: indexPath!) as! ClubListFileCollectionViewCell;
            cellItem.videoPlayerView.player?.pause()
            cellItem.videoPlayerView.isPlaying = false;
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myReelsListArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let clubdetailCell = tableView.dequeueReusableCell(withIdentifier: "MyClubListTableViewCell", for: indexPath) as? MyClubListTableViewCell else {
            return UITableViewCell();
        }
        
        let title = self.myReelsListArray[indexPath.row]["title"]!;
        let contents = self.myReelsListArray[indexPath.row]["clubIntroduce"]!;
        let possibleSumCount = self.myReelsListArray[indexPath.row]["currentSumJoinCount"]!;
        let possibleMinAge = self.myReelsListArray[indexPath.row]["minAge"]!
        let possibleMaxAge = self.myReelsListArray[indexPath.row]["maxAge"]!
        let expectedMoney = self.myReelsListArray[indexPath.row]["expectedMoney"]!
        let fileAllUrls = self.myReelsListArray[indexPath.row]["allUrls"]!
        let placeInfo = self.myReelsListArray[indexPath.row]["place"]!
        let club_Uuid = self.myReelsListArray[indexPath.row]["club_Uuid"]!
        let userId = self.myReelsListArray[indexPath.row]["userId"]!
        

        do{

            clubdetailCell.titleLabel.text = title as? String;
            clubdetailCell.contentsLabel.text = contents as? String;
            clubdetailCell.possibleJoinCountLabel.text =  "\(possibleSumCount as! Int)";
            clubdetailCell.possibleJoinAge.text = "\(possibleMinAge) ~ \(possibleMaxAge)";
            clubdetailCell.expectedMoney.text = "\(expectedMoney as! Int)";
            clubdetailCell.fileInfoArray = fileAllUrls as! [String];
            clubdetailCell.indexPath = indexPath;
            clubdetailCell.customClubInfo = try CustomClubData.init();
            clubdetailCell.customClubInfo.club_Uuid = club_Uuid as! String;
            clubdetailCell.customClubInfo.userId = userId as! String;
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


extension Encodable {
    
    var toDictionary : [String: Any]? {
        guard let object = try? JSONEncoder().encode(self) else { return nil }
        guard let dictionary = try? JSONSerialization.jsonObject(with: object, options: []) as? [String:Any] else { return nil }
        return dictionary
    }
}

