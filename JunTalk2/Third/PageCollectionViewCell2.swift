//
//  PageCollectionViewCell.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/05/10.
//

import UIKit
import Kingfisher
import AVKit
import Alamofire


extension Notification.Name {
    static let videoRefresh = Notification.Name("videoRefresh");
}


class PageCollectionViewCell2: UICollectionViewCell {
    
    
    var clickVideoIndexItem : ClickVideoIndexItem!
    @IBOutlet weak var videoListTableView: UITableView!
    var isPaging: Bool = false // 현재 페이징 중인지 체크하는 flag
    var hasNextPage: Bool = false // 마지막 페이지 인지 체크 하는 flag
    var videoListData : [Dictionary<String,Any>] = [];
    var pageNum :Int = 0;
    let cornerImageProcessor = RoundCornerImageProcessor(cornerRadius: 30)
    let retryStrategy = DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(3))
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoListData.removeAll();
        
        self.videoListTableView.delegate = self
        self.videoListTableView.dataSource = self
        pagingVideoList(page: pageNum);
        self.videoListTableView.tableFooterView = UIView(frame: .zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNotification), name: .videoRefresh, object: nil)
        
    }
    
    @objc func refreshNotification() {
        videoListData.removeAll();
        pagingVideoList(page: 0);
    }
    
    
    
    func paging() {
        if(self.videoListData.count > (10 * pageNum)){
            pageNum += 1;
            pagingVideoList(page: pageNum);
        }
    }
    
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async { //1
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbNailImage = UIImage(cgImage: cgThumbImage) //7
                DispatchQueue.main.async { //8
                    completion(thumbNailImage) //9
                }
            } catch {
                print(error.localizedDescription) //10
                DispatchQueue.main.async {
                    completion(nil) //11
                }
            }
        }
    }
    
    
    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    
    
    func createVideoThumbnail( url: String?,  completion: @escaping ((_ image: UIImage?)->Void)) {
        
        guard let url = URL(string: url ?? "") else { return }
        DispatchQueue.global().async {
            
            let url = url as URL
            let request = URLRequest(url: url)
            let cache = URLCache.shared
            
            if
                let cachedResponse = cache.cachedResponse(for: request),
                let image = UIImage(data: cachedResponse.data)
            {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            
            let asset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            var time = asset.duration
            time.value = min(time.value, 2)
            
            var image: UIImage?
            
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                image = UIImage(cgImage: cgImage)
            } catch { DispatchQueue.main.async {
                completion(nil)
            } }
            
            if
                let image = image,
                let data = image.pngData(),
                let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            {
                let cachedResponse = CachedURLResponse(response: response, data: data)
                
                cache.storeCachedResponse(cachedResponse, for: request)
            }
            
            DispatchQueue.main.async {
                completion(image)
            }
            
        }
        
    }
    
    
    
    
    func pagingVideoList(page : Int?){
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/videoController/video/null";
        let param: Parameters =
        [
            "pageNum" : page! as Any,
        ];
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).response{ response in
            switch response.result {
            case .success:
                do{
                    if let jsonArray = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [Dictionary<String,Any>] {
                        
                        for item in jsonArray{
                            self.videoListData.append(item);
                        }
                        self.isPaging = false // 페이징이 종료 되었음을 표시
                        self.videoListTableView.reloadData();
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


class VideoCell : UITableViewCell{
    
    @IBOutlet weak var videoThumbNailImageView: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        videoThumbNailImageView.image = nil;
        videoTitleLabel.text = nil;
    }
    
}

extension PageCollectionViewCell2 : UITableViewDataSource ,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoListData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let videoCell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as? VideoCell else {
            return UITableViewCell();
        }
        videoCell.videoTitleLabel.text = self.videoListData[indexPath.row]["videoName"] as? String;
        
        
        let folderName = self.videoListData[indexPath.row]["folderName"]!;
        let videoName = self.videoListData[indexPath.row]["videoName"]!;
        
        videoCell.videoThumbNailImageView.clipsToBounds = true
        videoCell.videoThumbNailImageView.layer.cornerRadius = videoCell.videoThumbNailImageView.frame.height/2
        videoCell.videoThumbNailImageView?.kf.indicatorType = .activity
        if let encoded = "http://ply2782ply2782.cafe24.com:8080/videoController/videoThumbNail?imageName=\(folderName)/\(videoName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let myURL = URL(string: encoded) {
        
            videoCell.videoThumbNailImageView.kf.setImage(with: AVAssetImageDataProvider(assetURL: myURL, seconds: 1))
            }
        
        return videoCell;
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let folderName = self.videoListData[indexPath.row]["folderName"]!;
        let videoName = self.videoListData[indexPath.row]["videoName"]!;
        
        
        clickVideoIndexItem.clickItemRow(index: indexPath.row, videoName: videoName as! String , folderName: folderName as! String)
    }
}

extension PageCollectionViewCell2 {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentOffset_y = scrollView.contentOffset.y
        let tableViewContentSize = self.videoListTableView.contentSize.height
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
            self.videoListTableView.reloadSections(IndexSet(integer: 0), with: .none)
        }
        
        // 페이징 메소드 호출
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.paging()
        }
    }
}
