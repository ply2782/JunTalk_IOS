//
//  StoreViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/10/23.
//

import UIKit
import Lottie
import StoreKit

public struct InAppProducts {
    public static let product = "JunTalkOnce"
    private static let productIdentifiers: Set<ProductIdentifier> = [InAppProducts.product]
    public static let store = IAPHelper(productIds: InAppProducts.productIdentifiers)
}


class StoreViewController: UIViewController {
    
    @IBOutlet var closeImageView: UIImageView!
    @IBOutlet var subLottieImageView: UIImageView!
    @IBOutlet var monthPayImageView: UIImageView!
    @IBOutlet var onedayPayImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
             
        
        let animationView = AnimationView(name:"envelop")
        onedayPayImageView.addSubview(animationView)
        animationView.frame = animationView.superview!.bounds
        animationView.contentMode = .scaleAspectFit
        //애니메이션 재생(애니메이션 재생모드 미 설정시 1회)
        animationView.play()
        //애니메이션 재생모드( .loop = 애니메이션 무한재생)
        animationView.loopMode = .loop
        
        
        let animationView2 = AnimationView(name:"envelop")
        monthPayImageView.addSubview(animationView2)
        animationView2.frame = animationView2.superview!.bounds
        animationView2.contentMode = .scaleAspectFit
        //애니메이션 재생(애니메이션 재생모드 미 설정시 1회)
        animationView2.play()
        //애니메이션 재생모드( .loop = 애니메이션 무한재생)
        animationView2.loopMode = .loop
        
        
        let subAnimationView = AnimationView(name:"starwithastrount")
        subLottieImageView.addSubview(subAnimationView)
        subAnimationView.frame = subAnimationView.superview!.bounds
        subAnimationView.contentMode = .scaleAspectFit
        subAnimationView.play()
        subAnimationView.loopMode = .loop
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(imageTapped))
        closeImageView.isUserInteractionEnabled = true
        closeImageView.addGestureRecognizer(tapGestureRecognizer)
        
        
        let oneDayClickPay = UITapGestureRecognizer(target:self, action:#selector(oneDayPayClick))
        onedayPayImageView.isUserInteractionEnabled = true
        onedayPayImageView.addGestureRecognizer(oneDayClickPay)
        
        
        let oneMonthClickPay = UITapGestureRecognizer(target:self, action:#selector(oneMonthPayClick))
        monthPayImageView.isUserInteractionEnabled = true
        monthPayImageView.addGestureRecognizer(oneMonthClickPay)
        
    }
    
    @objc private func imageTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @objc private func oneDayPayClick() {
        

    }
    
    @objc private func oneMonthPayClick() {
    
    }
    
}
