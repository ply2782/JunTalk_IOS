//
//  FourthViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/05/11.
//
//
import UIKit
import Alamofire
import SwiftyJSON
import AVKit
import Kingfisher



extension Notification.Name {
    static let FourthViewControllerRefresh = Notification.Name("FourthViewControllerRefresh");
}


extension String {
    func toDate() -> Date? { //"yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
}

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.string(from: self)
    }
}

protocol FourthViewControllerClickProtocal {
    func blockClickItem(index : Int?);
}

class FourthViewController: UIViewController {
    
    @IBOutlet weak var reelsImage: UIImageView!
    var isPaging: Bool = false // 현재 페이징 중인지 체크하는 flag
    var hasNextPage: Bool = false // 마지막 페이지 인지 체크 하는 flag
    @IBOutlet weak var createBulletinBoardImageView: UIImageView!
    @IBOutlet weak var bulletinTableView: UITableView!
    let cornerImageProcessor = RoundCornerImageProcessor(cornerRadius: 30)
    let retryStrategy = DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(3))
    var bulletinArray :[Dictionary<String,Any>] = [];
    var myModel : UserData!;
    var cacheVideoURl : [String] = [];
    var type = "A";
    var page = 0;
    var collectionViewCount : [String] = [];
    var bulletinModel : BulletinBoardModel!;
    
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        
        return control
    }()
    
    @objc func refreshTableView(){
        self.bulletinArray.removeAll()
        getBulletinBoard(myId: myModel.userId, user_Index: myModel.user_Index, category: type, page: 0);
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        do{
            self.bulletinModel = try BulletinBoardModel.init();
        }catch{
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNotification), name: .FourthViewControllerRefresh, object: nil)
        
        
        self.bulletinTableView.delegate = self;
        self.bulletinTableView.dataSource = self;
        self.bulletinTableView.refreshControl = refreshControl
        print("fourthViewController \(viewIfLoaded?.window != nil)");
        
        
        
        
        self.reelsImage.clipsToBounds = true
        self.reelsImage.layer.cornerRadius = self.reelsImage.frame.height/2
        
        
        let data = UserDefaults.standard.object(forKey: "myModel")
        if(data != nil){
            let decoder = JSONDecoder()
            self.myModel = try? decoder.decode(UserData.self, from: data as! Data)
        }
        
        getBulletinBoard(myId: myModel.userId, user_Index: myModel.user_Index, category: type, page: page);
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(imageTapped))
        self.createBulletinBoardImageView.isUserInteractionEnabled = true
        self.createBulletinBoardImageView.addGestureRecognizer(tapGestureRecognizer)
        
        
        
        
        let goToReels = UITapGestureRecognizer(target:self, action:#selector(goToReelsTapped))
        self.reelsImage.isUserInteractionEnabled = true
        self.reelsImage.addGestureRecognizer(goToReels)
        
        bulletinTableView.register(UINib(nibName: "UserBulletinTableViewCell", bundle: nil), forCellReuseIdentifier: "UserBulletinTableViewCell")
        
        
    }
    
    
    
    @objc func refreshNotification(){
        self.bulletinArray.removeAll()
        getBulletinBoard(myId: myModel.userId, user_Index: myModel.user_Index, category: type, page: 0);
    }
    
    
    
    @objc private func goToReelsTapped() {
        let reelsViewController = self.storyboard?.instantiateViewController(withIdentifier: "ReelsViewController") as! ReelsViewController
        reelsViewController.modalPresentationStyle = .overCurrentContext
        reelsViewController.modalTransitionStyle = .crossDissolve
        reelsViewController.userId = myModel.userId;
        reelsViewController.user_Index = myModel.user_Index
        self.present(reelsViewController, animated: true, completion: nil)
    }
    
    @objc private func imageTapped() {
        let createBulletinBoardViewController = self.storyboard?.instantiateViewController(withIdentifier: "CreateBulletinBoardViewController") as! CreateBulletinBoardViewController
        createBulletinBoardViewController.modalPresentationStyle = .overCurrentContext
        createBulletinBoardViewController.modalTransitionStyle = .crossDissolve
        self.present(createBulletinBoardViewController, animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("fourthViewController가 Load됨 (viewWillAppear)")
        
        for itemCell in bulletinTableView.visibleCells {
            let bulletinVisibleCell = itemCell as! UserBulletinTableViewCell
            for cell in bulletinVisibleCell.fileCollectionView.visibleCells {
                let indexPath = bulletinVisibleCell.fileCollectionView.indexPath(for: cell)
                let cellItem = bulletinVisibleCell.fileCollectionView.cellForItem(at: indexPath!) as! ClubListFileCollectionViewCell;
                if(cellItem.videoPlayerView.isPlaying == false){
                    cellItem.videoPlayerView.player?.play()
                    cellItem.videoPlayerView.isPlaying = true;
                }
                
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("fourthViewController가 화면에 나타남 (viewDidAppear)")
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("fourthViewController가 사라지기 전 (viewWillDisappear)")
        
        
        for itemCell in bulletinTableView.visibleCells {
            let bulletinVisibleCell = itemCell as! UserBulletinTableViewCell
            for cell in bulletinVisibleCell.fileCollectionView.visibleCells {
                let indexPath = bulletinVisibleCell.fileCollectionView.indexPath(for: cell)
                let cellItem = bulletinVisibleCell.fileCollectionView.cellForItem(at: indexPath!) as! ClubListFileCollectionViewCell;
                cellItem.videoPlayerView.player?.pause()
                cellItem.videoPlayerView.isPlaying = false;
            }
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("fourthViewController가 사라짐 (viewDidDisappear)")
    }
    
    
    func paging() {
        if(self.bulletinArray.count > (10 * page)){
            page += 1;
            getBulletinBoard(myId: myModel.userId, user_Index: myModel.user_Index, category: type, page: page);
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
    
    
    func getBulletinBoard(
        myId : String?,
        user_Index : Int?,
        category : String?,
        page : Int?){
            
            let apiURL = "http://ply2782ply2782.cafe24.com:8080/bulletinBoardController/bulletinBoard";
            
            let param: Parameters =
            [
                "page" : page! as Any,
                "category" : category! as Any,
                "user_Index" : user_Index! as Any,
                "myId" : myId! as Any
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
                    do{
                        if let jsonArray = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [Dictionary<String,Any>]
                        {
                            
                            
                            for item in jsonArray{
                                self.bulletinArray.append(item);
                            }
                            
                            self.isPaging = false // 페이징이 종료 되었음을 표시
                            self.bulletinTableView.reloadData()
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


extension FourthViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentOffset_y = scrollView.contentOffset.y
        let tableViewContentSize = self.bulletinTableView.contentSize.height
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
            self.bulletinTableView.reloadSections(IndexSet(integer: 1), with: .none)
        }
        
        // 페이징 메소드 호출
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.paging()
        }
    }
}


extension FourthViewController : UITableViewDelegate , UITableViewDataSource , FourthViewControllerClickProtocal {
    
    
    func blockClickItem(index: Int?) {
        
        let my_Index = myModel.user_Index;
        let items = bulletinArray[index!];
        
        let nickNameText = items["userId"]! as? String;
        let userIndex = items["user_Index"]! as? Int;
        let bulletin_Uuid = items["bulletin_Uuid"] as? String;
        
        bulletinModel.userId = nickNameText!
        bulletinModel.user_Index = userIndex!
        bulletinModel.bulletin_Uuid = bulletin_Uuid!;
        
        
        if(my_Index == userIndex){
            let sheet = UIAlertController(title: "확인", message: "정말 삭제하시겠습니까?", preferredStyle: .alert)
            sheet.addAction(UIAlertAction(title: "확인", style: .destructive, handler: { _ in self.deleteBulletinBoard(model: self.bulletinModel); }))

            sheet.addAction(UIAlertAction(title: "취소", style: .cancel))
            present(sheet, animated: true)
            
            
        }else{
            
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
            return bulletinArray.count;
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
            
            let items = bulletinArray[indexPath.item];
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




public enum Result<T> {
    case success(T)
    case failure(NSError)
}

class CacheManager {
    
    static let shared = CacheManager()
    
    private let fileManager = FileManager.default
    
    private lazy var mainDirectoryUrl: URL = {
        
        let documentsUrl = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return documentsUrl
    }()
    
    func getFileWith(stringUrl: String, completionHandler: @escaping (Result<URL>) -> Void ) {
        
        
        let file = directoryFor(stringUrl: stringUrl)
        
        //return file path if already exists in cache directory
        guard !fileManager.fileExists(atPath: file.path)  else {
            completionHandler(Result.success(file))
            return
        }
        
        DispatchQueue.global().async {
            
            if let videoData = NSData(contentsOf: URL(string: stringUrl)!) {
                videoData.write(to: file, atomically: true)
                
                DispatchQueue.main.async {
                    completionHandler(Result.success(file))
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(Result.failure(NSError()));
                }
            }
        }
    }
    
    private func directoryFor(stringUrl: String) -> URL {
        
        let fileURL = URL(string: stringUrl)!.lastPathComponent
        
        let file = self.mainDirectoryUrl.appendingPathComponent(fileURL)
        
        return file
    }
}


typealias ImageCacheLoaderCompletionHandler = ((UIImage) -> ())

class ImageCacheLoader {
    
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache: NSCache<NSString, UIImage>!
    
    init() {
        session = URLSession.shared
        task = URLSessionDownloadTask()
        self.cache = NSCache()
    }
    
    func obtainImageWithPath(imagePath: String, completionHandler: @escaping ImageCacheLoaderCompletionHandler) {
        if let image = self.cache.object(forKey: imagePath as NSString) {
            DispatchQueue.main.async {
                completionHandler(image)
            }
        } else {
            /* You need placeholder image in your assets,
             if you want to display a placeholder to user */
            let placeholder = #imageLiteral(resourceName: "placeholder")
            DispatchQueue.main.async {
                completionHandler(placeholder)
            }
            let url: URL! = URL(string: imagePath)
            task = session.downloadTask(with: url, completionHandler: { (location, response, error) in
                
                if let data = try? Data(contentsOf: url) {
                    
                    let img: UIImage! = UIImage(data: data)
                    self.cache.setObject(img, forKey: imagePath as NSString)
                    DispatchQueue.main.async {
                        completionHandler(img)
                    }
                    
                    
                }
            })
            task.resume()
        }
    }
}
