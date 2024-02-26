//
//  BlockDialogViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/05/01.
//

import UIKit
import Alamofire


protocol AddViewControllerDelegate: AnyObject {
    func willDissmiss()
}

class BlockDialogViewController: UIViewController, DeliverData {
    
    func deliverData(type: String) {
        print("blockDialogViewController Protocal \(type)");
    }
    
    var bulletinBoardModel : Dictionary<String, Any> = [:];
    var reelsModel : ReelsModel!;
    weak var delegate: AddViewControllerDelegate?
    
    let myUserDefaults = UserDefaults.standard;
    var myModel : UserData!;
    var tableView: UITableView?
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var cacnelButton: UIButton!
    @IBOutlet weak var blockButton: UIButton!
    var personUserIndex :Int = 0;
    var personUserId :String = "";
    var whatType : String? = "";
    var firstViewController = FirstViewController();
    var clubListModel : Dictionary<String, Any> = [:];
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        let data = UserDefaults.standard.object(forKey: "myModel")
        if(data != nil){
            let decoder = JSONDecoder()
            self.myModel = try? decoder.decode(UserData.self, from: data as! Data)
        }
        
        cacnelButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        self.setupTranstion();
    }
    
    
    private func setupTranstion() {
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    
    @IBAction func reportClick(_ sender: Any) {
        
        if(whatType == "bulletinBoard"){
            
            blockBulletinBoard(bulletin_Uuid: bulletinBoardModel["bulletin_Uuid"] as! String, category: bulletinBoardModel["category"] as! String, user_Index: myModel.user_Index, userId: myModel.userId, bulletin_UserId: personUserId, isBlock: true, blockReportContent: "null");
            
            
        }else if(whatType == "clubList"){
            
            
            blockClubList(club_Uuid: clubListModel["club_Uuid"] as! String, blockReportContent: "null", user_Index: clubListModel["user_Index"] as! Int, userId: clubListModel["userId"] as! String);
            
        }else if (whatType == "ReelsList") {
                                    
            blockReelsList(reelsModel: reelsModel, blockReportContent: "null", user_Index: myModel.user_Index)
            
        }else{
        
            blockUser(fromUser_Index: myModel.user_Index, fromUser: myModel.userId, user_Index: personUserIndex, userId: personUserId)
            
        }
                
        
    }
    
    
    func blockReelsList(reelsModel : ReelsModel , blockReportContent : String? , user_Index : Int?){
        
        
        print("reelsModel \(reelsModel)");
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/bulletinBoardController/blockReportJunes"
        
        let param: Parameters = [
            "lils_Index" : reelsModel.lils_Index as Any,
            "fromUser_Index" : user_Index! as Any,
            "lils_Uuid": reelsModel.lils_Uuid! as Any,
            "blockReportContent" : blockReportContent! as Any,
            "user_Index" : reelsModel.user_Index! as Any,
            "userId" : reelsModel.userId! as Any
        ];
        
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).response{ response in
            switch response.result {
            case .success:
                
                NotificationCenter.default.post(name: .ReelsRefresh, object: nil)
                
                return
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    
    func blockClubList(reelsModel : ReelsModel , blockReportContent : String? , user_Index : Int?){
        
        
        print("reelsModel \(reelsModel)");
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/clubController/blockClubList"
        
        let param: Parameters = [
            "lils_Index" : reelsModel.lils_Index as Any,
            "fromUser_Index" : user_Index! as Any,
            "lils_Uuid": reelsModel.lils_Uuid! as Any,
            "blockReportContent" : blockReportContent! as Any,
            "user_Index" : reelsModel.user_Index! as Any,
            "userId" : reelsModel.userId! as Any
        ];
        
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).response{ response in
            switch response.result {
            case .success:
                
                NotificationCenter.default.post(name: .ReelsRefresh, object: nil)
                
                return
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    
    
    @IBAction func blockClick(_ sender: Any) {
        
        guard let reviewModalViewController = self.storyboard?.instantiateViewController(withIdentifier: "ReportViewController") as? ReportViewController else {
            return
        }
        reviewModalViewController.modalPresentationStyle = .custom
        reviewModalViewController.transitioningDelegate = self
        reviewModalViewController.delegate = self.delegate;
        reviewModalViewController.myModel = self.myModel
        reviewModalViewController.whatType = self.whatType;
        reviewModalViewController.bulletinBoardModel = self.bulletinBoardModel;
        reviewModalViewController.clubListModel = self.clubListModel;
        reviewModalViewController.reelsModel = self.reelsModel;
        reviewModalViewController.personUserId = self.personUserId
        reviewModalViewController.personUserIndex = self.personUserIndex
        reviewModalViewController.dismissBlockDialogSelf = self;
        self.present(reviewModalViewController, animated: true, completion: nil)
        
    }
    
    
    
    
    @objc func dismissView(){        
        dismiss(animated: true , completion: nil)
    }
    
    
    func blockClubList(club_Uuid : String? , blockReportContent : String? , user_Index:Int?, userId : String? ){
        
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/clubController/blockClubList"
        
        let param: Parameters = [
            "club_Uuid": club_Uuid! as Any,
            "blockReportContent" : blockReportContent! as Any,
            "user_Index" : user_Index! as Any,
            "userId" : userId! as Any
        ];
        
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).response{ response in
            switch response.result {
            case .success:
                
                
                NotificationCenter.default.post(name: .MyClubListViewControllerRefresh, object: nil)
                
                NotificationCenter.default.post(name: .CalendarDetailViewControllerRefresh, object: nil)
                
                
                
                
                return
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    
    
    func blockBulletinBoard(bulletin_Uuid : String? , category : String? , user_Index : Int?, userId : String? , bulletin_UserId : String? ,isBlock: Bool? , blockReportContent: String? ){
        
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/bulletinBoardController/blockBulletinBoard"
        
        let param: Parameters = [
            "bulletin_Uuid" : bulletin_Uuid! as Any,
            "category" : category! as Any,
            "bulletin_UserId" : bulletin_UserId! as Any,
            "isBlock" : isBlock! as Any,
            "blockReportContent" : blockReportContent! as Any,
            "user_Index" : user_Index! as Any,
            "userId" : userId! as Any
        ];
        
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).response{ response in
            switch response.result {
            case .success:
                
                NotificationCenter.default.post(name: .FourthViewControllerRefresh, object: nil)
                
                NotificationCenter.default.post(name: .UserBulletinBoardViewControllerRefresh, object: nil)
                
                
                self.delegate?.willDissmiss()
                self.dismiss(animated: true, completion: nil)
                return
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    
    func blockUser(fromUser_Index:Int? , fromUser:String? , user_Index:Int?, userId:String? ){
        
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/userController/blockUser"
        
        let param: Parameters = [
            "fromUser_Index": fromUser_Index! as Any,
            "fromUser":fromUser! as Any,
            "user_Index" : user_Index! as Any,
            "userId" : userId! as Any
        ];
        
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).response{ response in
            switch response.result {
            case .success:
                self.firstViewController.deliverData(type: "bbbb");
                self.delegate?.willDissmiss()
                self.dismiss(animated: true, completion: nil)
                
                return
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0)) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 10.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}



extension BlockDialogViewController: UIViewControllerTransitioningDelegate {
    
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}


extension BlockDialogViewController : DismissBlockDialog{
    func dismissBlockDialogSelf() {
        
        showToast(message: "신고가 접수되었습니다.");
        dismiss(animated: true, completion: nil)
    }
}
