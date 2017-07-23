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
    
    var currentRows = 0
    var songSections = 1
    var songTableSearchBar:UISearchBar?
    var tableView:UITableView!
    var overLay:UIView?
    var remainingRows:Int = 0
    var totalRows:Int = 0
      var thePlayList:PlayList?
    var tableCell:SongsTableCell!
    var lastItem:Int = 0
    
    
    
    
    
    override init() {
        
    }
    
    
     init(songList:PlayList) {
        self.thePlayList = songList
    }
    
    
    func AddRows()->Int{
        remainingRows = totalRows
        
        return remainingRows
    }
    
    //MARK: Get Selected Song
    func GetSong(index:IndexPath)->Music{
        
        let musicData = self.thePlayList?.musicList?[index.row]
        return musicData!
    }

    
    
    
    //MARK: set the playlist
    func SetPlayList(songList:PlayList){
        
        self.thePlayList = songList
      //  let rowsCount:Int = (self.thePlayList?.musicList?.count)!
        self.totalRows = (self.thePlayList?.GetFullList().count)!
        self.SetSection(section: 1)
        
        
    }
    
    //MARK: Number of rows
    func GetRows()->Int{
        if currentRows == 0{
            currentRows = 25
        }
        
        return currentRows
    }
    
    func SetRows(rows:Int){
        self.totalRows = rows
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
        let musicData = self.thePlayList?.arrayList?.object(at:index.row) as? Music
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
           
        }
        
        
        return overLay!
    }

     //MARK: Get Songs Information
    
    func GetSongName(indexPath:IndexPath)-> String{
        
        let songName = self.thePlayList?.arrayList?.object(at: indexPath.row) as? Music
        guard let name = songName?.trackName else {
            
            return ""
        }
        
        
        return name
    }

    func GetAlbumName(indexPath:IndexPath)-> String{
        
        let songName = self.thePlayList?.arrayList?.object(at: indexPath.row) as? Music
        guard let name = songName?.albumName else {
            
            return ""
        }
        
        
        return name
    }
    
    //MARK: Adding new rows methods
    func SubArray() -> [Music]{
        var tempArray:[Music]?
        var tempTotal = 0
        var len = 0
        
        if self.currentRows < self.totalRows{
            if self.currentRows == 0{
                len = 25
            }
            else{
                len = 5
            }
            
            tempArray = self.thePlayList?.GetFullList().subarray(with: NSMakeRange(currentRows, len)) as! [Music]?
            self.lastItem = currentRows
            self.currentRows += len
        }
        else
        {
            tempTotal =  self.totalRows - self.currentRows
            len = tempTotal
            tempArray = self.thePlayList?.GetFullList().subarray(with: NSMakeRange(self.currentRows, len)) as! [Music]?
            self.lastItem = self.currentRows
            self.currentRows += len
            
        }
        
        
        return tempArray!
    }
    
    func AddNewItems(ListOfSongs:[Music]){
        
        if self.thePlayList?.arrayList == nil{
            self.thePlayList?.arrayList = NSMutableArray()
        }
       
        self.thePlayList?.arrayList?.addObjects(from: ListOfSongs)
        
        
    }
    
    
    func ProcessArray()->[Music]{
        let myList = SubArray()
        AddNewItems(ListOfSongs: myList)
        
        return myList
    }

}
