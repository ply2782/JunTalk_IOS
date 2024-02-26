//
//  ReelsTableViewCell.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/08/09.
//

import UIKit
import AVKit
import SwiftUI

class ReelsPlayerViewClass : UIView{
    
    override static var layerClass: AnyClass{
        return AVPlayerLayer.self;
    }
    
    var playerLayer : AVPlayerLayer{
        return layer as! AVPlayerLayer;
    }
    var isplayBoolean : Bool = false;
    
    var isPlaying:Bool {
        
        get {
            return isplayBoolean;
        }
        
        set{
            isplayBoolean = newValue;
        }
    }
    
    var player : AVPlayer?{
        
        get{
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.playerLayer.player?.currentItem, queue: .main) { [weak self] _ in
                self?.playerLayer.player?.seek(to: CMTime.zero)
                self?.playerLayer.player?.play()
            }
            playerLayer.videoGravity = .resizeAspectFill;
            return playerLayer.player;
        }
        
        set{
            playerLayer.player = newValue;
        }
        
        
    }
}



class ReelsTableViewCell: UITableViewCell {
    
    let STATUS_HEIGHT = UIApplication.shared.statusBarFrame.size.height   // 상태바 높이
    
    /**
     # safeAreaTopInset
     - Note: 현재 디바이스의 safeAreaTopInset값 반환
     */
    func safeAreaTopInset() -> CGFloat {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let topPadding = window?.safeAreaInsets.top
            return topPadding ?? STATUS_HEIGHT
        } else {
            return STATUS_HEIGHT
        }
    }
    
    /**
     # safeAreaBottomInset
     - Note: 현재 디바이스의 safeAreaBottomInset값 반환
     */
    func safeAreaBottomInset() -> CGFloat {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom
            return bottomPadding ??  0.0
        } else {
            return 0.0
        }
    }
    
    
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var playerView: ReelsPlayerViewClass!
    @IBOutlet weak var wholeView: UIView!
    @IBOutlet weak var wholeViewHeight: NSLayoutConstraint!
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var nicknameLabel: UILabel!
    var indexPath : IndexPath!;
    var clickDelegate : ReelsViewControllerClickProtocal!
    var myIndex : Int = 0;
    var thisIndex : Int = 0;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        deleteButton.setTitle("", for: .normal)
        let wholeHeight = UIScreen.main.bounds.size.height;
        let safeAreaHeight = (safeAreaBottomInset() + safeAreaTopInset());
        self.wholeViewHeight.constant =  (wholeHeight - safeAreaHeight)
        
        let gradient: CAGradientLayer = CAGradientLayer()
        //        gradient.colors = [
        //            UIColor.white.withAlphaComponent(0.3).cgColor,
        //            UIColor.black.withAlphaComponent(0.6).cgColor]
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.clear.cgColor, UIColor.white.withAlphaComponent(0.2).cgColor, UIColor.white.withAlphaComponent(0.3).cgColor,  UIColor.white.withAlphaComponent(0.4).cgColor]
        // gradient를 layer 전체에 적용해주기 위해 범위를 0.0 ~ 1.0으로 설정
        gradient.locations = [0.0, 0.3, 0.5, 0.7, 1.0]
        //        gradient.locations = [0.0, 1.0]
        // gradient 방향을 x축과는 상관없이 y축의 변화만 줌
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        self.contentStackView.clipsToBounds = true
        self.contentStackView.layer.cornerRadius = 10
        self.contentStackView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
        gradient.frame = self.contentStackView.bounds;
        self.contentStackView.layer.addSublayer(gradient)
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        
        
        
        if(myIndex == thisIndex){
            
            clickDelegate.deleteClickItem(index: indexPath.row);
            
            
        }else{
            
            clickDelegate.blockClickItem(index: indexPath.row);
            
        }
        
    }
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.replyLabel.text = nil;
        self.likeLabel.text = nil;
        self.contentTextView.text = nil;
        self.nicknameLabel.text = nil;
        self.playerView.player?.pause();
        self.playerView.player = nil;
        self.playerView.isPlaying = false;
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
