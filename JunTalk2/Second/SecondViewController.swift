//
//  SecondViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/04/27.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData
import Kingfisher




extension Notification.Name {
    static let chattingRefresh = Notification.Name("chattingRefresh");
}



protocol CVCellDelegate {
    func selectedCVCell(array : [String] )
}

class SecondViewController: UIViewController {
    
    
    
    @IBOutlet weak var chattingTableView: UITableView!
    var page = 0;
    var roomModelListCopy :[Dictionary<String,Any>] = [];
    let myUserDefaults = UserDefaults.standard;
    var myModel : UserData!;
    let formatter = DateFormatter()
    let reFormatter = DateFormatter()
    let date = Date()
    
    
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)

        return control
    }()
    
    @objc func refreshTableView(){
        self.roomModelListCopy.removeAll()
        getChattingList(page: page, userId: self.myModel.userId);
    }
    
    
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("response \(response)");
        print("userInfo \(userInfo)");
        completionHandler()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNotification), name: .chattingRefresh, object: nil)
        
        settingChattingTableView();
        formatter.dateFormat = "yy-MM-dd HH:mm:ss"
        reFormatter.dateFormat = "yyyy-MM-dd"
        
        let data = UserDefaults.standard.object(forKey: "myModel")
        if(data != nil){
            let decoder = JSONDecoder()
            self.myModel = try? decoder.decode(UserData.self, from: data as! Data)
        }
        getChattingList(page: page, userId: self.myModel.userId);
        chattingTableView.tableFooterView = UIView(frame: .zero)
    }
    
    
    
    @objc func refreshNotification(){
        print("refreshNotification")
        self.roomModelListCopy.removeAll()
        getChattingList(page: page, userId: self.myModel.userId);
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
    
    
    @IBAction func unwindVC1 (segue : UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chattingSegue"{
            if let destination = segue.destination as?
                CustomChattingViewController {
                if let selectdeIndex =
                    self.chattingTableView.indexPathForSelectedRow?.row {
                    destination.userId = self.myModel.userId;
                    destination.room_Uuid =
                        self.roomModelListCopy[selectdeIndex]["room_Uuid"] as? String;
                    destination.roomModel = self.roomModelListCopy[selectdeIndex];
                }
            }
        }
    }
    
    
    func settingChattingTableView(){
        self.chattingTableView.delegate = self;
        self.chattingTableView.dataSource = self;
        self.chattingTableView.prefetchDataSource = self
        self.chattingTableView.refreshControl = refreshControl

    }
    
    func getChattingList(page : Int? , userId : String?) -> Void {
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/roomController/roomList"
        
        let param: Parameters = [
            "page": page! as Any,
            "userId": userId! as Any
        ];
        
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).response{ response in
            switch response.result {
            case .success:
                
                do{
                    if let jsonArray = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [Dictionary<String,Any>] {
                        for item in jsonArray{
                            print("item \(item)");
                            self.roomModelListCopy.append(item);
                        }
                        self.chattingTableView.reloadData();
                        self.refreshControl.endRefreshing()

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


extension ChattingCell : CVCellDelegate{
    func selectedCVCell(array: [String]) {
        self.joinImageArray = array;
        
    }
}


class ChattingCell : UITableViewCell{
    
    @IBOutlet weak var unReadCountView: UIView!
    @IBOutlet weak var joinImageCollectionView: UICollectionView!
    @IBOutlet weak var unReadCountLabel: UILabel!
    @IBOutlet weak var conversationTextView: UITextView!
    @IBOutlet weak var regDateLabel: UILabel!
    @IBOutlet weak var joinCountLabel: UILabel!
    var delegate: CVCellDelegate?
    
    var joinImageArray :[String] = []{
        didSet{
            self.joinImageCollectionView.reloadData();
        }
    };
    
    
    override func awakeFromNib(){
        super.awakeFromNib();
        
    }
    
    
    override func prepareForReuse() {
        
        self.unReadCountLabel.text = nil;
        self.conversationTextView.text = nil;
        self.regDateLabel.text = nil;
        self.joinCountLabel.text = nil;
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.delegate = self;
        self.conversationTextView.isEditable = false;
        self.joinImageCollectionView.delegate = self;
        self.joinImageCollectionView.dataSource = self;
        
        
        
        self.unReadCountLabel.layer.cornerRadius = 20
        self.unReadCountLabel.layer.borderWidth = 1
        self.unReadCountLabel.layer.borderColor = UIColor.clear.cgColor
        self.unReadCountLabel.clipsToBounds = true
        
    }
}



class JoinImageListCell : UICollectionViewCell{
    @IBOutlet weak var joinImageView: UIImageView!
    let cornerImageProcessor = RoundCornerImageProcessor(cornerRadius: 30)
    let retryStrategy = DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(3))
    
    
    override func awakeFromNib(){
        super.awakeFromNib();
        print("layoutSubviews joinImageArray");
    }
    
    
    override func prepareForReuse() {
        self.joinImageView.image = nil;
        print("prepareForReuse joinImageView");
    }
    
        
    override func layoutSubviews() {
        super.layoutSubviews()
        print("layoutSubviews joinImageView");
    }
}



extension ChattingCell : UICollectionViewDataSource
                         ,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    // 선택 안한 부분 스타일 커스텀
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {


    }

    //  선택 한 부분 스타일 커스텀
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        print("selectedRow \(indexPath.row)");
    }

    // CollectionView item 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.joinImageArray.count;
    }


    // CollectionView Cell의 Object
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        guard let joinImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "JoinImageListCell", for: indexPath) as? JoinImageListCell else {
            return UICollectionViewCell()
        }

        let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/userController/profileImageShow?imageName=\(self.joinImageArray[indexPath.row])");
        
        joinImageCell.joinImageView.layer.borderColor = UIColor.clear.cgColor
        joinImageCell.joinImageView.clipsToBounds = true
        joinImageCell.joinImageView.layer.cornerRadius = joinImageCell.joinImageView.frame.height/2
        joinImageCell.joinImageView?.kf.indicatorType = .activity
        joinImageCell.joinImageView?.kf.setImage(
          with: url,
          placeholder: nil,
          options: [
            .retryStrategy(joinImageCell.retryStrategy),
            .transition(.fade(1.2)),
            .forceTransition,
            .processor(joinImageCell.cornerImageProcessor)
          ],
          completionHandler: nil)

        return joinImageCell;
    }

    // CollectionView Cell의 Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width: CGFloat = collectionView.frame.width
        let height : CGFloat = collectionView.frame.height
        return CGSize(width: 30, height: 30)

    }

    // CollectionView Cell의 위아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 1.0
    }

    // CollectionView Cell의 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    

    
    
}

