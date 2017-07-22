//
//  SongsTableView.swift
//  MusicPlayer
//
//  Created by Dominic Edwayne Rivera on 19/7/17.
//  Copyright © 2017 Dominic Edwayne Rivera. All rights reserved.
//

import UIKit

class SongsTableView: NSObject {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var songsRows = 0
    var songSections = 1
    var songTableSearchBar:UISearchBar?
    var tableView:UITableView!
    var overLay:UIView?
    var remainingRows:Int = 0
    var rows:Int = 0
      var thePlayList:PlayList?
    var tableCell:SongsTableCell!
    
    
    
    
    override init() {
        
    }
    
    
     init(songList:PlayList) {
        self.thePlayList = songList
    }
    
    
    func AddRows()->Int{
        remainingRows = rows
        
        return remainingRows
    }
    
    //MARK: Get Selected Song
    func GetSong(index:IndexPath)->Music{
        
        let musicData = self.thePlayList?.songList?.object(at: index.row) as? Music
        
        return musicData!
    }

    
    
    
    //MARK: set the playlist
    func SetPlayList(songList:PlayList){
        
        self.thePlayList = songList
        let rowsCount:Int = (self.thePlayList?.songList?.count)!
        self.SetRows(rows: rowsCount)
        self.SetSection(section: 1)
        
        
    }
    
    //MARK: Number of rows
    func GetRows()->Int{
        return songsRows
    }
    
    func SetRows(rows:Int){
        self.songsRows = rows
    }
    
    
    
    //MARK: Number of sections
    func GetSection()->Int{
        return songSections
        
    }
    
    func SetSection(section:Int){
        self.songSections = section
    }

    
    //MARK: Set TableView Cell
    func GetTableViewCell(index:IndexPath, tableView:UITableView, selectedSong:Bool)->UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: index) as! SongsTableCell
        let musicData = self.thePlayList?.songList?.object(at: index.row) as? Music
        cell.setMusicData(theMusic: musicData!)
        cell.SetLabel()
        
        cell.songImgButton.isHidden = true
        if selectedSong{
            cell.songImgButton.isHidden = false
        }
        
        
        return cell

    }
    //MARK:Set TableView Cell Search Results
    func GetTableViewCell(index:IndexPath, tableView:UITableView, selectedSong:Bool, filteredResults:[Music])->UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: index) as! SongsTableCell
        let musicData =  filteredResults[index.row]
        cell.setMusicData(theMusic: musicData)
        cell.SetLabel()
        
        cell.songImgButton.isHidden = true
        if selectedSong{
            cell.songImgButton.isHidden = false
        }
        
        
        return cell
        
    }
    
    
    
    //MARK: Overlay View
    func AddOverLay(view:UIView)->UIView{
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        
        let rect = UIScreen.main.bounds
        var indicator:UIActivityIndicatorView!
        
        if self.overLay == nil{
            self.overLay = UIView(frame: rect)
            self.overLay!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.overLay!.backgroundColor = UIColor.white
            indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            indicator.color = UIColor.darkGray
            indicator.frame = CGRect(x: (rect.size.width-50)/2, y: (rect.size.height-50)/2, width: 50, height: 50)
            indicator.hidesWhenStopped = true
            indicator.startAnimating()
            self.overLay?.addSubview(blurEffectView)
            self.overLay!.alpha = 0.8
            self.overLay!.addSubview(indicator)
            //self.view.addSubview(self.overLay!)
            //self.view.bringSubview(toFront: self.overLay!)
        }
        
        
        return overLay!
    }

     //MARK: Get Songs Information
    
    func GetSongName(indexPath:IndexPath)-> String{
        
        let songName = self.thePlayList?.songList?.object(at: indexPath.row) as? Music
        
        guard let name = songName?.trackName else {
            
            return ""
        }
        
        
        return name
    }

    func GetAlbumName(indexPath:IndexPath)-> String{
        
        let songName = self.thePlayList?.songList?.object(at: indexPath.row) as? Music
        
        guard let name = songName?.albumName else {
            
            return ""
        }
        
        
        return name
    }
    
    
    
    

}
