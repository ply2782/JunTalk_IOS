//
//  CreateReelsViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/08/15.
//

import UIKit
import Alamofire
import AVFoundation
import Kingfisher

class CreateReelsViewController: UIViewController {
    
    var myModel : UserData!;
    let photo = UIImagePickerController()
    var imageFileData : URL? = nil // 서버로 이미지 등록을 하기 위함
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    var tagArray : [String] = [];
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingMyModel();
        self.tagCollectionView.delegate = self;
        self.tagCollectionView.dataSource = self;
        self.photo.delegate = self
        picturePreView();
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view가 Load됨 (viewWillAppear)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("view가 화면에 나타남 (viewDidAppear)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("view가 사라지기 전 (viewWillDisappear)")
    
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("view가 사라짐 (viewDidDisappear)")
    }
    
    
    func settingMyModel(){
        let data = UserDefaults.standard.object(forKey: "myModel")
        if(data != nil){
            let decoder = JSONDecoder()
            self.myModel = try? decoder.decode(UserData.self, from: data as! Data)
        }
    }
    
    func picturePreView(){
        self.previewImageView.layer.borderColor = UIColor.clear.cgColor
        self.previewImageView.clipsToBounds = true
        self.previewImageView.layer.cornerRadius = self.previewImageView.frame.height/2
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(openAlbumTapped))
        self.previewImageView.isUserInteractionEnabled = true
        self.previewImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
  
    
    @objc private func openAlbumTapped() {
        self.openLibrary();
    }
    
    func openLibrary(){
        photo.sourceType = .photoLibrary
        photo.mediaTypes = ["public.movie"];
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
    
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func insertTag(_ sender: Any) {
        let tags = tagTextField.text;
        tagArray.append(tags!);
        tagCollectionView.reloadData()
    }
    
    
    
    @IBAction func insertReels(_ sender: Any) {
        self.updateProfileImage(imageFileData);
    }
    
    private func updateProfileImage(_ videoData : URL?){
        let url = "http://ply2782ply2782.cafe24.com:8080/bulletinBoardController/createLilsVideoList"
        let uuid = UUID().uuidString;
        
        self.insertReelsApi(url:url, videoData: videoData!, userId: myModel.userId, lils_Uuid: uuid, user_Index: myModel.user_Index, userMainPhoto: myModel.userMainPhoto, contents: self.contentTextView.text, hashTagList: self.tagArray)
    }
   
    
    func insertReelsApi(
        url : String,
        videoData : URL,
        userId: String,
        lils_Uuid: String,
        user_Index: Int,
        userMainPhoto : String,
        contents : String,
        hashTagList: [String]) {
            
            let header: HTTPHeaders = [
                "Content-Type" : "multipart/form-data"
            ]
            
            let parameters: [String : Any] = [
                "lils_Uuid": lils_Uuid,
                "userId": userId,                
                "user_Index":user_Index ,
                "hashTagList" : hashTagList,
                "contents" : contents,
                "userMainPhoto" : userMainPhoto,
            ]
            
            AF.upload(multipartFormData: { MultipartFormData in
                
                for (key, value) in parameters {
                    MultipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                }
                
                let uuid = UIDevice.current.identifierForVendor?.uuidString.lowercased() ?? "";
                let photoName = "\(uuid)_JunTalk.mp4";
                MultipartFormData.append(
                    videoData,
                    withName: "videoFiles",
                    fileName: photoName,
                    mimeType: "video/mp4")
                
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



extension CreateReelsViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let video = info[UIImagePickerController.InfoKey.mediaURL] {
            self.previewImageView.image = self.generateThumbnail(path: video as! URL);
            self.imageFileData = video as! URL;
       }
        photo.dismiss(animated: true, completion: nil) //dismiss를 직접 해야함
    }
}


class TagSCollectionViewCell :UICollectionViewCell{
    
    @IBOutlet weak var tagsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("awakeFromNib");
        // Initialization code
        tagsLabel.sizeToFit();
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse();
        tagsLabel.text = nil;
    }
    
    
}




extension CreateReelsViewController : UICollectionViewDataSource , UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // 선택 안한 부분 스타일 커스텀
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        
    }
    
    //  선택 한 부분 스타일 커스텀
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tagArray.count;
        
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagSCollectionViewCell", for: indexPath) as! TagSCollectionViewCell
        
        let tagsItem = tagArray[indexPath.row];
        cell.tagsLabel.text = tagsItem;
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("willDisplay: \(indexPath.row)")
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemCell = self.tagArray[indexPath.item].size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]).width + 80
        
        let collectionViewWidth = itemCell;
        let collectionViewHeight = collectionView.bounds.height
        return CGSize(width: collectionViewWidth, height: collectionViewHeight)
    }
    
    // CollectionView Cell의 위아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    // CollectionView Cell의 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    //    스크롤 시 끝에 다다를떄
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        print("scrollContentsOFfset \(targetContentOffset.pointee.x)");
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
}
