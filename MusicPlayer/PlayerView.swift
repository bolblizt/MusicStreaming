//
//  PlayerView.swift
//  MusicPlayer
//
//  Created by Dominic Edwayne Rivera on 19/7/17.
//  Copyright © 2017 Dominic Edwayne Rivera. All rights reserved.
//

import UIKit
import AVFoundation

protocol PlayerViewDelegate {
    
    func UpdateTableView(index:IndexPath, oldIndex:IndexPath)
    
}


class PlayerView: UIView {
     @IBOutlet weak var timeSlider: UISlider!
     @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var lapseLabel:UILabel!
    @IBOutlet weak var durationLabel:UILabel!
     @IBOutlet weak var albumImage:UIImageView!
    var delegate:PlayerViewDelegate!
    var currentTrack:Music?
    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    var playerLayer:AVPlayerLayer?
    var iscurrentlyPlaying:Bool = false
    var currentRow:Int = 0

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    
    //MARK: Setup MiniPlayer
    
    func SetupMiniPlayer(){

        self.timeSlider?.addTarget(self, action: #selector(PlayerView.playbackSliderValueChanged(_:)), for: .valueChanged)
    }
    
    //MARK: objects used to play audio files
    func SetPlayer(index:IndexPath, playList:PlayList){

        let selectedMusic =  playList.musicList?[index.row]
        var url:URL?
        
        if selectedMusic?.trackName == self.currentTrack?.trackName{
            
            self.player?.play()
            self.playPauseButton!.setImage( UIImage(named:"PauseButton"), for: UIControlState.normal)
        }
        else if let newURL = selectedMusic?.previewSongURL{
            
            url = URL(string: newURL)
            self.currentTrack = selectedMusic
            
            if self.player != nil{
                self.player?.pause()
                self.player = nil
                self.playerLayer = nil
            }
            
            
            let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
            self.currentRow = index.row
            playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            self.player = AVPlayer(playerItem: playerItem)
            self.playerLayer=AVPlayerLayer(player: player!)
            self.playerLayer?.frame=CGRect(x: 0, y: 0, width: 10, height: 50)
            self.layer.addSublayer(self.playerLayer!)
            self.playPauseButton!.setImage( UIImage(named:"PauseButton"), for: UIControlState.normal)
            self.playButtonTapped()
            self.player?.play()
            self.iscurrentlyPlaying = true
            
            let duration : CMTime = playerItem.asset.duration
            let seconds : Float64 = CMTimeGetSeconds(duration)
            
            let mySecs = Int(seconds) % 60
            let myMins = Int(seconds / 60)
            
            let myTimes = String(myMins) + ":" + String(mySecs);
            self.durationLabel.text = myTimes;
            
            
            self.timeSlider!.maximumValue = Float(seconds)
            self.timeSlider!.isContinuous = false
            self.timeSlider!.tintColor = UIColor.green
            
            
            //subroutine used to keep track of current location of time in audio file
            player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main) { (CMTime) -> Void in
                if self.player!.currentItem?.status == .readyToPlay {
                    let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                    
                    //comment out if you don't want continous play
                    if ((time == seconds) && (index.row != (playList.musicList?.count)! - 1)){
                        self.contPlay(index: index, playList: playList)
                    }
                    
                    let trackSecs2 = Int(time) % 60
                    let trackMins2 = Int(time / 60)
                    
                    let trackLapse = String(trackMins2) + ":" + String(trackSecs2);
                    self.lapseLabel.text = trackLapse;
                    self.timeSlider!.value = Float ( time );
                }
                
            }
        }
    }
    
    
 //MARK: Player for search items only
    func SetPlayerResult(index:IndexPath, filtered:[Music]){
        
        
        if self.player != nil{
            self.player?.pause()
            self.player = nil
            self.playerLayer = nil
        }
        
        let selectedMusic = filtered[index.row]
        let url = URL(string: (selectedMusic.previewSongURL))
        let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
        playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        self.player = AVPlayer(playerItem: playerItem)
        self.playerLayer=AVPlayerLayer(player: player!)
        self.playerLayer?.frame=CGRect(x: 0, y: 0, width: 10, height: 50)
        self.layer.addSublayer(self.playerLayer!)
        self.playPauseButton!.setImage( UIImage(named:"PauseButton"), for: UIControlState.normal)
        self.playButtonTapped()
        self.player?.play()
        self.iscurrentlyPlaying = true
        
        
        let duration : CMTime = playerItem.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        let mySecs = Int(seconds) % 60
        let myMins = Int(seconds / 60)
        
        let myTimes = String(myMins) + ":" + String(mySecs);
        self.durationLabel.text = myTimes;
        
        
        self.timeSlider!.maximumValue = Float(seconds)
        self.timeSlider!.isContinuous = false
        self.timeSlider!.tintColor = UIColor.green
        
        
        //subroutine used to keep track of current location of time in audio file
        player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player!.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                
                let trackSecs2 = Int(time) % 60
                let trackMins2 = Int(time / 60)
                
                let trackLapse = String(trackMins2) + ":" + String(trackSecs2);
                self.lapseLabel.text = trackLapse;
                self.timeSlider!.value = Float ( time );
            }
            
        }
    }
    
    
    //MARK: AVPlayer Interrupted
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if  keyPath == "status"  {
            if self.player?.currentItem?.status == .failed{
                
                self.MakeChangesOnPlayerState()
                self.currentTrack = nil
                 let userDict:[String:Int] = ["songRow":self.currentRow]
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name(rawValue: "streamingError"), object: nil, userInfo: userDict)
                
            } else if self.player?.currentItem?.status == .readyToPlay {
                
                
                
            } else if self.player?.status == .unknown {
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name(rawValue: "errorFetching"), object: nil)
                
            }
        }
    }

    func MakeChangesOnPlayerState(){
        DispatchQueue.main.async {
            self.playPauseButton.setImage(UIImage(named:"PlayButton"), for: .normal)
            self.player = nil
        }
       
    }
    
    //MARK: Slider value change
    //Function called when sliders is adjusted manually.
 
    func playbackSliderValueChanged(_ playbackSlider:UISlider)
    {
        
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(seconds, 1)
        
        player!.seek(to: targetTime)
        
        if player!.rate == 0
        {
            player?.play()
        }
    }
    
    //MARK: Load the Image on side player
    func LoadImage(songIndex:IndexPath, listSong:[Music]){
        
        var selectedTrack:Music?
     
            selectedTrack = listSong[(songIndex.row)]
        
        DispatchQueue.global(qos: .utility).async {
            if let url = NSURL(string: (selectedTrack?.albumArtURL)!) {
                if let data = NSData(contentsOf: url as URL) {
                    DispatchQueue.main.async {
                        self.albumImage.image = UIImage(data: data as Data)
                    }
                    
                }
            }
            
        }
        
    }

    
    //MARK: Stream and update the play button
    func playButtonTapped()
    {
       
        if self.player?.rate == 0
        {
            self.player!.play()
           self.iscurrentlyPlaying = true
             self.playPauseButton.setImage( UIImage(named:"PauseButton"), for: .normal)
           
        } else {
            self.player!.pause()
            self.playPauseButton.setImage(UIImage(named:"PlayButton"), for: .normal)
            self.iscurrentlyPlaying = false
        }
    }
    
    
    //MARK: Continous music stream
    func contPlay(index:IndexPath, playList:PlayList){
        
        if(index.row < (playList.musicList?.count)! - 1){
            let nextSong = index.row + 1
            let nextSongIndex = IndexPath(row: nextSong, section: 0)

            player!.pause()
            player = nil
            self.SetPlayer(index: nextSongIndex, playList: playList)
            self.LoadImage(songIndex: nextSongIndex, listSong: playList.GetMusicList())
            self.delegate?.UpdateTableView(index: nextSongIndex, oldIndex:index)
        }
    }
    
    
    
}
