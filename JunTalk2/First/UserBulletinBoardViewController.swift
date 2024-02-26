//
//  UserBulletinBoardViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/09/09.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVKit
import Kingfisher





extension Notification.Name {
    static let UserBulletinBoardViewControllerRefresh = Notification.Name("UserBulletinBoardViewControllerRefresh");
}




class UserBulletinBoardViewController: UIViewController {
    
    var bulletinModel : BulletinBoardModel!;
    @IBOutlet var userBulletinTableView: UITableView!
    var isPaging: Bool = false // 현재 페이징 중인지 체크하는 flag
    var hasNextPage: Bool = false // 마지막 페이지 인지 체크 하는 flag
    var personUserId  : String?
    var personUserIndex : Int?
    var page : Int = 0;
    var myId : String?
    var myIndex : Int?
    var mainBulletinArray : [Dictionary<String,Any>] = [];
    let cornerImageProcessor = RoundCornerImageProcessor(cornerRadius: 30)
    let retryStrategy = DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(3))
    
    
    
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)

        return control
    }()
    
    @objc func refreshTableView(){
        mainBulletinArray.removeAll()
        getLoadUserBulletinBoard(userId: personUserId!, myIndex: myIndex!, myId: myId!, category: "A", page: 0);
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            self.bulletinModel = try BulletinBoardModel.init();
        }catch{
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNotification), name: .UserBulletinBoardViewControllerRefresh, object: nil)
        
        userBulletinTableView.dataSource = self;
        userBulletinTableView.delegate = self;
        userBulletinTableView.register(UINib(nibName: "UserBulletinTableViewCell", bundle: nil), forCellReuseIdentifier: "UserBulletinTableViewCell")
        getLoadUserBulletinBoard(userId: personUserId!, myIndex: myIndex!, myId: myId!, category: "A", page: page);
    }
    
    @objc func refreshNotification(){
        mainBulletinArray.removeAll()
        getLoadUserBulletinBoard(userId: personUserId!, myIndex: myIndex!, myId: myId!, category: "A", page: 0);
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("UserBulletinBoardViewController가 Load됨 (viewWillAppear)")
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("UserBulletinBoardViewController가 사라지기 전 (viewWillDisappear)")
        
        
    }
    
    
    
    func paging() {
        if(self.mainBulletinArray.count > (10 * page)){
            page += 1;
            getLoadUserBulletinBoard(userId: personUserId!, myIndex: myIndex!, myId: myId!, category: "A", page: page);
        }
    }
    
    
    
    func deleteBulletinBoard(model : BulletinBoardModel ){
        do{
            
            guard let uploadData = try? JSONEncoder().encode(model)
            else {return}
            // URL 객체 정의
            let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/bulletinBoardController/deleteBulletinBoard");
            
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
                
                
            }
            // POST 전송
            task.resume()
            
            
            
            //            let apiURL = "http://ply2782ply2782.cafe24.com:8080/bulletinBoardController/deleteBulletinBoard";
            //
            //
            //            let param: Parameters =
            //            [
            //                "bulletin_Uuid" : "\(model.bulletin_Uuid)",
            //                "userId" : "\(model.userId)"
            //
            //            ];
            //
            //
            //            AF.request(apiURL, method: .post,
            //                       parameters: param,
            //                       encoding: URLEncoding.httpBody,
            //                       headers: [
            //                        "Content-Type":"application/json",
            //                        "Accept":"application/json; charset=utf-8",
            //                       ]
            //            )
            //            .response{ response in
            //                switch response.result {
            //                case .success:
            //
            //                    NotificationCenter.default.post(name: .FourthViewControllerRefresh, object: nil)
            //
            //                    NotificationCenter.default.post(name: .UserBulletinBoardViewControllerRefresh, object: nil)
            //
            //                    return
            //                case .failure(let error):
            //                    print(error)
            //                    return
            //                }
            //            }
        }catch{
            
        }
    }
    
    
    
    
    func getLoadUserBulletinBoard(
        userId : String? , myIndex : Int? , myId : String? , category : String? , page : Int?
    ){
        
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/bulletinBoardController/personal_BulletinBoard";
        
        let param: Parameters =
        [
            "userId" : userId! as Any,
            "myIndex" : myIndex! as Any,
            "myId" : myId!,
            "category" : category!,
            "page" : page!,
        ];
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).response{ response in switch response.result {
            
        case .success:
            
            do{
                
                if let jsonArray = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [Dictionary<String,Any>] {
                    
                    for item in jsonArray{
                        self.mainBulletinArray.append(item);
                    }
                    self.isPaging = false // 페이징이 종료 되었음을 표시
                    self.userBulletinTableView.reloadData()
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
    
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
}

class LoadingCell : UITableViewCell{
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    func start() {
        loadingIndicator.startAnimating()
    }
}



extension UserBulletinBoardViewController : UITableViewDelegate , UITableViewDataSource , FourthViewControllerClickProtocal {
    
    func blockClickItem(index: Int?) {
        
        
        let items = mainBulletinArray[index!];
        
        let nickNameText = items["userId"]! as? String;
        let userIndex = items["user_Index"]! as? Int;
        let bulletin_Uuid = items["bulletin_Uuid"] as? String;
        
        bulletinModel.userId = nickNameText!
        bulletinModel.user_Index = userIndex!
        bulletinModel.bulletin_Uuid = bulletin_Uuid!;
        
        
        
        if(myIndex == userIndex){
            
            let sheet = UIAlertController(title: "확인", message: "정말 삭제하시겠습니까?", preferredStyle: .alert)
            sheet.addAction(UIAlertAction(title: "확인", style: .destructive, handler: { _ in self.deleteBulletinBoard(model: self.bulletinModel); }))

            sheet.addAction(UIAlertAction(title: "취소", style: .cancel))
            present(sheet, animated: true)
            
            
        }else{
            
            let items = mainBulletinArray[index!];
            let nickNameText = items["userId"]! as? String;
            let userIndex = items["user_Index"]! as? Int;
            let alert = self.storyboard?.instantiateViewController(withIdentifier: "BlockDialogViewController") as! BlockDialogViewController
            alert.modalPresentationStyle = .overCurrentContext
            alert.modalTransitionStyle = .crossDissolve
            alert.personUserId = nickNameText!;
            alert.personUserIndex = userIndex!;
            alert.whatType = "bulletinBoard";
            alert.bulletinBoardModel = items;
            self.present(alert, animated: false, completion: nil)
            
        }
        
        
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let itemCell = cell as! UserBulletinTableViewCell
        for cell in itemCell.fileCollectionView.visibleCells {
            let indexPath = itemCell.fileCollectionView.indexPath(for: cell)
            let cellItem = itemCell.fileCollectionView.cellForItem(at: indexPath!) as! ClubListFileCollectionViewCell;
            cellItem.videoPlayerView.player?.play()
            cellItem.videoPlayerView.isPlaying = true;
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let itemCell = cell as! UserBulletinTableViewCell
        for cell in itemCell.fileCollectionView.visibleCells {
            let indexPath = itemCell.fileCollectionView.indexPath(for: cell)
            let cellItem = itemCell.fileCollectionView.cellForItem(at: indexPath!) as! ClubListFileCollectionViewCell;
            cellItem.videoPlayerView.player?.pause()
            cellItem.videoPlayerView.isPlaying = false;
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return mainBulletinArray.count;
        } else if section == 1 && self.isPaging && self.hasNextPage {
            return 1
        }
        
        return 0
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            guard let bulletinBoardCell = tableView.dequeueReusableCell(withIdentifier: "UserBulletinTableViewCell", for: indexPath) as? UserBulletinTableViewCell else {
                return UITableViewCell();
            }
            
            let items = mainBulletinArray[indexPath.item];
            let userMainPhoto = items["userMainPhoto"] as! String;
            let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/userController/profileImageShow?imageName=\(userMainPhoto)");
            let bulletin_LikeCount = items["bulletin_LikeCount"]! as? Int;
            let bulletin_CommentCount = items["bulletin_CommentCount"]! as? Int;
            let nickNameText = items["userId"]! as? String;
            let regDateText = items["bulletin_RegDate"]! as? String;
            let bulletin_Content = items["bulletin_Content"] as? String;
            let fileItemsArray = items["allUrls"]! as? [String];
            
            
            bulletinBoardCell.fileView.isHidden = false;
            if(fileItemsArray!.isEmpty){
                bulletinBoardCell.fileView.isHidden = true;
            }else{
                bulletinBoardCell.fileView.isHidden = false;
            }
            
            
            bulletinBoardCell.personImageView.clipsToBounds = true
            bulletinBoardCell.personImageView.layer.cornerRadius = bulletinBoardCell.personImageView.frame.height/2
            bulletinBoardCell.personImageView?.kf.indicatorType = .activity
            bulletinBoardCell.personImageView?.kf.setImage(
                with: url,
                placeholder: nil,
                options: [
                    .retryStrategy(retryStrategy),
                    .transition(.fade(1.2)),
                    .forceTransition,
                    .processor(cornerImageProcessor)
                ],
                completionHandler: nil)
            
            
            bulletinBoardCell.clickDelegate = self;
            bulletinBoardCell.currentClickRow = indexPath;
            bulletinBoardCell.contentsLabel?.text = bulletin_Content;
            bulletinBoardCell.likeCountLabel?.text = String(bulletin_LikeCount!)
            bulletinBoardCell.messageCount?.text = String(bulletin_CommentCount!)
            bulletinBoardCell.nicknameLabel?.text = nickNameText
            bulletinBoardCell.fileInfoArray = fileItemsArray!;
            
            // the date you want to format
            let exampleDate = (regDateText?.toDate()!.addingTimeInterval(-15000))!
            // ask for the full relative date
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            // get exampleDate relative to the current date
            let relativeDate = formatter.localizedString(for: exampleDate, relativeTo: Date())
            // print it out
            bulletinBoardCell.regDateLabel?.text = relativeDate
            
            
            return bulletinBoardCell;
            
        }else{
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as? LoadingCell else {
                return UITableViewCell()
            }
            cell.start();
            return cell
            
        }
        
     
    }
}


extension UserBulletinBoardViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentOffset_y = scrollView.contentOffset.y
        let tableViewContentSize = self.userBulletinTableView.contentSize.height
        let pagination_y = tableViewContentSize * 0.2
        
        if contentOffset_y > tableViewContentSize - pagination_y {
            if(!isPaging){
                self.beginPaging();
            }
        }
    }
    
    func beginPaging() {
        isPaging = true // 현재 페이징이 진행 되는 것을 표시
        // Section 1을 reload하여 로딩 셀을 보여줌 (페이징 진행 중인 것을 확인할 수 있도록)
        DispatchQueue.main.async {
            self.userBulletinTableView.reloadSections(IndexSet(integer: 1), with: .none)
        }
        
        // 페이징 메소드 호출
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.paging()
        }
    }
}
