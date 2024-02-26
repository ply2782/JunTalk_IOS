//
//  CreateClubListViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/08/15.
//

import UIKit
import DoubleSlider
import Alamofire
import SwiftyJSON
import AVKit
import Kingfisher


protocol ChooseViewControllerProtocal: AnyObject {
    func dismissSecondViewController( date : String );
}

protocol SelectPlace : AnyObject {
    func selectPlace( place: Place);
}


class CreateClubListViewController: UIViewController , ChooseViewControllerProtocal, SelectPlace, UITextFieldDelegate {
    
    func selectPlace(place: Place) {
        do{
            self.selectedPlace = place;
            locationLabel.text = place.place_name;
        }catch{
            print("error");
        }
        
    }
    
    func dismissSecondViewController(date : String) {
        selectedDateLabel.text = date
    }
    
    
    var selectedPlace : Place!;
    let photo = UIImagePickerController()
    var fileImageArray : [UIImage?] = [];
    var fileVideoArray : [URL?] = [];
    var fileSumArray :[Any] = [];
    weak var delegate : ChooseViewControllerProtocal?
    weak var selectPlaceDelegate : SelectPlace?
    var myModel : UserData!;
    var originalKeyBoardHeight : CGFloat?
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var categoryInsertButton: UIButton!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var fileCollectionView: UICollectionView!
    @IBOutlet weak var introduceTextView: UITextField!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var calendarLottieImageView: UIImageView!
    @IBOutlet weak var expenditureTextView: UITextField!
    @IBOutlet weak var titleTextView: UITextField!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var categoryTextView: UITextField!
    
