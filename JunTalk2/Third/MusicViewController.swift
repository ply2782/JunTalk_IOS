//
//  MusicViewController.swift
//  JunTalk2
//
//  Created by 바틀 on 2022/07/07.
//

import UIKit
import AVFoundation




class MusicViewController: UIViewController{
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var currentPlayStatusSlider: UISlider!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var volumSlider: UISlider!
    @IBOutlet weak var mainThumbNailImageView: UIImageView!
    @IBOutlet weak var closeImageView: UIImageView!
    @IBOutlet weak var movingAfterMusicButton: UIButton!
    @IBOutlet weak var playMusicButton: UIButton!
    @IBOutlet weak var movingBeforeMusicButton: UIButton!
    @IBOutlet weak var addMusicFileImageView: UIImageView!
    @IBOutlet weak var musicTitleLabel: UILabel!
    
    
    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    
    var musicFolder : String? = "";
    var musicName : String? = "";
    fileprivate let seekDuration: Float64 = 10
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.playMusicButton.setTitle("", for: .normal);
        self.movingAfterMusicButton.setTitle("", for: .normal);
        self.movingBeforeMusicButton.setTitle("", for: .normal);
        self.musicTitleLabel.text = musicName!;

        
        volumSlider.addTarget(self, action: #selector(didSlideSlider(_:)), for: .valueChanged)
        currentPlayStatusSlider.addTarget(self, action: #selector(seek(sender:)), for: .valueChanged)
        
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(imageTapped))
        self.closeImageView.isUserInteractionEnabled = true
        self.closeImageView.addGestureRecognizer(tapGestureRecognizer)
        
        let tapGestureRecognizer2 = UITapGestureRecognizer(target:self, action:#selector(downloadThisMusic))
        self.infoImageView.isUserInteractionEnabled = true
        self.infoImageView.addGestureRecognizer(tapGestureRecognizer2)
        
        initPlay();
    }
    
    
    func initPlay(){
        let urlStr = "http://ply2782ply2782.cafe24.com:8080/musicController/musicPlay?name=\(musicFolder!.split(separator: ".")[0])/\(musicName!)"
        
        guard let encodedStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }

        let url = URL(string: encodedStr)!
        let playerItem:AVPlayerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        
        
        let playerLayer=AVPlayerLayer(player: player!)
        playerLayer.frame=CGRect(x:10, y:400, width:100, height:150)
        self.view.layer.addSublayer(playerLayer)
        
        
        let interval = CMTime(seconds: 1, preferredTimescale: 100)
        
        player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] _ in
            self?.updateTime()
        }
        
        
    }
    
    @objc func seek(sender: UISlider) {
        // ✅ 현재 아이템을 가져온다 (없으면 함수 종료)
        guard let currentItem = player?.currentItem else { return }

        // ✅ 슬라이더의 위치를 가져와서 이동할 시간으로 바꾼다.
        let position = Double(sender.value)
            // 👉 slide의 현재 위치 (0 ~ 1)를 Float -> Double
        let seconds = position * currentItem.duration.seconds
            // 👉 이동할 시간대를 계산
        let time = CMTime(seconds: seconds, preferredTimescale: 100)
            // 👉 CMTime 객체로 변경, 100은 소수점 아래 2째자리 까지만 쓰겠다는 뜻 (분모)

        // ✅ 해당 시간대로 이동
        player?.seek(to: time)
    }
    
    
    func updateTime() {
        let currentTime = self.player?.currentItem?.currentTime().seconds ?? 0
        let totalTime = self.player?.currentItem?.duration.seconds ?? 0
        self.currentTimeLabel.text = "\(Int(currentTime))"
        self.currentPlayStatusSlider.value = Float(currentTime / totalTime)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let player = player {
            player.pause();
        }
        player = nil;
    }
    
    
    
    @objc func didSlideSlider(_ slider: UISlider){
        let value = slider.value
        player?.volume = value
    }
    
    
    @objc private func imageTapped() {
        self.dismiss(animated: true);
    }
    
    
    
    
    func DownlondFromUrl(){
            
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as! URL
        
        let destinationFileUrl = documentsUrl.appendingPathComponent("downloadedFile.mp3")
        
        let fileURL = URL(string: "http://ply2782ply2782.cafe24.com:8080/musicController/musicDownLoad2?fileName=\(musicFolder!.split(separator: ".")[0])/\(musicName!)")
        
        
    
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let request = URLRequest(url:fileURL!)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }
                
            } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription);
            }
        }
        task.resume()
    }
    
    
    @objc private func downloadThisMusic(){
        
//        DownlondFromUrl();
        
        if let audioUrl = URL(string: "http://ply2782ply2782.cafe24.com:8080/musicController/musicPlay?name=\(musicFolder!.split(separator: ".")[0])/\(musicName!)"){
            
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            print(destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                
                // if the file doesn't exist
            } else {
                
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: audioUrl) { location, response, error in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        print("File moved to documents folder")
                    } catch {
                        print(error)
                    }
                }.resume()
            }
        }
    }
    
    @IBAction func movingBeforeMusic(_ sender: Any) {
        seekBackWards();
        
    }
    
    
    
    
    
    @IBAction func playMusic(_ sender: Any) {
        if player?.rate == 0 {
            player!.play()
            playMusicButton.setTitle("Pause", for: UIControl.State.normal)
            //playButton!.setImage(UIImage(named: "player_control_pause_50px.png"), forState: UIControlState.Normal)
            
            // decrease image size
            UIView.animate(withDuration: 0.2, animations: {
                self.mainThumbNailImageView.frame =
                CGRect(x: 30, y: 30, width:self.mainThumbNailImageView.frame.size.width-60,
                       height: self.mainThumbNailImageView.frame.size.width-60)
                
            })
            
            
        } else {
            player!.pause()
            
            playMusicButton.setTitle("Play", for: UIControl.State.normal)
            //playButton!.setImage(UIImage(named: "player_control_play_50px.png"), forState: UIControlState.Normal)
            UIView.animate(withDuration: 0.2, animations: {
                self.mainThumbNailImageView.frame =
                CGRect(x: 30, y: 30, width:self.mainThumbNailImageView.frame.size.width,
                       height: self.mainThumbNailImageView.frame.size.width)
                
            })
            
        }
    }
    
    
    @IBAction func movignAfterMusic(_ sender: Any) {
        seekForward();
    }
    
    
    
    func seekBackWards() {
        if player == nil { return }
        let playerCurrenTime = CMTimeGetSeconds(player!.currentTime())
        var newTime = playerCurrenTime - seekDuration
        if newTime < 0 { newTime = 0 }
        player?.pause()
        let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        player?.seek(to: selectedTime)
        player?.play()
        
    }
    
    
    func seekForward() {
   
        if player == nil { return }
        if let duration = player!.currentItem?.duration {
            let playerCurrentTime = CMTimeGetSeconds(player!.currentTime())
            let newTime = playerCurrentTime + seekDuration
            if newTime < CMTimeGetSeconds(duration)
            {
                let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
                player!.seek(to: selectedTime)
            }
            player?.pause()
            player?.play()
        }
    }
    
    
    
    
    func incodingHTML(_ data: Data) -> String? {
        var html = String(data: data, encoding: .utf8)
        guard html == nil else { return html }
        let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0422))
        html = String(data: data, encoding: encoding)
        guard html == nil else { return html }
        html = String(decoding: data, as: UTF8.self)
        return html
    }
    
}