extension SecondViewController : UITableViewDataSource,UITableViewDelegate,
                                 UITableViewDataSourcePrefetching{
    

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let windowHeight = UIScreen.main.bounds.size.height;
        return tableView.rowHeight;

    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.roomModelListCopy.count;
    }
    
    func prefetchCellData(_ indexPath: IndexPath) {
            
           DispatchQueue.main.async {
               let indexPath = IndexPath(row: indexPath.row, section: 0) // 로드할 인덱스 패스
               if self.chattingTableView.indexPathsForVisibleRows?.contains(indexPath) ?? false { // 만약 보이지 않는 셀이면 nil을 반환하는 옵셔널 체이닝
                   self.chattingTableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .fade) // 해당 셀만 리로드
               }
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
        guard let chattingCell = tableView.dequeueReusableCell(withIdentifier: "ChattingCell", for: indexPath) as? ChattingCell else {
            return UITableViewCell();
        }
                
    
        
        let inputDate = self.roomModelListCopy[indexPath.row]["conversationTime"] as! String
        
        if(inputDate != nil && inputDate != "null"){
            let currentDate = formatter.date(from: inputDate);
            let reCurrentDate  = reFormatter.string(from: currentDate!);
            
            let currentYearSubString = reCurrentDate.index(reCurrentDate.startIndex, offsetBy: 3)
            let currentYear = reCurrentDate[...currentYearSubString];
            
            let startIndex = reCurrentDate.index(reCurrentDate.startIndex, offsetBy: 5)
            let currentMonthSubString =
                reCurrentDate.index(reCurrentDate.startIndex, offsetBy: 7)
            let currentMonth = reCurrentDate[startIndex ..< currentMonthSubString];
            
            let startIndex1 = reCurrentDate.index(reCurrentDate.startIndex, offsetBy: 8)
            let currentDaySubString =
                reCurrentDate.index(reCurrentDate.startIndex, offsetBy: 10)
            let currentDay = reCurrentDate[startIndex1 ..< currentDaySubString];
            
            let myDateComponents = DateComponents(year: Int(currentYear), month: Int(currentMonth), day: Int(currentDay))
            let startDate = Calendar.current.date(from: myDateComponents)!
            let offsetComps = Calendar.current.dateComponents([.year,.month,.day], from: startDate, to: Date())
            if case let (y?, m?, d?) = (offsetComps.year, offsetComps.month, offsetComps.day) {
                chattingCell.regDateLabel.text = "\(d)일전";
            }
        }
        
        
        chattingCell.conversationTextView.text =
            self.roomModelListCopy[indexPath.row]["room_Conversation"] as? String;
        
        chattingCell.joinCountLabel.text =
            "\(self.roomModelListCopy[indexPath.row]["room_JoinCount"] as! Int) 명"
        
        
        let joinPeopleImageArray = self.roomModelListCopy[indexPath.item]["joinPeopleImageList"] as! [String];
        
        if(joinPeopleImageArray.count > 0){
            if let delegate = chattingCell.delegate {
                delegate.selectedCVCell(array: joinPeopleImageArray);
            }
        }
        
        
        chattingCell.joinImageArray = self.roomModelListCopy[indexPath.item]["joinPeopleImageList"] as! [String]
        chattingCell.joinImageCollectionView.reloadData();
        
        
        let unReadCount = self.roomModelListCopy[indexPath.row]["unreadCount"] as? String;
        if(unReadCount == nil){
            chattingCell.unReadCountView.isHidden = true;
        }else{
            chattingCell.unReadCountView.isHidden = false;
            chattingCell.unReadCountLabel.text = unReadCount;
        }
                
        return chattingCell;
    }
}


