//
//  FileCollectionViewCell.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/08/06.
//

import UIKit
import AVKit

class PlayerViewClass : UIView{
            
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



class ClubListFileCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var videoPlayerView: PlayerViewClass!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    override func prepareForReuse() {
        
        self.videoPlayerView.player = nil
        self.videoPlayerView.playerLayer.player = nil
        self.imageView.image = nil;
    }
}
