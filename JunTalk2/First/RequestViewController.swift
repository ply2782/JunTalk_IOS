//
//  RequestViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/06/01.
//

import UIKit
import Alamofire


protocol RefreshRequestProtocal {
    func refresh();
}

class RequestViewController: UIViewController , RefreshRequestProtocal{
    
    
    func refresh() {
        self.noticeArray.removeAll();
        requestQuestionPaging(page: pageNum);
    }
    
    
    
    var refreshRequestProtocalDelegate : RefreshRequestProtocal!
    @IBOutlet weak var noticeTableView: UITableView!
    var noticeArray : [Dictionary<String,Any>] = [];
    var pageNum = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.noticeTableView.delegate = self;
        self.noticeTableView.dataSource = self;
        requestQuestionPaging(page: pageNum);
        refreshRequestProtocalDelegate = self;
    }
    
    @IBAction func closeRequestView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func requestQuestionPaging(page : Int?){
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/commonNoticeController/requestQuestionList";
        let param: Parameters =
        [
            "pageNum" : page! as Any,
        ];
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).response{ response in switch response.result {
        case .success:
            do{
                if let jsonArray = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [Dictionary<String,Any>] {
                    
                    for item in jsonArray{
                        self.noticeArray.append(item);
                    }
                    
                    
                    self.noticeTableView.reloadData();
                    
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "requestSegue"{
            if let destination = segue.destination as?
                RequestInsertViewController {
                
                destination.refreshRequestProtocalDelegate = self.refreshRequestProtocalDelegate;
                
                
            }
        }
    }
}



class noticeCell : UITableViewCell{
    
    @IBOutlet weak var requestTextView: UITextView!
}


extension RequestViewController : UITableViewDataSource , UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.noticeArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let noticeCell = tableView.dequeueReusableCell(withIdentifier: "noticeCell", for: indexPath) as? noticeCell else {
            return UITableViewCell();
        }
        
        let requestContent = self.noticeArray[indexPath.row]["requestContent"]! as? String;
        noticeCell.requestTextView.text = requestContent;
        print("requestContent \(String(describing: requestContent))")
        
        return noticeCell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 40
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("indexPath.row \(indexPath.row)");
    }
    
    
}
