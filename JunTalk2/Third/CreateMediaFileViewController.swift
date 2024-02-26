//
//  CreateMediaFileViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/09/12.
//
import Alamofire
import SwiftyJSON
import AVFoundation
import AVKit
import UIKit
import Kingfisher
import MediaPlayer



struct SongInfo {
    
    var albumTitle: String
    var artistName: String
    var songTitle:  String
    
    var songId   :  NSNumber
    var songURL : NSURL
    var trackNum : NSNumber
    var albumartwork : UIImage?
}

struct AlbumInfo {
    
    var albumTitle: String
    var albumArtist : String
    var albumartwork : UIImage?
    var songs: [SongInfo]
}

class SongQuery {
    
    func get(songCategory: String) -> [AlbumInfo] {
        
        var albums: [AlbumInfo] = []
        let albumsQuery: MPMediaQuery
        albumsQuery = MPMediaQuery.albums()
        
        let albumItems: [MPMediaItemCollection] = albumsQuery.collections! as [MPMediaItemCollection]
        
        for album in albumItems {
            
            let albumItems: [MPMediaItem] = album.items as [MPMediaItem]
            
            var songs: [SongInfo] = []
            
            var albumTitle: String = ""
            var albumArtist : String = ""
            var albumartwork : UIImage? = nil
            
            for song in albumItems {
                
                albumTitle = song.value( forProperty: MPMediaItemPropertyAlbumTitle ) as! String
                albumArtist = song.value( forProperty: MPMediaItemPropertyArtist ) as! String
                if let artwork: MPMediaItemArtwork = song.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork{
                    albumartwork = artwork.image(at: CGSize(width: 200, height: 200))
                }
                
                let songInfo: SongInfo = SongInfo(
                    albumTitle: song.value( forProperty: MPMediaItemPropertyAlbumTitle ) as! String,
                    artistName: song.value( forProperty: MPMediaItemPropertyArtist ) as! String,
                    songTitle:  song.value( forProperty: MPMediaItemPropertyTitle ) as! String,
                    songId:     song.value( forProperty: MPMediaItemPropertyPersistentID ) as! NSNumber,
                    songURL:  song.value(forKey: MPMediaItemPropertyAssetURL) as! NSURL,
                    trackNum: song.value(forProperty: MPMediaItemPropertyAlbumTrackCount) as! NSNumber,
                    albumartwork: albumartwork
                )
                songs.append( songInfo )
            }
            
            let albumInfo: AlbumInfo = AlbumInfo(
                
                albumTitle: albumTitle,
                albumArtist: albumArtist,
                albumartwork: albumartwork,
                songs: songs
            )
            
            albums.append( albumInfo )
        }
        return albums
    }
}



class CreateMediaFileViewController: UIViewController {
    
    @IBOutlet var fileTableView: UITableView!
    @IBOutlet var closeImageView: UIImageView!
    var userId : String? = "";
    let photo = UIImagePickerController()
    var fileMusicArray : [String?] = [];
    var fileVideoArray : [URL?] = [];
    var fileSumArray :[Any] = [];
    var albums: [AlbumInfo] = []
    var songQuery: SongQuery = SongQuery()
    var audio: AVAudioPlayer?
    let dateFormatter = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH_mm_ss"
        dateFormatter.locale = Locale(identifier:"ko_KR")
        
        fileTableView.delegate = self;
        fileTableView.dataSource = self;
        photo.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(imageTapped))
        closeImageView.isUserInteractionEnabled = true
        closeImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @IBAction func createFileAction(_ sender: Any) {
        uploadVideoFile(userId: userId);
        
    }
    
    func uploadVideoFile(userId : String?){
        
        let url = "http://ply2782ply2782.cafe24.com:8080/videoController/videoUpload"
        
        let header: HTTPHeaders = [
            "Content-Type" : "multipart/form-data"
        ]
        
        let parameters: [String : Any] = [
            "userId": userId!,
            "regDate" : dateFormatter.string(from: Date()),
        ]
        
        AF.upload(multipartFormData: { MultipartFormData in
            
            for (key, value) in parameters {
                MultipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            }
            
            for item in self.fileSumArray {
                let uuid = UIDevice.current.identifierForVendor?.uuidString.lowercased() ?? "";
                let photoName = "\(uuid)_JunTalk.mp4";
                MultipartFormData.append(
                    item as! URL,
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
                    
                    NotificationCenter.default.post(name: .videoRefresh, object: nil)
                    
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
    
    
    @IBAction func selectVideoAction(_ sender: Any) {
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
    
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0)) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    
    
    @IBAction func selectMusicAction(_ sender: Any) {
        
        showToast(message: "준비중입니다.")
        MPMediaLibrary.requestAuthorization { (status) in
            if status == .authorized {
                self.albums = self.songQuery.get(songCategory: "")
                DispatchQueue.main.async {
                    if self.albums.count == 0 {
                        print("album count is  0");
                    }else{
                        print("album count is over 0");
                    }
                }
            }
        }
        
        
    }
    
    @objc func imageTapped(){
        self.dismiss(animated: true);
    }
}


class FileListTableViewCell : UITableViewCell{
    
    @IBOutlet var thumbNailImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbNailImageView.image = nil;
        titleLabel.text = nil;
    }
}

extension CreateMediaFileViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(fileSumArray.count > 5){
            return 5;
        }else{
            return fileSumArray.count;
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200;
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FileListTableViewCell", for: indexPath) as? FileListTableViewCell else {
            return UITableViewCell()
        }
        
        cell.thumbNailImageView.layer.cornerRadius = 10
        cell.thumbNailImageView.layer.borderWidth = 1
        cell.thumbNailImageView.layer.borderColor = UIColor.clear.cgColor
        cell.thumbNailImageView.clipsToBounds = true
        cell.thumbNailImageView.image = self.generateThumbnail(path: self.fileSumArray[indexPath.row] as! URL);
        cell.titleLabel.text = "Video";
        
        return cell;
        
    }
}





extension CreateMediaFileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
        
        if let video = info[UIImagePickerController.InfoKey.mediaURL] {
            self.fileSumArray.append(video);
            self.fileTableView.reloadData();
        }
        photo.dismiss(animated: true, completion: nil) //dismiss를 직접 해야함
    }
}
