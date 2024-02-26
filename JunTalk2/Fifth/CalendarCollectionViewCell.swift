//
//  CalendarCollectionViewCell.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/07/24.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVKit
import Kingfisher





class CalendarCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet weak var calendarItemCollectionVIew: UICollectionView!
        
    var clickProtocal : CoolectionViewClickWithMoveViewController!;
    let now = Date()
    var cal = Calendar.current
    let dateFormatter = DateFormatter()
    var components = DateComponents()
    var days: [String] = []
    var daysCountInMonth = 0 // 해당 월이 며칠까지 있는지
    var weekdayAdding = 0 // 시작일
    var mainClubListArray : [Dictionary<String,Any>] = [];
    var hasItemMap = [String:Int]();
    var user_Index : Int = 0;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("awakeFromNib");
        // Initialization code
        self.initCollection()
        self.initView();
        self.clubList(user_Index: user_Index);
    }
    
    func clubList(user_Index : Int?){
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/clubController/clubList";
        
        let param: Parameters =
        [
            "user_Index" : user_Index! as Any,
        ];
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).response{ response in switch response.result {            
        case .success:
            do{
                let json = JSON(response.data!);
                self.mainClubListArray = [];
                
                let jsonData = json["clubList"].stringValue.data(using: String.Encoding.utf8);
                
                
                
                if let jsonArray = try JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments) as? [Dictionary<String,Any>] {
                    
                    for item in jsonArray{
                        self.mainClubListArray.append(item);
                    }
                    self.calendarItemCollectionVIew.reloadData()
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
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("layoutSubviews")     
    }
    
    
    override func prepareForReuse() {
        print("prepareForReuse 재사용")        
        components.year = cal.component(.year, from: now)
        components.month = cal.component(.month, from: now)
        components.day = 1
        self.calculation()
        self.calendarItemCollectionVIew.reloadData()
    }
    
    // 뷰을 초기 설정
    private func initView() {
        dateFormatter.dateFormat = "yyyy년 MM월"
        dateFormatter.locale = Locale(identifier:"ko_KR")
        components.year = cal.component(.year, from: now)
        components.month = cal.component(.month, from: now)
        components.day = 1
        self.calculation()
        
        self.calendarItemCollectionVIew.reloadData()
    }
    
    
    func calculation() {
        // 이 과정을 해주는 이유는 예를 들어 2020년 4월이라 하면 4월 1일은 수요일 즉, 수요일이 달의 첫날이 됩니다.  수요일은 component의 4 이므로 CollectionView에서 앞의 3일은 비울 필요가 있으므로 인덱스가 1일부터 시작할 수 있도록 해줍니다. 그래서 2 - 4 해서 -2부터 시작하게 되어  정확히 3일 후부터 1일이 시작하게 됩니다.
        //    1  일요일 2 - 1  -> 0번 인덱스부터 1일 시작
        //    2 월요일 2 - 2  -> 1번 인덱스부터 1일 시작
        //    3 화요일 2 - 3  -> 2번 인덱스부터 1일 시작
        //    4 수요일 2 - 4  -> 3번 인덱스부터 1일 시작
        //    5 목요일 2 - 5  -> 4번 인덱스부터 1일 시작
        //    6 금요일 2 - 6  -> 5번 인덱스부터 1일 시작
        //    7 토요일 2 - 7  -> 6번 인덱스부터 1일 시작
        // 월 별 일 수 계산
        let firstDayOfMonth = cal.date(from: components)
        let firstWeekday = cal.component(.weekday, from: firstDayOfMonth!) // 해당 수로 반환이 됩니다. 1은 일요일 ~ 7은 토요일
        daysCountInMonth = cal.range(of: .day, in: .month, for: firstDayOfMonth!)!.count
        weekdayAdding = 2 - firstWeekday
        
        self.days.removeAll()
        for day in weekdayAdding...daysCountInMonth {
            if day < 1 { // 1보다 작을 경우는 비워줘야 하기 때문에 빈 값을 넣어준다.
                self.days.append("")
            } else {
                self.days.append(String(day))
            }
        }
                
    }
    
    
    // CollectionView의 초기 설정
    private func initCollection() {
        self.calendarItemCollectionVIew.delegate = self
        self.calendarItemCollectionVIew.dataSource = self
        self.calendarItemCollectionVIew.register(UINib(nibName: "CalendarItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "calendarItemCell")
    }
    
}



extension CalendarCollectionViewCell : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // 선택 안한 부분 스타일 커스텀
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        
    }
    
    //  선택 한 부분 스타일 커스텀
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     
        let yearString = "\(components.year!)"
        var monthString = "\(components.month!)"
        if(Int(monthString)! > 9){
            monthString = "\(components.month!)"
        }else{
            monthString = "0\(components.month!)"
        }
        
        var dayString = "\(days[indexPath.row])"
        
        if(dayString != ""  && Int(dayString)! > 9 ){
           dayString = "\(days[indexPath.row])"
        }else{
            dayString = "0\(days[indexPath.row])"
        }
        
        let itemRegDate = "\(yearString)-\(monthString)-\(dayString)";
        
        self.clickProtocal.clickItem(string: itemRegDate);
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.days.count // 일의 수
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarItemCell", for: indexPath) as! CalendarItemCollectionViewCell
        
        cell.dateLabel.text = days[indexPath.row] // 일
        cell.itemCountLabel.isHidden = true;
                
        if indexPath.row % 7 == 0 { // 일요일
            cell.dateLabel.textColor = .red
        } else if indexPath.row % 7 == 6 { // 토요일
            cell.dateLabel.textColor = .blue
        } else { // 월요일 좋아(평일)
            cell.dateLabel.textColor = .black
        }
        
        
        let yearString = "\(components.year!)"
        var monthString = "\(components.month!)"
        if(Int(monthString)! > 9){
            monthString = "\(components.month!)"
        }else{
            monthString = "0\(components.month!)"
        }
        
        var dayString = "\(days[indexPath.row])"
        
        if(dayString != ""  && Int(dayString)! > 9 ){
           dayString = "\(days[indexPath.row])"
        }else{
            dayString = "0\(days[indexPath.row])"
        }
        
        let itemRegDate = "\(yearString)-\(monthString)-\(dayString)";
                        
        
        hasItemMap = [String:Int]();
        for item in self.mainClubListArray{
            let mainClubListRegDate = item["regDate"] as! String;
            if(mainClubListRegDate == itemRegDate){
                if(hasItemMap[mainClubListRegDate] != nil){
                    hasItemMap[mainClubListRegDate]! += 1
                }else{
                    hasItemMap[mainClubListRegDate] = 1;
                }
                cell.itemCountLabel.isHidden = false;
                cell.itemCountLabel.text = "\(hasItemMap[mainClubListRegDate]!)";
                
                cell.itemCountLabel.textColor = .white
                cell.itemCountLabel.layer.backgroundColor = UIColor.green.cgColor
                cell.itemCountLabel.layer.borderColor = UIColor.green.cgColor
                cell.itemCountLabel.layer.cornerRadius = 0.5 * cell.itemCountLabel.bounds.size.width
            }
        }
        self.monthLabel.text = dateFormatter.string(from: cal.date(from: components)!);
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //        print("willDisplay: \(indexPath.row)")
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //        print("didEndDisplaying: \(indexPath.row)")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let myBoundSize: CGFloat = UIScreen.main.bounds.size.width
        let collectionViewWidth = collectionView.bounds.width - 10
        let cellSize : CGFloat = ( collectionViewWidth / 7 )
        
        return CGSize(width: cellSize, height: (cellSize + 50))
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
