//
//  ReportViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/06/12.
//

import UIKit
import DLRadioButton
import Alamofire


protocol DismissBlockDialog : AnyObject{
    func dismissBlockDialogSelf();
}

class ReportViewController: UIViewController {
    
    var reelsModel : ReelsModel!;
    var whatType : String? = "";
    weak var dismissBlockDialogSelf: DismissBlockDialog?
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    var reportReason:String? = "";
    weak var delegate: AddViewControllerDelegate?
    var myModel : UserData!;
    var personUserIndex :Int = 0;
    var personUserId :String = "";
    var bulletinBoardModel : Dictionary<String, Any> = [:];
    var clubListModel : Dictionary<String, Any> = [:];
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.layer.borderWidth = 2
        cancelButton.layer.borderColor = UIColor.black.cgColor
        cancelButton.layer.cornerRadius = 10
        
        reportButton.layer.borderWidth = 2
        reportButton.layer.borderColor = UIColor.black.cgColor
        reportButton.layer.cornerRadius = 10
    }
    
    @IBAction func firstButton(_ sender: Any) {
        reportReason = "부적절한 사진 및 동영상"
    }
    
    @IBAction func secondButton(_ sender: Any) {
        reportReason = "선정적 / 폭력적 사진 및 동영상"
    }
    @IBAction func thirdButton(_ sender: Any) {
        reportReason = "불쾌감을 자극하는 잔인한 사진 및 동영상"
    }
    
    @IBAction func fourthButton(_ sender: Any) {
        reportReason = "기타 부적절한 사진 및 동영상"
    }
    
    
    @IBAction func reportButton(_ sender: Any) {
        if(reportReason == ""){
            showToast(message: "사유를 선택해 주세요.")
            
        }else{
            
            if(whatType == "bulletinBoard"){
                
                blockBulletinBoard(bulletin_Uuid: bulletinBoardModel["bulletin_Uuid"] as! String, category: bulletinBoardModel["category"] as! String, user_Index: myModel.user_Index, userId: myModel.userId, bulletin_UserId: personUserId, isBlock: true, blockReportContent: reportReason);
                
            }else if(whatType == "clubList"){
                
                
                blockClubList(club_Uuid: clubListModel["club_Uuid"] as! String, blockReportContent: reportReason, user_Index: clubListModel["user_Index"] as! Int, userId: clubListModel["userId"] as! String as! String);
                
            }else if (whatType == "ReelsList") {
                
                blockReelsList(reelsModel: reelsModel, blockReportContent: reportReason, user_Index: myModel.user_Index)
                
            }else{
                
                blockUser(fromUser_Index: myModel.user_Index, fromUser: myModel.userId, user_Index: personUserIndex, userId: personUserId, blockReason: reportReason)
            }
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
                
                self.delegate?.willDissmiss()
                self.dismissBlockDialogSelf?.dismissBlockDialogSelf();
                self.dismiss(animated: true, completion: nil)
                
                return
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    
    func blockUser(fromUser_Index : Int? , fromUser : String? , user_Index : Int?, userId : String? , blockReason : String?){
        
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/userController/blockReportUser"
        
        let param: Parameters = [
            "fromUser_Index": fromUser_Index! as Any,
            "fromUser":fromUser! as Any,
            "user_Index" : user_Index! as Any,
            "userId" : userId! as Any,
            "blockReportContent" : blockReason! as Any,
        ];
        
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).response{ response in
            switch response.result {
            case .success:
                
                
                self.delegate?.willDissmiss()
                self.dismissBlockDialogSelf?.dismissBlockDialogSelf();
                self.dismiss(animated: true, completion: nil)
                
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
                self.dismissBlockDialogSelf?.dismissBlockDialogSelf();
                self.dismiss(animated: true, completion: nil)
                return
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    
    
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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

