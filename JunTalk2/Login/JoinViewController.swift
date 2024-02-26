//
//  JoinViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/05/21.
//

import UIKit
import FSCalendar
import Alamofire

class JoinViewController: UIViewController{
    
    let photo = UIImagePickerController()
    var imageFileData : UIImage? = nil // 서버로 이미지 등록을 하기 위함
    var userMainPhotoName :String = ""
//    @IBOutlet weak var claendarView: FSCalendar!
    @IBOutlet weak var preViewImageView: UIImageView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var thirdNumberTextField: UITextField!
    @IBOutlet weak var secondNumberTextField: UITextField!
    @IBOutlet weak var firstNumberTextField: UITextField!
    @IBOutlet weak var genderSegMent: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var idTextField: UITextField!
    let dateFormatter = DateFormatter()
    let device = UIDevice.current;
    let userModel = UserData?.self;    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
//        claendarView.delegate = self
//        claendarView.dataSource = self
        photo.delegate = self
        genderSegMent.addTarget(self, action: #selector(segconChanged(segcon:)), for: .valueChanged)
        self.genderSegMent.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        let height = UIScreen.main.bounds.size.height
        self.viewHeight.constant = (height + 200);
        print(device.name)
        print(device.model)
        print(device.localizedModel)
        print(device.systemName)
        print(device.systemVersion)
        print(device.orientation)
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
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion:nil)
//        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController else { return }
//        viewController.modalTransitionStyle = .coverVertical
//        viewController.modalPresentationStyle = .fullScreen
//        self.present(viewController, animated: true, completion: nil)
    }
    
    func checkNull() -> Bool {
        let id = idTextField.text;
        let password = passwordTextField.text;
        let name = nameTextField.text;
        let gender = selectedValue(selectedIndex : genderSegMent.selectedSegmentIndex)
        let userBirthDay = ""
//        let userBirthDay = dateFormatter.string(from: claendarView.selectedDate ?? Date())
        let firstNumber = firstNumberTextField.text;
        let secondNumber = secondNumberTextField.text;
        let thirdNumber = thirdNumberTextField.text;
        let userIdentity = "101";
        
                
        
        if(id == nil || id == ""){
            return false;
        }else if(password == nil || password == ""){
            return false;
        }else if(name == nil || name == ""){
            return false;
        }else if(gender == ""){
            return false;
        }else if(userBirthDay == ""){
            return false;
        }else if(firstNumber == nil || firstNumber == ""){
            return false;
        }else if(secondNumber == nil || secondNumber == ""){
            return false;
        }else if(thirdNumber == nil || thirdNumber == ""){
            return false;
        }else{
            
            insertJoin(userIdentity: userIdentity, userId: id, userName:"test", userKakaoId: "test", userPassword: password, userPhoneNumber:"\(String(describing: firstNumber!))-\(String(describing: secondNumber!))-\(String(describing: thirdNumber!))", userGender: gender, userBirthDay: userBirthDay, userKakaoOwnNumber: 10000, userMainPhoto: userMainPhotoName)
            
            return true;
        }
    }
    
    func insertJoin(
        userIdentity : String?,
        userId : String?,
        userName : String?,
        userKakaoId : String?,
        userPassword : String?,
        userPhoneNumber : String?,
        userGender : String?,
        userBirthDay : String? ,
        userKakaoOwnNumber : Int? ,
        userMainPhoto:String?
    ) {
        // 1. 전송할 값 준비
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/userController/join"
        let param: Parameters = [
            "userIdentity": userIdentity!,
            "userId": userId!,
            "userName": userName!,
            "userKakaoId": userKakaoId!,
            "userPassword": userPassword!,
            "userPhoneNumber": userPhoneNumber!,
            "userGender": userGender!,
            "userBirthDay":userBirthDay!,
            "userKakaoOwnNumber": userKakaoOwnNumber!,
            "userMainPhoto": userMainPhoto!,
            "device" : "ios",
        ];
        
        
        AF.request(
            apiURL,
            method: .post,
            parameters: param,
            encoding: URLEncoding.httpBody
        )
            .response
            { response in
            switch response.result {
            case .success:
                print(response.data!);
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    func selectedValue (selectedIndex : Int?) -> String {
        var gender = "";
        switch selectedIndex {
        case 0:
            gender = "M";
        case 1:
            gender = "F";
        default:
            break;
        }
        return gender;
    }
    
    @objc func segconChanged(segcon: UISegmentedControl)
    {

        switch segcon.selectedSegmentIndex{
        case 0:
            print(segcon.titleForSegment(at: 0)!);
        case 1:
            print(segcon.titleForSegment(at: 1)!);
        default:
            return
        }
    }

    @IBAction func clickJoin(_ sender: Any) {
        if(checkNull()){
            print("complete");
            updateProfileImage(imageFileData!);
        }else{
            print("not complete");
        }
    }
    
    @IBAction func imsertPicture(_ sender: Any) {
        self.openLibrary();
    }
    
    func openLibrary(){
        photo.sourceType = .photoLibrary
        present(photo, animated: false, completion: nil)
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            photo.sourceType = .camera
            present(photo, animated: false, completion: nil)
        }
        else{
            print("Camera not available")
        }
    }
    
    
    
    private func updateProfileImage(_ image : UIImage){
        let imageData = image.jpegData(compressionQuality: 1)!
        let url = "http://ply2782ply2782.cafe24.com:8080/userController/saveMainUserPhoto"
        
        upload(image: imageData, to: url)
        
    }
    //end of function
    func upload(image: Data, to url: String) {
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        let uuid = UIDevice.current.identifierForVendor?.uuidString.lowercased() ?? "";
        userMainPhotoName = "\(uuid)_JunTalk.jpg";        
        AF.upload(multipartFormData:{ multiPart in
            multiPart.append(
                image, withName: "userMainPhoto",
                fileName: self.userMainPhotoName,
                mimeType: "image/jpeg")
        }, to: url , headers: headers)
        .uploadProgress(queue: .main, closure: { progress in
            //Current upload progress of file
            print("Upload Progress: \(progress.fractionCompleted)")
        }).response{ response in
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

extension JoinViewController : UIImagePickerControllerDelegate,
                               UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            preViewImageView.image = image
            imageFileData = image;
        }
        
        photo.dismiss(animated: true, completion: nil) //dismiss를 직접 해야함
    }
}

extension JoinViewController : FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    // 날짜 선택 시 콜백 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(dateFormatter.string(from: date) + " 선택됨")
        
    }
    // 날짜 선택 해제 시 콜백 메소드
    public func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        print(dateFormatter.string(from: date) + " 해제됨")
    }
}
