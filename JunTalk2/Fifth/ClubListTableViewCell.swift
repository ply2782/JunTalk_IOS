//
//  ClubListTableViewCell.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/08/06.
//

import UIKit
import Kingfisher
import AVFoundation
import Alamofire

class ClubListTableViewCell: UITableViewCell {
    
    @IBOutlet var blockButton: UIButton!
    @IBOutlet weak var fileCollectionView: UICollectionView!
    @IBOutlet weak var joinViewLabel: UILabel!
    @IBOutlet weak var joinView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsLabel: UILabel!
    @IBOutlet weak var possibleJoinCountLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var expectedMoney: UILabel!
    @IBOutlet weak var possibleJoinAge: UILabel!
    let cornerImageProcessor = RoundCornerImageProcessor(cornerRadius: 30)
    let retryStrategy = DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(3))
    var clickDelegate : FourthViewControllerClickProtocal!
    var fileInfoArray :[String] = [];
    var indexPath : IndexPath!;
    var myModel : UserData!;
    var clickInterface : ClickInterface!
    var clubItems : Dictionary<String, Any> = [:];
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        blockButton.setTitle("", for: .normal);
        self.fileCollectionView.delegate = self;
        self.fileCollectionView.dataSource = self;
        self.fileCollectionView.register(UINib(nibName: "ClubListFileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ClubListFileCollectionViewCell")
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(imageTapped))
        self.joinView.isUserInteractionEnabled = true
        self.joinView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    
    @objc private func imageTapped() {
        clickInterface.isClick(clubItems: clubItems);
    }
        
    @IBAction func blockClubList(_ sender: Any) {
        clickDelegate.blockClickItem(index: indexPath.row);
        
    }
    
    func checkVideoFrameVisibility(ofCell cell: ClubListFileCollectionViewCell) -> Bool {
        var cellRect = cell.videoPlayerView.bounds
        cellRect = cell.videoPlayerView.convert(cell.videoPlayerView.bounds, to: superview)
        return frame.contains(cellRect)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0))
        self.joinViewLabel.layer.zPosition = 1;
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
        // gradient를 layer 전체에 적용해주기 위해 범위를 0.0 ~ 1.0으로 설정
        gradient.locations = [0.0, 1.0]
        // gradient 방향을 x축과는 상관없이 y축의 변화만 줌
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.cornerRadius = 0
        gradient.frame = self.joinView.bounds;
        self.joinView.layer.addSublayer(gradient)
        self.joinView.layer.frame.size.width = UIScreen.main
            .bounds.width;
        
    }
}

extension ClubListTableViewCell : UICollectionViewDataSource , UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
