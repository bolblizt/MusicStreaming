//
//  PlayerView.swift
//  MusicPlayer
//
//  Created by Dominic Edwayne Rivera on 19/7/17.
//  Copyright © 2017 Dominic Edwayne Rivera. All rights reserved.
//

import UIKit
import AVFoundation


class PlayerView: UIView {
     @IBOutlet weak var timeSlider: UISlider!
     @IBOutlet weak var playPauseButton: UIButton!
    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    var playerLayer:AVPlayerLayer?
    var iscurrentlyPlaying:Bool = false

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
    
    //setup avplayer avPlayerItem --> objects used to play audio files
    func setPlayer(index:IndexPath, playList:PlayList){
        
        
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
        self.playPauseButton!.setImage( UIImage(named:"PauseButton"), for: UIControlState.normal)
         self.playPauseButton.addTarget(self, action: #selector(PlayerView.playButtonTapped(_:)), for: .touchUpInside)
        self.player?.play()
        self.iscurrentlyPlaying = true
       // self.playButtonTapped()
        
      
        let duration : CMTime = playerItem.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
       // let mySecs = Int(seconds) % 60
        //let myMins = Int(seconds / 60)
          /*
        let myTimes = String(myMins) + ":" + String(mySecs);
        durLabel.text = myTimes;
        
        */
        self.timeSlider!.maximumValue = Float(seconds)
        self.timeSlider!.isContinuous = false
        self.timeSlider!.tintColor = UIColor.green
        
        
        //subroutine used to keep track of current location of time in audio file
        player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player!.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                
                //comment out if you don't want continous play
                
                if(time == seconds && self.currentSong != self.listOfSongs.count-1){
                    self.contPlay()
                }
                
                if time == seconds && 
                
                let mySecs2 = Int(time) % 60
                let myMins2 = Int(time / 60)
                
                let myTimes2 = String(myMins2) + ":" + String(mySecs2);
                //self.curLabel.text = myTimes2;//current time of audio track
                
                
                self.timeSlider!.value = Float ( time );
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
    
    func contPlay(){
        /*
        if(currentSong < listOfSongs.count - 1){
            currentSong = currentSong + 1;
            listNum = listNum + 1;
            if(listNum > 3){
                listNum = 1;
            }
            getListNum()
            if(currentSong > currentList + 2){
                currentList = currentList + 3;
                showSongs()
                
            }
            player!.pause()
            player = nil
            
            setPlayer();
            if player?.rate == 0
            {
                player!.play()
                playButton!.setTitle("Pause", for: UIControlState.normal)
            }
            
        }*/
    }
    
    
   /*
    func playButtonTapped()
    {
        
        if self.player?.rate == 0
        {
            self.player!.play()
            self.iscurrentlyPlaying = true
           // sender.setImage( UIImage(named:"PauseButton"), for: .normal)
             self.playPauseButton!.setImage( UIImage(named:"PauseButton"), for: .normal)
        } else {
            self.player!.pause()
          //  sender.setImage(UIImage(named:"PlayButton"), for: .normal)
             self.playPauseButton!.setImage(UIImage(named:"PlayButton"), for: .normal)
            self.iscurrentlyPlaying = false
        }
    }*/
    
    
}
