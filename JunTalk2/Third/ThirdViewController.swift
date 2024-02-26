//
//  ThirdViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/05/08.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation
import AVKit

protocol ClickIndexItem {
    func clickItemRow(index: Int? , musicName : String?);
}

protocol ClickVideoIndexItem {
    func clickItemRow(index: Int? , videoName : String? , folderName : String?);
}

class ThirdViewController : UIViewController , ClickIndexItem , ClickVideoIndexItem {
    
   
    
    var myModel : UserData!;
    var clickVideoIndexItem : ClickVideoIndexItem!;
    var clickProtocal : ClickIndexItem?;
    @IBOutlet weak var topTabCollectionView: UICollectionView!
    @IBOutlet weak var pageCollectionView: UICollectionView!
    var arrTitle: [String] = ["음악","동영상"]
    var pageNum = 0;
    var musicListData : [Dictionary<String,Any>] = [];
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createFileSegue"{
            if let destination = segue.destination as?
                CreateMediaFileViewController {
                destination.userId = myModel.userId;                
            }
        }
    }
    
    func clickItemRow(index: Int? , videoName : String? , folderName : String?) {
        
        
        if let encoded = "http://ply2782ply2782.cafe24.com:8080/videoController/videoThumbNail?imageName=\(folderName!)/\(videoName!)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let myURL = URL(string: encoded) {
        
            // AVPlayerController의 인스턴스 생성
            let playerController = AVPlayerViewController()
            // 비디오 URL로 초기화된 AVPlayer의 인스턴스 생성
            let player = AVPlayer(url: myURL)
            // AVPlayerViewController의 player 속성에 위에서 생성한 AVPlayer 인스턴스를 할당
            playerController.player = player
            self.present(playerController, animated: true){
                player.play() // 비디오 재생
            }
        }
    }
    
    
    func clickItemRow(index: Int? , musicName : String?) {
        let musicViewController = self.storyboard?.instantiateViewController(withIdentifier: "MusicViewController") as! MusicViewController
        musicViewController.modalPresentationStyle = .overCurrentContext
        musicViewController.modalTransitionStyle = .crossDissolve
        musicViewController.musicName = musicName!
        musicViewController.musicFolder = musicName!
        self.present(musicViewController, animated: false, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let data = UserDefaults.standard.object(forKey: "myModel")
        if(data != nil){
            let decoder = JSONDecoder()
            self.myModel = try? decoder.decode(UserData.self, from: data as! Data)
        }
        self.topTabCollectionView.delegate  = self;
        self.topTabCollectionView.dataSource = self;
        self.pageCollectionView.delegate = self;
        self.pageCollectionView.dataSource = self;
        self.pageCollectionView.isScrollEnabled = false
        self.clickProtocal = self;
        self.clickVideoIndexItem = self;
        
        
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
    
    
    
}


extension ThirdViewController : UICollectionViewDataSource , UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    
    
    // 선택 안한 부분 스타일 커스텀
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? TabBarCollectionViewCell else {return}
        cell.titleLabel.textColor = .lightGray
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(indexPath.row == 0){
            pageCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .right, animated: true)
        }else if(indexPath.row == 1){
            pageCollectionView.scrollToItem(at: IndexPath(item:1, section: 0), at: .right, animated: true)
        }
    }
    
    
    
    // CollectionView item 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == topTabCollectionView){
            return arrTitle.count
            
        }else if(collectionView == pageCollectionView){
            return arrTitle.count
            
        }
        return 0;
    }
    
    
    // CollectionView Cell의 Object
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == topTabCollectionView){
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TabBarCollectionViewCell", for: indexPath) as? TabBarCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.titleLabel.textColor = .lightGray
            cell.titleLabel.text = arrTitle[indexPath.row];
            if indexPath.item == 0 {
                cell.isSelected = true
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
            }
            return cell
            
            
        }else if(collectionView == pageCollectionView){
            
            if(indexPath.item == 0){
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PageCollectionViewCell", for: indexPath) as? PageCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.clickProtocal = self.clickProtocal;
                return cell
                
            }else{
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PageCollectionViewCell2", for: indexPath) as? PageCollectionViewCell2 else {
                    return UICollectionViewCell()
                }
                cell.clickVideoIndexItem = self.clickVideoIndexItem;
                return cell
            }
            
        }
        return UICollectionViewCell()
    }
    
    // CollectionView Cell의 Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(collectionView == topTabCollectionView){
            
            let width: CGFloat = collectionView.frame.width / 2 - 1.0
            let height : CGFloat = 50;
            return CGSize(width: width, height: height)
            
        } else if(collectionView == pageCollectionView){
            
            let width: CGFloat = collectionView.frame.width
            let height : CGFloat = collectionView.frame.height
            return CGSize(width: width, height: height)
            
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    // CollectionView Cell의 위아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if(collectionView == topTabCollectionView){
            return 1.0
        } else if(collectionView == pageCollectionView){
            return 1.0
        }
        return 0
    }
    
    // CollectionView Cell의 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if(collectionView == topTabCollectionView){
            return 1.0
        } else if(collectionView == pageCollectionView){
            return 1.0
        }
        return 0
    }
    
}
