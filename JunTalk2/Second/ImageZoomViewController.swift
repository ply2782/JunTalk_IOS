//
//  ImageZoomViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/07/03.
//

import UIKit
import Kingfisher

class ImageZoomViewController: UIViewController , UIGestureRecognizerDelegate {
    @IBOutlet weak var imageView: UIImageView!    
    @IBOutlet weak var closeImageView: UIImageView!
    var imageUrl = URL(string : "");
    var pinch = UIPinchGestureRecognizer()
    var recognizerScale : CGFloat = 1.0
    var maxScale : CGFloat = 2.0
    var minScale : CGFloat = 1.0
    let cornerImageProcessor = RoundCornerImageProcessor(cornerRadius: 30)
    let retryStrategy = DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(3))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.doPinch(_:)))
        self.view.addGestureRecognizer(pinch)
        tapOriginal();
        
        
        self.imageView.layer.borderColor = UIColor.clear.cgColor
        self.imageView.clipsToBounds = true
        self.imageView.layer.cornerRadius = 20
        self.imageView?.kf.indicatorType = .activity
        self.imageView?.kf.setImage(
            with: imageUrl,
            placeholder: nil,
            options: [
                .retryStrategy(retryStrategy),
                .transition(.fade(1.2)),
                .forceTransition,
                .processor(cornerImageProcessor)
            ],
            completionHandler: nil)
        
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(closeTapped))
        self.closeImageView.isUserInteractionEnabled = true
        self.closeImageView.addGestureRecognizer(tapGestureRecognizer)
        
        
    }
    
    @objc private func closeTapped(){
        dismiss(animated: true , completion: nil)
    }
    
    @objc func doPinch(_ pinch : UIPinchGestureRecognizer){
        
        
        
        if pinch.state == .began || pinch.state == .changed{
            
            if(recognizerScale < maxScale && pinch.scale > 1.0){
                imageView.transform = (imageView.transform).scaledBy(x: pinch.scale, y: pinch.scale)
                recognizerScale *= pinch.scale
                pinch.scale = 1.0
            }
            else if(recognizerScale > minScale && pinch.scale < 1.0){
                imageView.transform = (imageView.transform).scaledBy(x: pinch.scale, y: pinch.scale)
                
                recognizerScale *= pinch.scale
                pinch.scale = 1.0
                
            }
        }
    }
    
    
    func tapOriginal (){        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tapGR.delegate = self
        tapGR.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(tapGR)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer){
        imageView.transform = CGAffineTransform.identity
        recognizerScale = 1.0
    }
    
}