    var selectedDate : String?;
    var labels: [String] = []
    var tagArray : [String] = [];
    var doubleSlider: DoubleSlider!
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moveMapView"{
            if let destination = segue.destination as?
                MapViewController {
                destination.selectPlaceDelegate = self.selectPlaceDelegate;
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            
            self.selectedPlace = try Place.init();
            collectionViewSetting();
            makeLabels();
            settingDobuleSlider();
            clickEventCalendar();
            self.selectPlaceDelegate = self;
            self.photo.delegate = self
            categoryInsertButton.titleLabel?.adjustsFontSizeToFitWidth = true;
            categoryInsertButton.titleLabel?.sizeToFit();
            self.delegate = self;
            
            categoryTextView.delegate = self;
            titleTextView.delegate = self;
            expenditureTextView.delegate = self;
            introduceTextView.delegate = self;
            
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
            
            
        }catch{
            print("error");
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        categoryTextView.endEditing(true)
        titleTextView.endEditing(true)
        expenditureTextView.endEditing(true)
        introduceTextView.endEditing(true);
        self.view.endEditing(true);
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   categoryTextView.resignFirstResponder()
        titleTextView.resignFirstResponder()
        expenditureTextView.resignFirstResponder()
        introduceTextView.resignFirstResponder()
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
    
    
    
    
    
    
    
    @IBAction func openAlbumButton(_ sender: Any) {
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
    
    
    
    
    func collectionViewSetting(){
        categoryCollectionView.delegate = self;
        categoryCollectionView.dataSource = self;
        fileCollectionView.delegate = self;
        fileCollectionView.dataSource = self;
        
    }
    
    
    
    func insertClubListApi(){
        do {
            let url = "http://ply2782ply2782.cafe24.com:8080/clubController/createClub"
            let title = titleTextView.text;
            let limitJoinCount = 6;
            let expectedMoney = expenditureTextView.text;
            let clubIntroduce = introduceTextView.text;
            let userKakaoOwnNumber = myModel.userKakaoOwnNumber;
            let user_Index = myModel.user_Index;
            let regDate = selectedDateLabel.text;
            let userMainPhoto = myModel.userMainPhoto;
            let userId = myModel.userId;
            let minAge = doubleSlider.minValue;
            let maxAge = doubleSlider.maxValue;
            //        guard let uploadData = try? JSONEncoder().encode(selectedPlace)
            //        else {return}
            //        let object = try? JSONSerialization.data(withJSONObject: selectedPlace.serialize(), options: [.prettyPrinted])
            var jsonObj : String = ""
            
            let jsonCreate = try JSONSerialization.data(withJSONObject: selectedPlace.serialize(), options: .prettyPrinted)
            
            // json 데이터를 변수에 삽입 실시
            jsonObj = String(data: jsonCreate, encoding: .utf8) ?? ""
            let place = jsonObj;
            
            
            let clubState = "N";
            let hashTagList = tagArray;
            let club_Uuid = UUID().uuidString;
            
            let header: HTTPHeaders = [
                "Content-Type" : "multipart/form-data"
            ]
            
            
            let parameters: Parameters = [
                "title": title!,
                "limitJoinCount": limitJoinCount,
                "expectedMoney" : expectedMoney! ,
                "clubIntroduce" : clubIntroduce!,
                "userKakaoOwnNumber" : userKakaoOwnNumber,
                "user_Index" : user_Index,
                "regDate" : regDate!,
                "userMainPhoto" : userMainPhoto,
                "userId" : userId,
                "minAge" : minAge,
                "maxAge" : maxAge,
                "place" : place,
                "clubState" : clubState,
                "hashTagList" : hashTagList,
                "club_Uuid" : club_Uuid
            ]
            for item in fileSumArray {
                if(item is UIImage){
                    self.fileImageArray.append(item as! UIImage);
                }else{
                    self.fileVideoArray.append(item as! URL);
                }
            }
            
            var customImageData : [Data] = [];
            for item in self.fileImageArray{
                let imageData = item!.jpegData(compressionQuality: 1)!
                customImageData.append(imageData);
            }
            
            
            AF.upload(multipartFormData: { MultipartFormData in
                
                //body 추가
                
                
                for (key, value) in parameters {
                    MultipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                }
                
                //img 추가
                for item in customImageData{
                    let uuid = UIDevice.current.identifierForVendor?.uuidString.lowercased() ?? "";
                    
                    let photoName = "\(uuid)_JunTalk.jpg";
                    
                    MultipartFormData.append(
                        item,
                        withName: "imageFiles",
                        fileName: photoName,
                        mimeType: "image/jpeg")
                }
                
                for item in self.fileVideoArray {
                    let uuid = UIDevice.current.identifierForVendor?.uuidString.lowercased() ?? "";
                    
                    let photoName = "\(uuid)_JunTalk.mp4";
                    
                    MultipartFormData.append(
                        item!,
                        withName: "videoFiles",
                        fileName: photoName,
                        mimeType: "video/mp4")
                }
                
            }, to: url, method: .post, headers: header )
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
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        doubleSlider.removeTarget(self, action: #selector(printVal(_:)), for: .valueChanged)
    }
    
    private func makeLabels() {
        for num in stride(from: 0, to: 100, by: 1) {
            labels.append("$\(num)")
        }
        labels.append("No limit")
    }
    
    
    func settingDobuleSlider(){
        
        let frame = CGRect(
            x: self.sliderView.bounds.minX - 2.0,
            y: self.sliderView.bounds.midY ,
            width: UIScreen.main.bounds.size.width,
            height: 40
        )
        doubleSlider = DoubleSlider(frame: frame)
        doubleSlider.labelsAreHidden = true;
        doubleSlider.translatesAutoresizingMaskIntoConstraints = false
        doubleSlider.trackTintColor = UIColor.lightGray
        doubleSlider.labelDelegate = self
        doubleSlider.numberOfSteps = labels.count
        doubleSlider.smoothStepping = true
        let labelOffset: CGFloat = 8.0
        doubleSlider.lowerLabelMarginOffset = labelOffset
        doubleSlider.upperLabelMarginOffset = labelOffset
        doubleSlider.lowerValueStepIndex = 0
        doubleSlider.upperValueStepIndex = labels.count - 1
        // You can use traditional notifications
        
        doubleSlider.addTarget(self, action: #selector(printVal(_:)), for: .valueChanged)
        // Or Swifty delegates
        doubleSlider.editingDidEndDelegate = self
        sliderView.addSubview(doubleSlider)
    }
    
    @objc func printVal(_ doubleSlider: DoubleSlider) {
        print("Lower: \(doubleSlider.lowerValue) Upper: \(doubleSlider.upperValue)")
    }
    
    
    func clickEventCalendar(){
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(openCalendar))
        self.calendarLottieImageView.isUserInteractionEnabled = true
        self.calendarLottieImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func openCalendar() {
        let openCalendarViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChooseCalendarViewController") as! ChooseCalendarViewController
        openCalendarViewController.delegate = self.delegate;
        openCalendarViewController.modalPresentationStyle = .custom
        openCalendarViewController.modalTransitionStyle = .crossDissolve
        self.present(openCalendarViewController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func insertCategory(_ sender: Any) {
        let tags = categoryTextView.text;
        tagArray.append(tags!);
        categoryCollectionView.reloadData()
        
    }
    
    
    @IBAction func createClubListAction(_ sender: Any) {
        insertClubListApi();
    }
}


extension CreateClubListViewController: DoubleSliderLabelDelegate {
    func labelForStep(at index: Int) -> String? {
        return labels[index];
    }
}

extension CreateClubListViewController: DoubleSliderEditingDidEndDelegate {
    func editingDidEnd(for doubleSlider: DoubleSlider) {
        self.ageLabel.text = "\(doubleSlider.lowerValueStepIndex) ~ \(doubleSlider.upperValueStepIndex)"
        print("Lower Step Index: \(doubleSlider.lowerValueStepIndex) Upper Step Index: \(doubleSlider.upperValueStepIndex)")
    }
}



class MediaCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var thumbNailImageView: UIImageView!
    @IBOutlet weak var mediaWholeView: CardView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("awakeFromNib");
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse();
        thumbNailImageView.image = nil;
    }
    
}


class TagsCollectionViewCell : UICollectionViewCell{
    @IBOutlet weak var tagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("awakeFromNib");
        tagLabel.sizeToFit();
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse();
        tagLabel.text = nil;
    }
    
    
}


extension CreateClubListViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    
    // 선택 안한 부분 스타일 커스텀
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    //  선택 한 부분 스타일 커스텀
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    // CollectionView item 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(collectionView == fileCollectionView){
            
            return self.fileSumArray.count;
            
        }else if(collectionView == categoryCollectionView){
            
            return self.tagArray.count;
        }else{
            return 0;
        }
    }
    
    
    // CollectionView Cell의 Object
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == fileCollectionView){
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCollectionViewCell", for: indexPath) as? MediaCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.thumbNailImageView.layer.cornerRadius = 10
            cell.thumbNailImageView.layer.borderWidth = 1
            cell.thumbNailImageView.layer.borderColor = UIColor.clear.cgColor
            cell.thumbNailImageView.clipsToBounds = true
            
            if(self.fileSumArray[indexPath.row] is UIImage){
                cell.thumbNailImageView.image = self.fileSumArray[indexPath.row] as! UIImage;
            }else{
                cell.thumbNailImageView.image = self.generateThumbnail(path: self.fileSumArray[indexPath.row] as! URL);
            }
            
            
            return cell;
            
        }else{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagsCollectionViewCell", for: indexPath) as? TagsCollectionViewCell else {
                return UICollectionViewCell()
            }
            let tagString = tagArray[indexPath.row];
            cell.tagLabel.text = tagString;
            return cell;
        }
        
        return UICollectionViewCell();
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("willDisplay: \(indexPath.row)")
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
        print("didEndDisplaying: \(indexPath.row)")
    }
    
    // CollectionView Cell의 Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(collectionView == categoryCollectionView){
            
            let itemCell = self.tagArray[indexPath.item].size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]).width + 80
            
            let collectionViewWidth = itemCell;
            let collectionViewHeight = collectionView.bounds.height
            return CGSize(width: collectionViewWidth, height: collectionViewHeight)
        }else{
            
            return CGSize(width: 120, height: 120)
        }
    }
    
    
    
    // CollectionView Cell의 위아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    // CollectionView Cell의 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    
    
}




extension CreateClubListViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
        
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            self.fileSumArray.append(image);
            self.fileCollectionView.reloadData();
            
        }else if let video = info[UIImagePickerController.InfoKey.mediaURL] {
            
            self.fileSumArray.append(video);
            self.fileCollectionView.reloadData();
            
            
        }
        
        
        photo.dismiss(animated: true, completion: nil) //dismiss를 직접 해야함
    }
}
