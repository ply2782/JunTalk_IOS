//
//  RequestInsertViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/09/11.
//

import UIKit
import Alamofire


class RequestInsertViewController: UIViewController {

    var myModel : UserData!;
    @IBOutlet var requestTextView: UITextView!
    
    var refreshRequestProtocalDelegate : RefreshRequestProtocal!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestTextView.delegate = self;
        requestTextView.text = "건의사항을 입력해주세요."
        requestTextView.textColor = UIColor.lightGray
        requestTextView.sizeToFit()
        
        let data = UserDefaults.standard.object(forKey: "myModel")
        if(data != nil){
            let decoder = JSONDecoder()
            self.myModel = try? decoder.decode(UserData.self, from: data as! Data)
        }
        
     
    }
    
    
    func sendRequestQuestionList(user_Index : Int? , userId : String? , requestContent : String? ){
        
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/commonNoticeController/sendRequestQuestionList"
        
        let param: Parameters = [
            "user_Index": user_Index! as Any,
            "userId": userId! as Any,
            "requestContent" : requestContent! as Any,
        ];
        
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).response{ response in
            switch response.result {
            case .success:
                self.refreshRequestProtocalDelegate.refresh();
                self.dismiss(animated: true, completion: nil)
                
                return
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    
    @IBAction func uploadRequestAction(_ sender: Any) {
        let requestContents = requestTextView.text;
        self.sendRequestQuestionList(user_Index: myModel.user_Index , userId: myModel.userId, requestContent: requestContents)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true);
    }
}




extension RequestInsertViewController : UITextViewDelegate{
    
    // TextView Place Holder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "정보를 입력해주세요."
            textView.textColor = UIColor.lightGray
        }
    }
    
}
