//
//  CreateBulletinBoardViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/07/11.
//

import UIKit
import Alamofire
import AVFoundation
import Kingfisher


class CreateBulletinBoardViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var lastStackView: UIStackView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var fileImageTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var openAlbumImageView: UIImageView!
    let photo = UIImagePickerController()
    var fileImageArray : [UIImage?] = [];
    var fileVideoArray : [URL?] = [];
    var fileSumArray :[Any] = [];
    @IBOutlet weak var fileImageTableView: UITableView!
    @IBOutlet weak var textViewTextNumLabel: UILabel!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    var nowPage: Int = 0
    var selectedCatgory : String = "";
    var originalKeyBoardHeight : CGFloat?
    // 데이터 배열
    let dataArray: [String] = ["# 감사", "# 중보", "# 소식","# 공지", "# 소개", "# 일상" , "# 자랑"];
    let maxCount = 200;
    @IBOutlet weak var closeImageView: UIImageView!
    var myModel : UserData!;
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let data = UserDefaults.standard.object(forKey: "myModel")
        if(data != nil){
            let decoder = JSONDecoder()
            self.myModel = try? decoder.decode(UserData.self, from: data as! Data)
        }
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(imageTapped))
        self.closeImageView.isUserInteractionEnabled = true
        self.closeImageView.addGestureRecognizer(tapGestureRecognizer)
        
        
        let openAlbumRecognizer = UITapGestureRecognizer(target:self, action:#selector(openAlbumTapped))
        self.openAlbumImageView.isUserInteractionEnabled = true
        self.openAlbumImageView.addGestureRecognizer(openAlbumRecognizer)
        
        self.photo.delegate = self
        self.fileImageTableView.delegate = self;
        self.fileImageTableView.dataSource = self;
        self.categoryCollectionView.delegate = self
        self.categoryCollectionView.dataSource = self
        self.contentsTextView.delegate = self;
        
        self.hideKeyboard();
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        contentsTextView.endEditing(true)
        self.view.endEditing(true);
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   contentsTextView.resignFirstResponder()
        return true
    }

    @objc func keyboardWillHide(_ sender: Notification) {
        let bounds = UIScreen.main.bounds
        //        let height = bounds.size.height
        UIView.animate(withDuration: 1) {
            self.view.window?.frame.origin.y = 0
        }

    }

    @objc func keyboardWillShow(_ sender: Notification) {
        let userInfo:NSDictionary = sender.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.size.height
        originalKeyBoardHeight = keyboardHeight;
        UIView.animate(withDuration: 1) {
            self.view.window?.frame.origin.y = (-self.originalKeyBoardHeight! + 40)
        }
    }
    
    
    
    
    @objc private func imageTapped() {
        self.dismiss(animated: true);
    }
    
    @objc private func openAlbumTapped() {
        self.openLibrary();
    }
    
    func openLibrary(){
        photo.sourceType = .photoLibrary
        photo.mediaTypes = ["public.movie" , "public.image"];
        present(photo, animated: false, completion: nil)
    }
    
    
    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    @IBAction func insertBulletinBoard(_ sender: Any) {
        
        for item in fileSumArray {
            if(item is UIImage){
                self.fileImageArray.append(item as! UIImage);
                
            }else{
                self.fileVideoArray.append(item as! URL);
                
            }
        }
        self.updateProfileImage(self.fileImageArray , self.fileVideoArray);
    }
    private func updateProfileImage(_ imageArray : [UIImage?] , _ videoArray : [URL?]){
        var customImageData : [Data] = [];        
        for item in imageArray{
            let imageData = item!.jpegData(compressionQuality: 1)!
            customImageData.append(imageData);
        }
        let url = "http://ply2782ply2782.cafe24.com:8080/bulletinBoardController/insertBulletinBoard"
        
        //        let uuid = UIDevice.current.identifierForVendor?.uuidString.lowercased() ?? "";
        let uuid = UUID().uuidString;
        
        self.posts(videoData : videoArray, imageData: customImageData, to: url, bulletin_Uuid: uuid, userId: self.myModel.userId, user_Index: self.myModel.user_Index, bulletin_Content: self.contentsTextView.text, userMainPhoto: self.myModel.userMainPhoto, category: selectedCatgory)
        
    }
    
    
    
    func posts(videoData : [URL?], imageData: [Data], to url: String , bulletin_Uuid : String ,userId : String , user_Index : Int ,
               bulletin_Content : String , userMainPhoto:String ,
               category:String) {
        
        let header: HTTPHeaders = [
            "Content-Type" : "multipart/form-data"
        ]
        
        let parameters: [String : Any] = [
            "bulletin_Uuid": bulletin_Uuid,
            "userId": userId,
            "user_Index":user_Index ,
            "bulletin_Content" : bulletin_Content,
            "userMainPhoto" : userMainPhoto,
            "category" :category,
        ]
        
        AF.upload(multipartFormData: { MultipartFormData in
            
            //body 추가
            
            
            for (key, value) in parameters {
                MultipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            }
            
            //img 추가
            for item in imageData{
                let uuid = UIDevice.current.identifierForVendor?.uuidString.lowercased() ?? "";
                let photoName = "\(uuid)_JunTalk.jpg";
                MultipartFormData.append(
                    item,
                    withName: "imageFiles",
                    fileName: photoName,
                    mimeType: "image/jpeg")
            }
            
            for item in videoData {
                let uuid = UIDevice.current.identifierForVendor?.uuidString.lowercased() ?? "";
                let photoName = "\(uuid)_JunTalk.mp4";
                MultipartFormData.append(
                    item!,
                    withName: "videoFiles",
                    fileName: photoName,
                    mimeType: "video/mp4")
            }
            
        }, to: url, method: .post, headers: header)
        .validate()
        .response{ response in
            switch response.result {
            case .success:
                do{
                    
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


extension CreateBulletinBoardViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
        
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            
            //            self.fileImageArray.append(image);
            self.fileSumArray.append(image);
            
            self.fileImageTableViewHeight.constant = CGFloat(Double(self.fileSumArray.count) * 200)
            self.fileImageTableView.reloadData();
            
        }else if let video = info[UIImagePickerController.InfoKey.mediaURL] {
            
            
            //            self.fileVideoArray.append(video as! URL);
            self.fileSumArray.append(video);
            
            self.fileImageTableViewHeight.constant = CGFloat(Double(self.fileSumArray.count) * 200)
            self.fileImageTableView.reloadData();
            
            
        }
        
        
        photo.dismiss(animated: true, completion: nil) //dismiss를 직접 해야함
    }
}

class CategoryCollectionViewCell : UICollectionViewCell{
    
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
}

extension CreateBulletinBoardViewController : UICollectionViewDelegate , UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{
    
    
    func switchCategory(_ category : String) -> String{
        switch (category) {
        case "# 감사" :
            return "Thanks";
        case "# 중보" :
            return "Pray";
        case "# 소식":
            return "News";
        case "# 공지":
            return "Notice";
        case "# 소개":
            return "Introduce";
        case "# 일상":
            return "Daily";
        case "# 자랑":
            return "Show";
        default:
            return "null";
        }
    }
    
    // 선택 안한 부분 스타일 커스텀
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    }
    
    //  선택 한 부분 스타일 커스텀
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selectedRow \(indexPath.row)");
    }
    
    // CollectionView item 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count;
    }
    
    
    // CollectionView Cell의 Object
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        guard let categoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        categoryCell.categoryLabel.text = self.dataArray[indexPath.row];
        selectedCatgory = self.switchCategory(self.dataArray[indexPath.row]);
        
        return categoryCell;
    }
    
    // CollectionView Cell의 Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = collectionView.frame.width
        let height : CGFloat = collectionView.frame.height
        return CGSize(width: width, height: height)
        
    }
    
    // CollectionView Cell의 위아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    // CollectionView Cell의 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}

