//
//  ViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/04/19.
//

import UIKit
import Alamofire
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import SwiftyJSON
import AuthenticationServices


class ViewController: UIViewController {
    
    
    @IBOutlet weak var managerModelLayout: UIStackView!
    
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var kakaoButton: UIButton!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    var userModel = UserData?.self;
    //timer
    var mTimer : Timer?
    var number : Int = 0
    var stringArray : [String] = ["optimistic", "different", "awesome", "positive", "believer"];
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("메모리에 View가 Load됨 (viewDidLoad)")
        startTimer();
        self.idTextField.layer.borderColor = UIColor.gray.cgColor
        self.passwordTextField.layer.borderColor = UIColor.gray.cgColor
        managerModeIsActivated();
        self.hideKeyboard();
      
        setUI();
    }
    
    func setUI() {
        let appleBtn = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        appleBtn.addTarget(self, action: #selector(appleLoginTapped), for: .touchDown)
        view.addSubview(appleBtn)
        appleBtn.translatesAutoresizingMaskIntoConstraints = false
        appleBtn.topAnchor.constraint(equalTo: subLabel.bottomAnchor, constant: 40).isActive = true
        appleBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    
    
    
    @objc private func appleLoginTapped() {
                
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self as? ASAuthorizationControllerDelegate
        authorizationController.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
        authorizationController.performRequests()
       
        
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
        stopTimer();
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("view가 사라짐 (viewDidDisappear)")
    }
    
    @IBAction func loginCheck(_ sender: Any) {
        let userId = idTextField.text;
        let password = passwordTextField.text;
        myModel(_userId: userId, _password: password);
    }
    
    
    
    
    func updateToken(userKakaoOwnNumber : Int?){
        let firebaseToken = UserDefaults.standard.object(forKey: "firebaseToken")
        
        if(firebaseToken != nil){
            let apiURL = "http://ply2782ply2782.cafe24.com:8080/fcmController/updateToken"
            
            let param: Parameters = [
                "userToken": firebaseToken! as Any,
                "userKakaoOwnNumber": userKakaoOwnNumber! as Any];
            
            AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).response { response in
                switch response.result {
                case .success:
                    print("firebaseToken update success");
                    break
                    
                case .failure(let error):
                    print(error)
                    return
                }
            }
        }
    }
    
    
    @IBAction func kakaoLogin(_ sender: Any) {
        //카카오 소셜 로그인
        UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
            if let error = error {
                print(error)
            }
            else {
                print("loginWithKakaoAccount() success.")
                
                //do something
                let realOauth = oauthToken;
                print("realOauth \(realOauth!)");
                UserApi.shared.me() {(user, error) in
                    if let error = error {
                        print(error)
                    }
                    else {
                        let myInfo = user;
                        self.isExistOfId(_userKakaoOwnNumber: myInfo?.id)
                    }
                }
            }
        }
        
    }
    
    
    func managerModeIsActivated() {
        // 1. 전송할 값 준비
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/userController/managerModeIsActivated"
        AF.request(apiURL, method: .post, parameters: nil, encoding: URLEncoding.httpBody).response{ response in
            switch response.result {
            case .success:
                do{
                    if let jsonArray = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? Bool {
                        
                        if(jsonArray){
                            self.managerModelLayout.isHidden = false;
                        }else{
                            self.managerModelLayout.isHidden = true;
                        }
                    }else{
                        print("bad Json");
                    }
                    
                }catch(let error){
                    print("error : \(error)");
                }
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    func isExistOfId(_userKakaoOwnNumber:Int64?) {
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/userController/isExistOfId";
        let param: Parameters =
        [
            "userKakaoOwnNumber": _userKakaoOwnNumber! as Any,
        ];
        AF.request(
            apiURL,
            method: .get,
            parameters: param,
            headers: ["Content-Type":"application/json", "Accept":"application/json; charset=utf-8"])
        .validate(statusCode: 200..<300)
        .response{ response in
            switch response.result {
            case .success:
                let dataJson = JSON(response.data!);
                if(dataJson.isEmpty){
                    
                    guard let joinConroller = self.storyboard?.instantiateViewController(withIdentifier: "JoinViewController") as? JoinViewController else { return }
                    // 화면 전환 애니메이션 설정
                    joinConroller.modalTransitionStyle = .coverVertical
                    // 전환된 화면이 보여지는 방법 설정 (fullScreen)
                    joinConroller.modalPresentationStyle = .fullScreen
                    self.present(joinConroller, animated: true, completion: nil)
                    
                }else{
                    
                    
                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(dataJson)
                    {
                        UserDefaults.standard.set(encoded, forKey: "myModel")
                    }
                    
                    let userOwnKakaoNumber : Int = dataJson["userKakaoOwnNumber"].rawValue as! Int;
                    
                    
                    self.updateToken(userKakaoOwnNumber: userOwnKakaoNumber);
                    
                    guard let tabViewController = self.storyboard?.instantiateViewController(withIdentifier: "tabViewController") as? TabViewController else { return }
                    // 화면 전환 애니메이션 설정
                    tabViewController.modalTransitionStyle = .coverVertical
                    // 전환된 화면이 보여지는 방법 설정 (fullScreen)
                    tabViewController.modalPresentationStyle = .fullScreen
                    self.present(tabViewController, animated: true, completion: nil)
                }
                
                return
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    func makeCATransitionLabel(_ label: UILabel) {
        let transition = CATransition()
        transition.duration = 1
        transition.timingFunction = .init(name: .easeInEaseOut)
        transition.type = .push
        transition.subtype = .fromTop
        label.layer.add(transition,forKey:CATransitionType.push.rawValue)
        
    }
    
    
    func myModel(_userId:String? , _password:String?) {
        // 1. 전송할 값 준비
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/userController/managerLogin"
        let param: Parameters = [
            "userId": _userId! as Any,
            "password": _password! as Any];
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).responseDecodable(of:userModel.self){ response in
            switch response.result {
            case .success:
                
                self.isExistOfId(_userKakaoOwnNumber: 1874047916)
//                guard let tabViewController = self.storyboard?.instantiateViewController(withIdentifier: "tabViewController") as? TabViewController else { return }
//                // 화면 전환 애니메이션 설정
//                tabViewController.modalTransitionStyle = .coverVertical
//                // 전환된 화면이 보여지는 방법 설정 (fullScreen)
//                tabViewController.modalPresentationStyle = .fullScreen
//                self.present(tabViewController, animated: true, completion: nil)
                
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func startTimer(){
        if let timer = mTimer {
            //timer 객체가 nil 이 아닌경우에는 invalid 상태에만 시작한다
            if !timer.isValid {
                /** 1초마다 timerCallback함수를 호출하는 타이머 */
                mTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
            }
        }else{
            //timer 객체가 nil 인 경우에 객체를 생성하고 타이머를 시작한다
            /** 1초마다 timerCallback함수를 호출하는 타이머 */
            mTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
        }
    }
    
    
    func stopTimer(){
        if let timer = mTimer {
            if(timer.isValid){
                timer.invalidate()
            }
        }
        number = 0
    }
    
    
    
    
    //타이머가 호출하는 콜백함수
    @objc func timerCallback(){
        number += 1
        
        if(number >= stringArray.count){
            number = 0;
        }
        subLabel.text = String(stringArray[number]);
        makeCATransitionLabel(subLabel);
    }
    
    
    
    
}




extension ViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    // 로그인 진행하는 화면 표출
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    // Apple ID 연동 성공 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            if  let authorizationCode = appleIDCredential.authorizationCode,
                let identityToken = appleIDCredential.identityToken,
                let authString = String(data: authorizationCode, encoding: .utf8),
                let tokenString = String(data: identityToken, encoding: .utf8) {
                print("authorizationCode: \(authorizationCode)")
                print("identityToken: \(identityToken)")
                print("authString: \(authString)")
                print("tokenString: \(tokenString)")
                
                
                self.isExistOfId(_userKakaoOwnNumber: 1);
            }
            
            print("useridentifier: \(userIdentifier)")
            print("fullName: \(fullName)")
            print("email: \(email)")
            
        case let passwordCredential as ASPasswordCredential:
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            print("username: \(username)")
            print("password: \(password)")
            
        default:
            break
        }
    }
    
    // Apple ID 연동 실패 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("error")
    }
}
