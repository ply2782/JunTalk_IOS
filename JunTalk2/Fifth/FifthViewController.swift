//
//  FifthViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/05/15.
//


import UIKit
import Alamofire
import SwiftyJSON
import AVKit
import Kingfisher





protocol CollectionViewReloadDataProtocal{
    func isClick();
}


protocol CoolectionViewClickWithMoveViewController {
    func clickItem( string: String?);
}

class FifthViewController: UIViewController ,CollectionViewReloadDataProtocal , CoolectionViewClickWithMoveViewController{
    
    func clickItem(string: String?) {
        
        let calendarDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "CalendarDetailViewController") as! CalendarDetailViewController
        calendarDetailViewController.modalPresentationStyle = .overCurrentContext
        calendarDetailViewController.modalTransitionStyle = .crossDissolve
        calendarDetailViewController.user_Index = self.myModel.user_Index;
        calendarDetailViewController.currentDate = string!
        self.present(calendarDetailViewController, animated: false, completion: nil)
    }
    
    func isClick() {
        self.collectionView.reloadData();
    }
    
    
    
    @IBOutlet weak var clubListButton: UIButton!
    @IBOutlet weak var myMenuButton: UIButton!
    var clickProtocal  : CoolectionViewClickWithMoveViewController!;
    var delegate : CollectionViewReloadDataProtocal!;
    @IBOutlet weak var collectionView: UICollectionView!
    var clubListData : [Dictionary<String,Any>] = [];
    let dateFormatter = DateFormatter()
    var cal = Calendar.current
    var components = DateComponents()
    let now = Date()
    var myModel : UserData!;
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateClubList"{
            if let destination = segue.destination as?
                CreateClubListViewController {
                destination.myModel = self.myModel;
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initCollection();
        let data = UserDefaults.standard.object(forKey: "myModel")
        if(data != nil){
            let decoder = JSONDecoder()
            self.myModel = try? decoder.decode(UserData.self, from: data as! Data)
        }
        components.year = cal.component(.year, from: now)
        components.month = cal.component(.month, from: now)
        components.day = 1
        dateFormatter.dateFormat = "yyyy년 MM월"
        dateFormatter.locale = Locale(identifier:"ko_KR")
        self.delegate = self;
        self.myMenuButton.setTitle("", for: .normal)
        self.clickProtocal = self;
        self.clubListButton.setTitle("", for: .normal);
        
     
    }
    
    
    
    // CollectionView의 초기 설정
    private func initCollection() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "CalendarCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "calendarCell")
    }
}


extension FifthViewController : UICollectionViewDelegate , UICollectionViewDelegateFlowLayout , UICollectionViewDataSource , UIScrollViewDelegate {
    
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
        return 12
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as? CalendarCollectionViewCell else { return UICollectionViewCell() }
                
        cell.user_Index = myModel.user_Index;
        cell.clickProtocal = self.clickProtocal;
        cell.components.month! += indexPath.row;
        cell.calculation()
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    
        print("willDisplay: \(indexPath.row)")
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        print("didEndDisplaying: \(indexPath.row)")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewWidth = collectionView.bounds.width
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
        if self.collectionView.contentOffset.x > self.collectionView.contentSize.width-self.collectionView.bounds.size.width {
            print("end");
        }
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        print("scrollViewWillEndDragging");
        
        
    }
    
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        self.collectionView.reloadData()
        
    }
    
    
    
}