extension CreateBulletinBoardViewController :  UITextViewDelegate
{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //이전 글자 - 선택된 글자 + 새로운 글자(대체될 글자)
        let newLength = textView.text.count - range.length + text.count
        let koreanMaxCount = maxCount + 1
        textViewTextNumLabel.text = "\(newLength) /\(maxCount)"
        //글자수가 초과 된 경우 or 초과되지 않은 경우
        if newLength > koreanMaxCount { //11글자
            let overflow = newLength - koreanMaxCount //초과된 글자수
            if text.count < overflow {
                return true
            }
            let index = text.index(text.endIndex, offsetBy: -overflow)
            
            let newText = text[..<index]
            
            guard let startPosition = textView.position(from: textView.beginningOfDocument, offset: range.location) else { return false }
            
            guard let endPosition = textView.position(from: textView.beginningOfDocument, offset: NSMaxRange(range)) else { return false }
            
            guard let textRange = textView.textRange(from: startPosition, to: endPosition) else { return false }
            
            textView.replace(textRange, withText: String(newText))
            
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count > maxCount {
            //글자수 제한에 걸리면 마지막 글자를 삭제함.
            textView.text.removeLast()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
                
            }
            //             /// 180 이하일때는 더 이상 줄어들지 않게하기
            //               if estimatedSize.height <= 200 {
            //
            //               }
            //               else {
            //                   if constraint.firstAttribute == .height {
            //                       constraint.constant = estimatedSize.height
            //                   }
            //               }
        }
    }
}


class FileImageTableViewCell : UITableViewCell{
    
    @IBOutlet weak var thumbNailImageView: UIImageView!
    
}


extension CreateBulletinBoardViewController : UITableViewDelegate , UITableViewDataSource {
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return self.fileImageArray.count;
        return self.fileSumArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let fileImageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "FileImageTableViewCell", for: indexPath) as? FileImageTableViewCell else {
            return UITableViewCell();
        }
        
        fileImageTableViewCell.thumbNailImageView.layer.cornerRadius = 10
        fileImageTableViewCell.thumbNailImageView.layer.borderWidth = 1
        fileImageTableViewCell.thumbNailImageView.layer.borderColor = UIColor.clear.cgColor
        fileImageTableViewCell.thumbNailImageView.clipsToBounds = true
        
        
        if(self.fileSumArray[indexPath.row] is UIImage){
            
            fileImageTableViewCell.thumbNailImageView.image = self.fileSumArray[indexPath.row] as! UIImage;
            
        }else{
            
            
            fileImageTableViewCell.thumbNailImageView.image = self.generateThumbnail(path: self.fileSumArray[indexPath.row] as! URL);
            
        }
        return fileImageTableViewCell;
    }
    
}
