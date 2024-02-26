//
//  PageCollectionViewCell.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/05/10.
//

import UIKit
import Alamofire

class PageCollectionViewCell: UICollectionViewCell {
    
    var musicListData : [Dictionary<String,Any>] = [];
    var isPaging: Bool = false // 현재 페이징 중인지 체크하는 flag
    var hasNextPage: Bool = false // 마지막 페이지 인지 체크 하는 flag
    var clickProtocal : ClickIndexItem?;
    @IBOutlet weak var itemListTableView: UITableView!
    var pageNum :Int = 0;
    
    override func layoutSubviews() {
        super.layoutSubviews()
        musicListData.removeAll();
        self.itemListTableView.delegate = self
        self.itemListTableView.dataSource = self
        pagingMusicList(page: pageNum);
        self.itemListTableView.tableFooterView = UIView(frame: .zero)
    }
    
    
    func paging() {
        if(self.musicListData.count > (10 * pageNum)){
            pageNum += 1;
            pagingMusicList(page: pageNum);
        }
    }
    
    
    func pagingMusicList(page : Int?){
        let apiURL = "http://ply2782ply2782.cafe24.com:8080/musicController/music/popsong";
        let param: Parameters =
        [
            "pageNum" : page! as Any,
        ];
        AF.request(apiURL, method: .post, parameters: param, encoding: URLEncoding.httpBody).response{ response in switch response.result {
        case .success:
            do{
                if let jsonArray = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [Dictionary<String,Any>] {
                    
                    for item in jsonArray{
                        self.musicListData.append(item);
                    }
                    self.isPaging = false // 페이징이 종료 되었음을 표시
                    self.itemListTableView.reloadData()
                    
                    
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
}


class MusicCell : UITableViewCell{
    
    @IBOutlet weak var musicTitleLabel: UILabel!
    @IBOutlet weak var musicImage: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        musicImage.image = nil;
        musicTitleLabel.text = nil;
    }
}

extension PageCollectionViewCell : UITableViewDataSource ,UITableViewDelegate {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicListData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let musicCell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath) as? MusicCell else {
            return UITableViewCell();
        }
        musicCell.musicTitleLabel.text = self.musicListData[indexPath.row]["musicName"] as? String;
        return musicCell;
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("indexPath.row \(indexPath.row)");
        clickProtocal?.clickItemRow(index: indexPath.row , musicName: self.musicListData[indexPath.row]["musicName"] as? String);
        
    }
}






extension PageCollectionViewCell {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let contentOffset_y = scrollView.contentOffset.y
        let tableViewContentSize = self.itemListTableView.contentSize.height
        let pagination_y = tableViewContentSize * 0.2

        if contentOffset_y > tableViewContentSize - pagination_y {
            if(!isPaging){
                self.beginPaging();
            }
        }
    }

    func beginPaging() {
        isPaging = true // 현재 페이징이 진행 되는 것을 표시
        // Section 1을 reload하여 로딩 셀을 보여줌 (페이징 진행 중인 것을 확인할 수 있도록)
        DispatchQueue.main.async {
            self.itemListTableView.reloadSections(IndexSet(integer: 0), with: .none)
        }

        // 페이징 메소드 호출
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.paging()
        }
    }
}
