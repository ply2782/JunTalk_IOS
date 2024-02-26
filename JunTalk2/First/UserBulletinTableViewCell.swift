//
//  UserBulletinTableViewCell.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/09/09.
//

import UIKit
import Kingfisher
import AVFoundation


class UserBulletinTableViewCell: UITableViewCell {
    
    @IBOutlet var fileView: UIView!
    @IBOutlet var personImageView: UIImageView!
    @IBOutlet var contentsLabel: UILabel!
    @IBOutlet var menuButton: UIButton!
    @IBOutlet var nicknameLabel: UILabel!
    @IBOutlet var messageCount: UILabel!
    @IBOutlet var likeCountLabel: UILabel!
    @IBOutlet var fileCollectionView: UICollectionView!
    @IBOutlet var regDateLabel: UILabel!
    let cornerImageProcessor = RoundCornerImageProcessor(cornerRadius: 30)
    let retryStrategy = DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(3))
    var fileInfoArray :[String] = [];
    var currentClickRow: IndexPath = [];
    var clickDelegate : FourthViewControllerClickProtocal!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        menuButton.setTitle("", for: .normal)
        fileCollectionView.dataSource = self;
        fileCollectionView.delegate = self;
        fileCollectionView.register(UINib(nibName: "ClubListFileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ClubListFileCollectionViewCell")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func blockMenuAction(_ sender: Any) {
        
        clickDelegate.blockClickItem(index: currentClickRow.row);
        
    }
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        fileCollectionView.reloadData();
        personImageView.image = nil;
        contentsLabel.text = nil;
        nicknameLabel.text = nil;
        messageCount.text = nil;
        likeCountLabel.text = nil;
        regDateLabel.text = nil;
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
}


extension UserBulletinTableViewCell : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // 선택 안한 부분 스타일 커스텀
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        
    }
    
    //  선택 한 부분 스타일 커스텀
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fileInfoArray.count;
        
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClubListFileCollectionViewCell", for: indexPath) as! ClubListFileCollectionViewCell
        
        cell.imageView.isHidden = false;
        cell.videoPlayerView.isHidden = false;
        
        
        
        let fileArrayurl = self.fileInfoArray[indexPath.row];
        
        if(fileArrayurl.contains(".mp4")){
            cell.imageView.isHidden = true;
            cell.videoPlayerView.isHidden = false;
            
            let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/videoController/stream/\(fileArrayurl)");
            
            let avPlayer = AVPlayer(url: url!);
            cell.videoPlayerView.playerLayer.player = avPlayer;
            cell.videoPlayerView.player?.play();
            cell.videoPlayerView.isPlaying = true;

            
        }else{
            
            cell.imageView.isHidden = false;
            cell.videoPlayerView.isHidden = true;
            
            let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/userController/profileImageShow?imageName=\(fileArrayurl)");
            
            cell.imageView?.kf.indicatorType = .activity
            cell.imageView?.kf.setImage(
                with: url,
                placeholder: nil,
                options: [
                    .retryStrategy(retryStrategy),
                    .transition(.fade(1.2)),
                    .forceTransition,
                    .processor(cornerImageProcessor)
                ],
                completionHandler: nil)
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("willDisplay: \(indexPath.row)")
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let cellItem = self.fileCollectionView.cellForItem(at: indexPath) as! ClubListFileCollectionViewCell;
        cellItem.videoPlayerView.player?.pause();
        cellItem.videoPlayerView.isPlaying = false;
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewWidth = collectionView.bounds.width
        let collectionViewHeight = collectionView.bounds.height
        return CGSize(width: collectionViewWidth, height: collectionViewHeight)
    }
    
    // CollectionView Cell의 위아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1.0
    }
    
    // CollectionView Cell의 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1.0
    }
    
    //    스크롤 시 끝에 다다를떄
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.fileCollectionView.contentOffset.x > self.fileCollectionView.contentSize.width-self.fileCollectionView.bounds.size.width {
            print("end");
        }
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        print("scrollContentsOFfset \(targetContentOffset.pointee.x)");
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for cell in self.fileCollectionView.visibleCells {
            
            let indexPath = self.fileCollectionView.indexPath(for: cell)
            let cellItem = self.fileCollectionView.cellForItem(at: indexPath!) as! ClubListFileCollectionViewCell;
            
            if(!cellItem.videoPlayerView.isplayBoolean){
                cellItem.videoPlayerView.player?.play()
                cellItem.videoPlayerView.isPlaying = true;
            }else{
                cellItem.videoPlayerView.player?.pause()
                cellItem.videoPlayerView.isPlaying = false;
            }
        }
        
    }
}
