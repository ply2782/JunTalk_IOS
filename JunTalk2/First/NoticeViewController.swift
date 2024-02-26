//
//  NoticeViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/05/22.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher


protocol NoticeItemClickInterface{
    func clickIndex(indexPath : IndexPath , status: Bool , realIndex : Int);
}


class NoticeViewController: UIViewController,
                            NoticeItemClickInterface {
    
    func clickIndex(indexPath: IndexPath , status : Bool , realIndex : Int) {
        
        selectedIndexArray[indexPath.row] = status;
        print("realIndex \(realIndex)");
        
    }
    
    var selectedIndexArray : [Int : Bool] = [:];
    
    @IBOutlet weak var noticeTableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    var noticeArray :[Dictionary<String,Any>] = [];
    let cornerImageProcessor = RoundCornerImageProcessor(cornerRadius: 20)
    let retryStrategy = DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(3))
    @IBOutlet weak var topTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMainNotice();
        loadNotice();
        noticeTableView.delegate = self;
        noticeTableView.dataSource = self;
        
    }
    
    @IBAction func deleteNoticeList(_ sender: Any) {
        var indexArray : [String] = [];
        for item in selectedIndexArray{
            if(item.value == true){
                indexArray.append("\(item.key)");
            }
        }
        self.removeNotice(noticeNumber: indexArray.sorted())
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func loadMainNotice() {
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/commonNoticeController/loadMainNoticeContent";
        AF.request(
            apiURL,
            method: .get,
            parameters: nil,
            headers: ["Content-Type":"application/json", "Accept":"application/json; charset=utf-8"])
        .validate(statusCode: 200..<300)
        .responseString { (response) in
            self.topTextView.text = response.value!
        }
    }
    
    
    
    func removeNotice(noticeNumber : [String]){
         
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/commonNoticeController/removeNotice";
        
        let string = noticeNumber.joined(separator: ",")
        let param: Parameters =
        [
            "noticeNumber" : string,
        ];
        
        AF.request(apiURL,
                   method: .post,
                   parameters: param,
                   encoding: URLEncoding.httpBody).response{ response in switch response.result {
                   case .success:
                       do{
                           print("success");
                           
                           for noticeItem in noticeNumber.reversed(){
                               print("noticeItem \(noticeItem)");
                               self.noticeArray.remove(at: Int(noticeItem)!);
                               
                           }
                           self.selectedIndexArray.removeAll()
                           self.noticeTableView.reloadData()
                           
                       }catch(let error){
                           print("error : \(error)");
                       }
                       return
                   case .failure(let error):
                       print(error)
                       return
                   }
        }
    }
    
    
    
    func loadNotice() {
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/commonNoticeController/loadNotice";
        AF.request(
            apiURL,
            method: .get,
            parameters: nil,
            headers: ["Content-Type":"application/json", "Accept":"application/json; charset=utf-8"])
        .validate(statusCode: 200..<300)
        .response{ response in
            switch response.result {
            case .success:
                do{
                    if let jsonArray = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [Dictionary<String,Any>]
                    {
                        for item in jsonArray{
                            self.noticeArray.append(item);
                        }
                        self.noticeTableView.reloadData()
                    }else{
                        print("bad Json");
                    }
                    
                }catch(let error){
                    print("error : \(error)");
                }
                
                return
            case .failure(let error):
                print(error)
                return
            }
        }
    }
}


class NoticeCell : UITableViewCell{
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var regDateLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    var clickInterfaceDelegate : NoticeItemClickInterface!
    var indexPath : IndexPath!;
    
    
    @IBAction func isClickAction(_ sender: Any) {
        
        
       
        removeButton.isSelected = removeButton.isSelected == true ? false : true;
        
        print("removeButton.isSelected \(removeButton.isSelected)")
        if(removeButton.isSelected == true){
            removeButton.setBackgroundColor(.red, for: .normal)
        }else{
            removeButton.setBackgroundColor(.white, for: .normal)
        }
        
        clickInterfaceDelegate.clickIndex(indexPath: indexPath , status: removeButton.isSelected , realIndex: removeButton.tag);
        
        
        
    }
    
    override func awakeFromNib(){
        super.awakeFromNib();
        removeButton.setTitle("", for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}


extension NoticeViewController : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.noticeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let noticeCell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell", for: indexPath) as? NoticeCell else {
            return UITableViewCell();
        }
        
        let notice_Index = self.noticeArray[indexPath.row]["notice_Index"]! as Any;
        let mainPhoto = self.noticeArray[indexPath.row]["mainPhoto"]! as Any;
        let nickname = self.noticeArray[indexPath.row]["userId"]! as Any;
        let url = URL(string: "http://ply2782ply2782.cafe24.com:8080/userController/profileImageShow?imageName=\(mainPhoto)");
        let regDate = self.noticeArray[indexPath.row]["notice_RegDate"]! as Any;
        let content = self.noticeArray[indexPath.row]["notice_Content"]! as Any;
        
        
        noticeCell.contentTextView.text = content as? String;
        noticeCell.regDateLabel.text = regDate as? String;
        noticeCell.nickNameLabel.text = nickname as? String;
        noticeCell.nickNameLabel.sizeToFit();
        noticeCell.indexPath = indexPath;
        noticeCell.removeButton.tag = notice_Index as! Int;
                
        
        noticeCell.removeButton.setBackgroundColor(.white, for: .normal)
        if(!selectedIndexArray.isEmpty){
            if(selectedIndexArray[indexPath.row] == true){
                noticeCell.removeButton.setBackgroundColor(.red, for: .normal)
            }
        }
        
        
        
        noticeCell.clickInterfaceDelegate = self;
        noticeCell.personImageView.layer.borderColor = UIColor.clear.cgColor
        noticeCell.personImageView.clipsToBounds = true
        noticeCell.personImageView.layer.cornerRadius = noticeCell.personImageView.frame.height/2
        noticeCell.personImageView?.kf.indicatorType = .activity
        noticeCell.personImageView?.kf.setImage(
            with: url,
            placeholder: nil,
            options: [
                .retryStrategy(retryStrategy),
                .transition(.fade(1.2)),
                .forceTransition,
                .processor(cornerImageProcessor)
            ],
            completionHandler: nil)
        
        return noticeCell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("indexPath.row \(indexPath.row)");
    }
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
         
        self.setBackgroundImage(backgroundImage, for: state)
    }
}
