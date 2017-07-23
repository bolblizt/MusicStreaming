//
//  SongsTableCell.swift
//  MusicPlayer
//
//  Created by Dominic Edwayne Rivera on 20/7/17.
//  Copyright © 2017 Dominic Edwayne Rivera. All rights reserved.
//

import UIKit

class SongsTableCell: UITableViewCell {

    
    @IBOutlet weak var artistImage:UIImageView!
    @IBOutlet weak var artistName:UILabel!
    @IBOutlet weak var artistTrack:UILabel!
    @IBOutlet weak var artistAlbum:UILabel!
    @IBOutlet weak var songImgButton:UIImageView!
    
    private var musicInfo:Music?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setMusicData(theMusic:Music){
        
        self.musicInfo = theMusic
        
    }
    
    func SetLabel(){
        self.artistAlbum.text = self.musicInfo?.albumName
        
        if let albumName = self.musicInfo?.albumName{
            self.artistAlbum.text = albumName
        }
        
        
        if let artistName = self.musicInfo?.artist{
            self.artistName.text = artistName
        }
        
        if let songTitle = self.musicInfo?.trackName{
            self.artistTrack.text = songTitle
        }
        self.songImgButton.isHidden = true
         
    }
    
    
    func getAlbumURL() ->String{
        var urlstr = ""
        
        if let urlImg = self.musicInfo?.albumArtURL{
            
            urlstr = urlImg
        }
        
        return  urlstr
    }
    
    

}
