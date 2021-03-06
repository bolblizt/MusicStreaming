//
//  SidePlayerView.swift
//  MusicPlayer
//
//  Created by Dominic Edwayne Rivera on 22/7/17.
//  Copyright © 2017 Dominic Edwayne Rivera. All rights reserved.
//

import UIKit
import AVFoundation

protocol SidePlayerDelegate {
     func UpdateTableView(index:IndexPath, oldIndex:IndexPath)
}

class SidePlayerView: UIView{

    
    @IBOutlet weak var playPauseButtonLandscape: UIButton!
    @IBOutlet weak var timeSliderLandscape: UISlider!
    @IBOutlet weak var albumImage:UIImageView!
    @IBOutlet weak var sideLapseLabel:UILabel!
    @IBOutlet weak var sideDurationLabel:UILabel!
    var delegate:SidePlayerDelegate!
    
    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    var playerLayer:AVPlayerLayer?
    var iscurrentlyPlaying:Bool = false
    
    
    //MARK: Setup MiniPlayer
    
    func SetupMiniPlayer(){
        
        
        self.timeSliderLandscape?.addTarget(self, action: #selector(SidePlayerView.playbackSliderValueChanged(_:)), for: .valueChanged)
        
    }
    
    //setup avplayer avPlayerItem --> objects used to play audio files
    func SetPlayer(index:IndexPath, playList:PlayList){
        
        
        if self.player != nil{
            self.player?.pause()
            self.player = nil
            self.playerLayer = nil
        }
        
        let selectedMusic =  playList.songList?.object(at: index.row) as? Music
        let url = URL(string: (selectedMusic?.previewSongURL)!)
        let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
        self.player = AVPlayer(playerItem: playerItem)
        
        
        self.playerLayer=AVPlayerLayer(player: player!)
        self.playerLayer?.frame=CGRect(x: 0, y: 0, width: 10, height: 50)
        self.layer.addSublayer(self.playerLayer!)
        self.playPauseButtonLandscape!.setImage( UIImage(named:"PauseButton"), for: UIControlState.normal)
        self.playPauseButtonLandscape.addTarget(self, action: #selector(SidePlayerView.playButtonTapped(_:)), for: .touchUpInside)
        self.player?.play()
        self.iscurrentlyPlaying = true
        // self.playButtonTapped()
        
        
        let duration : CMTime = playerItem.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        let mySecs = Int(seconds) % 60
        let myMins = Int(seconds / 60)
        
        let myTimes = String(myMins) + ":" + String(mySecs);
        self.sideDurationLabel.text = myTimes;
        
        
        self.timeSliderLandscape!.maximumValue = Float(seconds)
        self.timeSliderLandscape!.isContinuous = false
        self.timeSliderLandscape!.tintColor = UIColor.green
        
        
        //subroutine used to keep track of current location of time in audio file
        player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player!.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                
                //comment out if you don't want continous play
                if ((time == seconds) && (index.row != (playList.songList?.count)! - 1)){
                    self.contPlay(index: index, playList: playList)
                }
                
                let trackSecs2 = Int(time) % 60
                let trackMins2 = Int(time / 60)
                
                let trackLapse = String(trackMins2) + ":" + String(trackSecs2);
                self.sideLapseLabel.text = trackLapse;
                self.timeSliderLandscape!.value = Float ( time );
            }
            
        }
    }
    
    //MARK: Player for search items
    func SetPlayerResult(index:IndexPath, filtered:[Music]){
        
        
        if self.player != nil{
            self.player?.pause()
            self.player = nil
            self.playerLayer = nil
        }
        
        let selectedMusic = filtered[index.row]
        let url = URL(string: (selectedMusic.previewSongURL))
        let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
        self.player = AVPlayer(playerItem: playerItem)
        
        
        self.playerLayer=AVPlayerLayer(player: player!)
        self.playerLayer?.frame=CGRect(x: 0, y: 0, width: 10, height: 50)
        self.layer.addSublayer(self.playerLayer!)
        self.playPauseButtonLandscape!.setImage( UIImage(named:"PauseButton"), for: UIControlState.normal)
        self.playPauseButtonLandscape.addTarget(self, action: #selector(PlayerView.playButtonTapped(_:)), for: .touchUpInside)
        self.player?.play()
        self.iscurrentlyPlaying = true
        // self.playButtonTapped()
        
        
        let duration : CMTime = playerItem.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        let mySecs = Int(seconds) % 60
        let myMins = Int(seconds / 60)
        
        let myTimes = String(myMins) + ":" + String(mySecs);
        self.sideDurationLabel.text = myTimes;
        
        
        self.timeSliderLandscape!.maximumValue = Float(seconds)
        self.timeSliderLandscape!.isContinuous = false
        self.timeSliderLandscape!.tintColor = UIColor.green
        
        
        //subroutine used to keep track of current location of time in audio file
        player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player!.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                
                let trackSecs2 = Int(time) % 60
                let trackMins2 = Int(time / 60)
                
                let trackLapse = String(trackMins2) + ":" + String(trackSecs2);
                self.sideLapseLabel.text = trackLapse;
                self.timeSliderLandscape!.value = Float ( time );
            }
            
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
    
    
    //MARK: PlayButton
    func playButtonTapped(_ sender:UIButton)
    {
        
        if self.player?.rate == 0
        {
            self.player!.play()
            self.iscurrentlyPlaying = true
            sender.setImage( UIImage(named:"PauseButton"), for: .normal)
            // self.playPauseButton!.setImage( UIImage(named:"PauseButton"), for: .normal)
        } else {
            self.player!.pause()
            sender.setImage(UIImage(named:"PlayButton"), for: .normal)
            // self.playPauseButton!.setImage(UIImage(named:"PlayButton"), for: .normal)
            self.iscurrentlyPlaying = false
        }
    }
    
    
    func contPlay(index:IndexPath, playList:PlayList){
        
        if(index.row < (playList.songList?.count)! - 1){
            let nextSong = index.row + 1
            let nextSongIndex = IndexPath(row: nextSong, section: 0)
            
            
            player!.pause()
            player = nil
            self.SetPlayer(index: nextSongIndex, playList: playList)
            self.delegate?.UpdateTableView(index: nextSongIndex, oldIndex:index)
        }
    }

}
