//
//  SideMenuViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/06/01.
//

import UIKit
import Lottie
import KakaoSDKCommon
import Alamofire
import KakaoSDKAuth
import KakaoSDKUser

class SideMenuViewController: UIViewController {
    
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var showPolicyButton: UIButton!
    @IBOutlet weak var showLibraryButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var joinOutButton: UIButton!
    @IBOutlet weak var lottieImageView: UIImageView!
    @IBOutlet weak var closeButton: UIImageView!
    @IBOutlet weak var myPictureImageView: UIImageView!
    @IBOutlet weak var myNickNameLabel: UILabel!
    
    var myModel : UserData!;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let data = UserDefaults.standard.object(forKey: "myModel")
        if(data != nil){
            let decoder = JSONDecoder()
            self.myModel = try? decoder.decode(UserData.self, from: data as! Data)
        }
        
        let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/userController/profileImageShow?imageName=\(myModel.userMainPhoto)");
        
        self.myPictureImageView.load(url: url!)
        self.myNickNameLabel.text = myModel.userId
        
        self.myPictureImageView.layer.cornerRadius = self.myPictureImageView.frame.height/2
        self.myPictureImageView.layer.borderWidth = 1
        self.myPictureImageView.layer.borderColor = UIColor.clear.cgColor
        self.myPictureImageView.clipsToBounds = true
        
        
        
        let animationView = AnimationView(name:"ice-cream-bowl-loading")
        lottieImageView.addSubview(animationView)
        animationView.frame = animationView.superview!.bounds
        animationView.contentMode = .scaleAspectFit
        //애니메이션 재생(애니메이션 재생모드 미 설정시 1회)
        animationView.play()
        //애니메이션 재생모드( .loop = 애니메이션 무한재생)
        animationView.loopMode = .loop
        
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(imageTapped))
        self.closeButton.isUserInteractionEnabled = true
        self.closeButton.addGestureRecognizer(tapGestureRecognizer)
        
        let lottieTapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(moveToPayViewController))
        lottieImageView.isUserInteractionEnabled = true
        lottieImageView.addGestureRecognizer(lottieTapGestureRecognizer)
        
    }
    
    
    
    
    @objc private func moveToPayViewController() {
        guard let payViewController = self.storyboard?.instantiateViewController(withIdentifier: "StoreViewController") else {
            return
        }
        //화면 전환 애니메이션을 설정합니다. coverVertical 외에도 다양한 옵션이 있습니다.
        payViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        //인자값으로 다음 뷰 컨트롤러를 넣고 present 메소드를 호출합니다.
        self.present(payViewController, animated: true)
        
    }
    
    
    @objc private func imageTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func JoinOut(_ sender: Any) {
        NotificationCenter.default.post(name: .joinOutRefresh, object: nil)
        self.dismiss(animated: true);
    }
    
    @IBAction func LogOut(_ sender: Any) {
        NotificationCenter.default.post(name: .logOutRefresh, object: nil)
        self.dismiss(animated: true);                
    }
    
    @IBAction func ShowLibrary(_ sender: Any) {
        print("ShowLibrary");
    }
    
    @IBAction func ShowPolicy(_ sender: Any) {
        print("ShowPolicy");
    }
    
    @IBAction func Question(_ sender: Any) {
        print("Question");
        //storyboard를 통해 두번쨰 화면의 storyboard ID를 참조하여 뷰 컨트롤러를 가져옵니다.
        guard let requestViewController = self.storyboard?.instantiateViewController(withIdentifier: "RequestViewController") else {
            return
        }
        //화면 전환 애니메이션을 설정합니다. coverVertical 외에도 다양한 옵션이 있습니다.
        requestViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        //인자값으로 다음 뷰 컨트롤러를 넣고 present 메소드를 호출합니다.
        self.present(requestViewController, animated: true)
    }
    
    
    
}
