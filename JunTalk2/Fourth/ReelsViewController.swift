//
//  ReelsViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/08/09.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import AVFoundation





extension Notification.Name {
    static let ReelsRefresh = Notification.Name("ReelsRefresh");
}




protocol ReelsViewControllerClickProtocal {
    func blockClickItem(index : Int?);
    func deleteClickItem(index: Int?);
}




class ReelsViewController: UIViewController , ReelsViewControllerClickProtocal {
    
    func deleteClickItem(index: Int?) {
        
        let sheet = UIAlertController(title: "확인", message: "정말로 삭제하시겠습니까?", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "확인", style: .destructive, handler: { _ in
            do{
                let reelsItem = self.reelsListArray[index!]
                var customReelsData : ReelsModel = try ReelsModel.init();
                customReelsData.userId = reelsItem.userId;
                customReelsData.lils_Uuid = reelsItem.lils_Uuid;
                self.deleteReels(model: customReelsData);
            }catch{
                
            }
            
            
        }))
        sheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(sheet, animated: true)
        
    }
    
    
    
    
    func deleteReels(model : ReelsModel ){
        do{
            
            
            guard let uploadData = try? JSONEncoder().encode(model)
            else {return}
            // URL 객체 정의
            let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/bulletinBoardController/removeLilsVideoList");
            
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
                NotificationCenter.default.post(name: .ReelsRefresh, object: nil)
                
            }
            // POST 전송
            task.resume()
        }catch{
            
        }
    }
    
    
    
    
    func blockClickItem(index: Int?) {
        do{
            let items = reelsListArray[index!];
            let alert = self.storyboard?.instantiateViewController(withIdentifier: "BlockDialogViewController") as! BlockDialogViewController
            alert.modalPresentationStyle = .overCurrentContext
            alert.modalTransitionStyle = .crossDissolve
            alert.personUserId = userId;
            alert.personUserIndex = user_Index;
            alert.whatType = "ReelsList";
            
            alert.reelsModel = try ReelsModel.init();
            alert.reelsModel = items;
            self.present(alert, animated: false, completion: nil)
        }catch{
            
        }
        
        
        
    }
    
    var reelsClickProtocal : ReelsViewControllerClickProtocal!
    @IBOutlet weak var reelsTableView: UITableView!
    @IBOutlet weak var dismissButton: UIButton!
    var reelsListArray : [ReelsModel] = [];
    var page : Int = 0;
    var isPaging: Bool = false // 현재 페이징 중인지 체크하는 flag
    var hasNextPage: Bool = false // 마지막 페이지 인지 체크 하는 flag
    var userId : String = "";
    var user_Index : Int = 0;
    let cornerImageProcessor = RoundCornerImageProcessor(cornerRadius: 30)
    let retryStrategy = DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(3))
    @IBOutlet weak var moveCreateReelsViewController: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNotification), name: .ReelsRefresh, object: nil);
        
        reelsClickProtocal = self;
        settingTableView();
        // Do any additional setup after loading the view.
        self.lilsVideoList(
            page: page,
            userId: userId,
            user_Index: user_Index )
        self.dismissButton.setTitle("", for: .normal)
        
    }
    
    @objc func refreshNotification(){
        self.reelsListArray.removeAll();
        page = 0;
        self.lilsVideoList(
            page: page,
            userId: userId,
            user_Index: user_Index )
    }

    
    
    func paging() {
        if(self.reelsListArray.count > (10 * page)){
            page += 1;
            self.lilsVideoList(
                page: page,
                userId: userId,
                user_Index: user_Index )
        }
    }
    
    
    func beginPaging() {
        isPaging = true // 현재 페이징이 진행 되는 것을 표시
        // 페이징 메소드 호출
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.paging()
        }
    }
    
    
    
    override func viewDidLayoutSubviews() {
        self.reelsTableView.frame = view.bounds;
    }
    
    func settingTableView(){
        self.reelsTableView.delegate = self;
        self.reelsTableView.dataSource = self;
        self.reelsTableView.register(UINib(nibName: "ReelsTableViewCell", bundle: nil), forCellReuseIdentifier: "ReelsTableViewCell")
    }
    
    @IBAction func deleteReels(_ sender: Any) {
        print("delete");
        self.dismiss(animated: true);
    }
    
    
    func lilsVideoList(page : Int? , userId : String? , user_Index: Int?){
        
        
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/bulletinBoardController/LilsVideoList"
        
        let param: Parameters = [
            "page": page! as Any,
            "userId": userId! as Any,
            "user_Index" : user_Index! as Any,
        ];
        
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).responseDecodable(of:[ReelsModel].self){ response in
            switch response.result {
            case .success:
                
                for item in response.value!{
                    self.reelsListArray.append(item);
                }
                self.isPaging = false // 페이징이 종료 되었음을 표시
                self.reelsTableView.reloadData()
                return
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
}



extension ReelsViewController : UITableViewDelegate, UITableViewDataSource ,UIGestureRecognizerDelegate{
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return tableView.rowHeight;
    //    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func prefetchCellData(_ indexPath: IndexPath) {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: indexPath.row, section: 0) // 로드할 인덱스 패스
            if self.reelsTableView.indexPathsForVisibleRows?.contains(indexPath) ?? false { // 만약 보이지 않는 셀이면 nil을 반환하는 옵셔널 체이닝
                self.reelsTableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .fade) // 해당 셀만 리로드
            }
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
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reelsListArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        do{
            
            guard let reelsCell = tableView.dequeueReusableCell(withIdentifier: "ReelsTableViewCell", for: indexPath) as? ReelsTableViewCell else {
                return UITableViewCell();
            }
            
            let reelsItem = self.reelsListArray[indexPath.row]
            let thisIndex = reelsItem.user_Index;
            let lils_videoUrl = reelsItem.lils_videoUrl
            let userMainPhoto = reelsItem.userMainPhoto
            let userId = reelsItem.userId
            let content = reelsItem.content
            let hashTagList = reelsItem.hashTagList
            let replyCount = reelsItem.replyCount
            let likeCount = reelsItem.likeCount
            
            
            let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/videoController/stream/\(lils_videoUrl!)");
            let avPlayer = AVPlayer(url: url!);
            reelsCell.playerView.playerLayer.player = avPlayer;
            reelsCell.playerView.player?.pause()
            
            let imageUrl = URL(string: "http://ply2782ply2782.cafe24.com:8080/userController/profileImageShow?imageName=\(userMainPhoto!)");
            reelsCell.personImageView.clipsToBounds = true
            reelsCell.personImageView.layer.cornerRadius = reelsCell.personImageView.frame.height/2
            reelsCell.personImageView?.kf.indicatorType = .activity
            reelsCell.personImageView?.kf.setImage(
                with: imageUrl,
                placeholder: nil,
                options: [
                    .retryStrategy(retryStrategy),
                    .transition(.fade(1.2)),
                    .forceTransition,
                    .processor(cornerImageProcessor)
                ],
                completionHandler: nil)
            reelsCell.nicknameLabel.text = userId;
            reelsCell.likeLabel.text = "\(likeCount!)"
            reelsCell.replyLabel.text = "\(replyCount!)"
            reelsCell.contentTextView.text = content            
            reelsCell.indexPath = indexPath;
            reelsCell.myIndex = user_Index;
            reelsCell.thisIndex = thisIndex!;
            reelsCell.clickDelegate = self.reelsClickProtocal;
            
            return reelsCell;
            
        }catch{
            
        }
        
        return UITableViewCell();
    }
    
    
    //    스크롤 시 끝에 다다를떄
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentOffset_y = scrollView.contentOffset.y
        let tableViewContentSize = self.reelsTableView.contentSize.height
        let pagination_y = tableViewContentSize * 0.2
        
        if contentOffset_y > tableViewContentSize - pagination_y {
            if(!isPaging){
                self.beginPaging();
            }
        }
        
        if self.reelsTableView.contentOffset.x > self.reelsTableView.contentSize.height-self.reelsTableView.bounds.size.height {
            
            
            print("end");
            
        }
        
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("willDisplay \(indexPath.row)")
        if let itemCell = cell as? ReelsTableViewCell {
            itemCell.playerView?.player?.pause()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("didEndDisPlaying \(indexPath.row)")
        
        if let itemCell = cell as? ReelsTableViewCell {
            itemCell.playerView?.player?.pause()
        }
        
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("!scrollViewDidEndDragging");
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true;
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if let indexPath = self.reelsTableView.indexPathForRow(at: CGPoint(x: scrollView.contentOffset.x, y: (scrollView.contentOffset.y + scrollView.frame.height) ))
        {
            print("Current cell \(indexPath.row)")
            if let itemCell = self.reelsTableView.cellForRow(at: indexPath) as? ReelsTableViewCell{
                itemCell.playerView.player?.play();
            }
            
            if(indexPath.row > 0){
                self.reelsTableView.reloadRows(at: [IndexPath(row: (indexPath.row - 1), section: 0)], with: .fade)
            }
            
        }
        
        
        //        for cell in self.reelsTableView.visibleCells {
        //            let indexPath = self.reelsTableView.indexPath(for: cell)
        //            let cellItem = self.reelsTableView.cellForRow(at: indexPath!) as! ReelsTableViewCell;
        //            if(!cellItem.playerView.isplayBoolean){
        //                cellItem.playerView.player?.play()
        //                cellItem.playerView.isPlaying = true;
        //            }else{
        //                cellItem.playerView.player?.pause()
        //                cellItem.playerView.isPlaying = false;
        //            }
        //        }
    }
    
    
    
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        print("scrollContentsOFfset \(targetContentOffset.pointee.y)");
        
        if let indexPath = self.reelsTableView.indexPathForRow(at: CGPoint(x: scrollView.contentOffset.x, y: (scrollView.contentOffset.y + scrollView.frame.height) ))
        {
            
            DispatchQueue.main.async {
                
                //                if abs(velocity.y) > abs(velocity.x) {
                //                    if(velocity.y < 0){
                //                        print("up");
                //                        self.reelsTableView.reloadRows(at: [IndexPath(row: (indexPath.row  + 1), section: 0)], with: .fade)
                //
                //                    }else{
                //                        print("down");
                //                        self.reelsTableView.reloadRows(at: [IndexPath(row: (indexPath.row - 1 ), section: 0)], with: .fade)
                //                    }
                //                }
                //                if let itemCell = self.reelsTableView.cellForRow(at: indexPath) as? ReelsTableViewCell{
                //                    itemCell.playerView.player?.play();
                //                }
                
                
            }
            
        }
    }
    
    
}
