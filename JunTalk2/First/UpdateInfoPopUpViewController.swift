//
//  UpdateInfoPopUpViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/09/10.
//

import UIKit
import Alamofire
import AVFoundation
import Kingfisher


class UpdateInfoPopUpViewController: UIViewController{
    
    var updateProtocalDelegate : UpdateProtocal!;
    let photo = UIImagePickerController()
    var fileImageArray : [UIImage?] = [];
    @IBOutlet var myStatusTextView: UITextView!
    @IBOutlet var myNickNameTextView: UITextView!
    @IBOutlet var imagePreviewImageView: UIImageView!
    var myIndex : Int? = 0;
    var myId : String? = "";
    var myStatus : String? = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photo.delegate = self
        
        placeholderSetting();
        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func updateMyPhoto(_ sender: Any) {
        self.openLibrary();
    }
    
    func openLibrary(){
        photo.sourceType = .photoLibrary
        photo.mediaTypes = ["public.image"];
        present(photo, animated: false, completion: nil)
    }
    
    func placeholderSetting() {
        myNickNameTextView.delegate = self;
        myNickNameTextView.text = "닉네임을 입력해주세요"
        myNickNameTextView.textColor = UIColor.lightGray
        myNickNameTextView.sizeToFit()
        
        myStatusTextView.delegate = self;
        myStatusTextView.text = "상태메시지를 입력해주세요."
        myStatusTextView.textColor = UIColor.lightGray
        myStatusTextView.sizeToFit()
    }
    
    
    @IBAction func updateMyInfoAction(_ sender: Any) {
        
        let nickNameDefaultText = "닉네임을 입력해주세요";
        let isChangedNickName = nickNameDefaultText == myNickNameTextView.text ?  myId : myNickNameTextView.text;
        
        let statusDefaultText = "상태메시지를 입력해주세요";
        let isChangedMyStatus = statusDefaultText == myStatusTextView.text ? myStatus : myStatusTextView.text;
        
        saveMyData(userId: isChangedNickName, user_Index: myIndex, user_Introduce: isChangedMyStatus)
    }
    
    @IBAction func updateMyNickName(_ sender: Any) {
        myNickNameTextView.isEditable = true;
        myNickNameTextView.isSelectable = true;
    }
    
    
    @IBAction func updateMyStatus(_ sender: Any) {
        myStatusTextView.isEditable = true;
        myStatusTextView.isSelectable = true;
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    
    func saveMyData( userId : String? , user_Index : Int?, user_Introduce : String? ){
        
        
        
        var customImageData : [Data] = [];
        for item in fileImageArray{
            let imageData = item!.jpegData(compressionQuality: 1)!
            customImageData.append(imageData);
        }
        let url = "http://ply2782ply2782.cafe24.com:8080/userController/saveMyData"
        
        
        let header: HTTPHeaders = [
            "Content-Type" : "multipart/form-data"
        ]
        
        let parameters: [String : Any] = [
            "userId": userId!,
            "user_Index": user_Index! ,
            "user_Introduce" : user_Introduce!,
        ]
        
        AF.upload(multipartFormData: { MultipartFormData in
            for (key, value) in parameters {
                MultipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            }
            for item in customImageData{
                let uuid = UIDevice.current.identifierForVendor?.uuidString.lowercased() ?? "";
                let photoName = "\(uuid)_JunTalk.jpg";
                MultipartFormData.append(
                    item,
                    withName: "userMainPhoto",
                    fileName: photoName,
                    mimeType: "image/jpeg")
            }
            
        }, to: url, method: .post, headers: header)
        .validate()
        .response{ response in
            switch response.result {
            case .success:
                do{
                    
                    self.updateProtocalDelegate.updateInfo();
                    NotificationCenter.default.post(name: .mainRefresh, object: nil)
                    
                    self.dismiss(animated: true, completion: nil)
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

extension UpdateInfoPopUpViewController : UITextViewDelegate{
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

extension UpdateInfoPopUpViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.fileImageArray.append(image);
            
            imagePreviewImageView.layer.cornerRadius = 10
            imagePreviewImageView.layer.borderWidth = 1
            imagePreviewImageView.layer.borderColor = UIColor.clear.cgColor
            imagePreviewImageView.clipsToBounds = true
            imagePreviewImageView.image = self.fileImageArray[0] as! UIImage;
        }
        photo.dismiss(animated: true, completion: nil) //dismiss를 직접 해야함
    }
}
