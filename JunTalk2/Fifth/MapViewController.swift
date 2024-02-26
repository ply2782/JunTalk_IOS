//
//  MapViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/09/03.
//

import UIKit
import Alamofire
import SwiftyJSON
import Lottie
import CoreData
import Kingfisher



class MapViewController: UIViewController, MTMapViewDelegate {
    
    var page = 1;
    var isPaging: Bool = false // 현재 페이징 중인지 체크하는 flag
    var hasNextPage: Bool = false // 마지막 페이지 인지 체크 하는 flag
    @IBOutlet var placeListTableView: UITableView!
    @IBOutlet var subView: UIView!
    var mapView: MTMapView?
    var mapPoint1: MTMapPoint?
    var poiItem1: MTMapPOIItem?
    var latitude : Double = 37.576568
    var longitude : Double = 127.029148
    @IBOutlet var textfield: UITextField!
    var searchResult : ResultSearchKeyword!
    var selectPlaceDelegate : SelectPlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            self.searchResult = try ResultSearchKeyword.init();
            placeListTableView.delegate = self;
            placeListTableView.dataSource = self;
            
            
            // 지도 불러오기
            mapView = MTMapView(frame: subView.frame)
            if let mapView = mapView {
                // 델리게이트 연결
                mapView.delegate = self
                // 지도의 타입 설정 - hybrid: 하이브리드, satellite: 위성지도, standard: 기본지도
                mapView.baseMapType = .standard
                // 현재 위치 트래킹
                mapView.currentLocationTrackingMode = .onWithoutHeading
                mapView.showCurrentLocationMarker = true
                // 지도의 센터를 설정 (x와 y 좌표, 줌 레벨 등을 설정)
//                mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude:  37.456518177069526, longitude: 126.70531256589555)), zoomLevel: 3, animated: true)
                self.view.addSubview(mapView)
            }
        }catch{
            print("error");
        }
      
    }
    
    
    
    
    
    
    // poiItem 클릭 이벤트
    func mapView(_ mapView: MTMapView!, touchedCalloutBalloonOf poiItem: MTMapPOIItem!) {
        // 인덱스는 poiItem의 태그로 접근
        let index = poiItem.tag
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // mapView의 모든 poiItem 제거
        for item in mapView!.poiItems {
            mapView!.remove(item as! MTMapPOIItem)
        }
    }
    
    @IBAction func searchingAction(_ sender: Any) {
        let keyword = textfield.text;
        do{
            self.searchResult = try ResultSearchKeyword.init();
            searchingLocation(query: keyword, page: 1);
        }catch{
            print("error");
        }
        
    }
    
    func searchingLocation(query :String?  , page : Int? ){
        
        let apiURL = "https://dapi.kakao.com/v2/local/search/keyword.json";
        let param: Parameters =
        [
            "query" : query!,
            "page" : page!,
        ];
        AF.request(
            apiURL,
            method: .get,
            parameters: param,
            headers: [
                "Content-Type":"application/json",
                "Accept":"application/json; charset=utf-8",
                "Authorization" : "KakaoAK 4891dca7cfbf3148148cb7920ebf4062"
            ])
        .validate(statusCode: 200..<300)
        .responseDecodable(of:ResultSearchKeyword.self){ response in
            switch response.result {
            case .success:
                let metaData = response.value!.meta
                let documents = response.value!.documents;
                
                self.searchResult.meta = metaData;
                for item in documents{
                    self.searchResult.documents.append(item);
                }
                
                self.isPaging = false // 페이징이 종료 되었음을 표시
                self.placeListTableView.reloadData();
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func paging() {
        if(self.searchResult.documents.count > (10 * page)){
            page += 1;
            let keyword = textfield.text;
            searchingLocation(query: keyword, page: page);
        }
    }
}


class PlaceListTableViewCell : UITableViewCell {
    
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var category_nameLabel: UILabel!
    @IBOutlet var place_nameLabel: UILabel!
    @IBOutlet var selectButton: UIButton!
    var delegate : ClickProtocal!
    var indexPath:IndexPath!
    
    override func awakeFromNib(){
        super.awakeFromNib();
        locationLabel.sizeToFit()
        category_nameLabel.sizeToFit()
        place_nameLabel.sizeToFit()
    }
    
    
    @IBAction func clickAction(_ sender: Any) {
        self.delegate?.clickItems(at: indexPath);
    }
    
    override func prepareForReuse() {
        locationLabel.text = nil;
        category_nameLabel.text = nil;
        place_nameLabel.text = nil;
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

extension MapViewController : UITableViewDelegate , UITableViewDataSource, UITableViewDataSourcePrefetching , ClickProtocal {
    
    
    func clickItems(at index: IndexPath) {
        let selectedItem  = self.searchResult.documents[index.row];
        selectPlaceDelegate?.selectPlace(place: selectedItem);
        self.dismiss(animated: true, completion: nil);
    }
    
    
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        print("prefetchRowsAt: \(indexPaths)")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.searchResult.documents.count;
        } else if section == 1 && self.isPaging && self.hasNextPage {
            return 1
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let kakaoMapListCell = tableView.dequeueReusableCell(withIdentifier: "PlaceListTableViewCell", for: indexPath) as? PlaceListTableViewCell else {
            return UITableViewCell();
        }
        
        let item = searchResult.documents[indexPath.row];
        
        kakaoMapListCell.delegate = self
        kakaoMapListCell.indexPath = indexPath
        kakaoMapListCell.place_nameLabel.text = item.place_name;
        kakaoMapListCell.category_nameLabel.text = item.category_name;
        kakaoMapListCell.locationLabel.text = item.address_name
        return kakaoMapListCell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = searchResult.documents[indexPath.row];
        
        self.mapPoint1 = MTMapPoint(geoCoord: MTMapPointGeo(latitude: Double(item.y)!, longitude: Double(item.x)!))
        self.mapView!.setMapCenter(self.mapPoint1, zoomLevel: 3, animated: true)
        poiItem1 = MTMapPOIItem()
        // 핀 색상 설정
        poiItem1!.markerType = .bluePin;
        poiItem1!.mapPoint = self.mapPoint1
        // 핀 이름 설정
        poiItem1!.itemName = item.place_name
        // 맵뷰에 추가!
        mapView!.addPOIItems([poiItem1 as Any]);
        mapView!.select(poiItem1, animated: true);
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("willDisplay: \(indexPath.row)")
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("didEndDisplaying: \(indexPath.row)")
        let itemCell = cell as! PlaceListTableViewCell
        itemCell.prepareForReuse();
    }
    
}

extension MapViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentOffset_y = scrollView.contentOffset.y
        let tableViewContentSize = self.placeListTableView.contentSize.height
        let pagination_y = tableViewContentSize * 0.2
        if contentOffset_y > tableViewContentSize - pagination_y {
            if(!self.isPaging){
                print("isPaging start()")
                self.beginPaging();
            }
        }
    }
    
    func beginPaging() {
        isPaging = true // 현재 페이징이 진행 되는 것을 표시
        // Section 1을 reload하여 로딩 셀을 보여줌 (페이징 진행 중인 것을 확인할 수 있도록)
        DispatchQueue.main.async {
            self.placeListTableView.reloadSections(IndexSet(integer: 1), with: .none)
        }
        
        // 페이징 메소드 호출
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("self.searchResult.meta.is_end \(self.searchResult.meta.is_end)")
            if(self.searchResult.meta.is_end == false){
                self.paging()
            }
        }
    }
}
