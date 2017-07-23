//
//  Music.swift
//  MusicPlayer
//
//  Created by Dominic Edwayne Rivera on 1/7/17.
//  Copyright © 2017 Dominic Edwayne Rivera. All rights reserved.
//

import Foundation
import Alamofire


//MUSIC
struct Music{
    
    var trackName:String
    var artist:String?
    var albumName:String?
    var currentSong:Bool
    var durationInMilis:CLongLong
    var previewSongURL:String
    var albumArtURL:String
    
    
    
    
    init(Init trackName:String, artistName:String, albumName:String, durationMilis:CLongLong, previewSongURL:String, albumArt:String){
        
        self.trackName = trackName
        self.artist = artistName
        self.albumName = albumName
        self.currentSong = false
        self.durationInMilis = durationMilis
        self.previewSongURL = previewSongURL
        self.albumArtURL = albumArt
     
        
    }
    
    
    init() {
        
        self.trackName = ""
        self.artist = ""
        self.albumName = ""
        self.currentSong = false
        self.durationInMilis = 0
        self.previewSongURL = ""
        self.albumArtURL = ""

        
    }
    
    
    
    
}


//PlayList
struct  PlayList {
    
   private  var songList:NSArray?
    var musicList:[Music]?
    var arrayList:NSMutableArray?
   private var currentTotalRow:Int = 0
    
    init( list:[Music] ) {
        self.songList = NSArray(array: list)
        self.musicList = list
    
        
        
    }
    
    func GetFullList()->NSArray{
        return self.songList!
    }
    
    func GetMusicList()->[Music]{
     return self.musicList!
    }
    
    mutating func SetCurrentRows(rowsTotal:Int){
        self.currentTotalRow = rowsTotal
    }
    
    func GetCurrentRows()->Int{
       return self.currentTotalRow
    }
    
    func AddNewItems(trackList:[Music]){
        
       
        
    }
    
}


//MusicDownloader
class MusicDownloader:NSObject{
    
    
    private var urlStr:String?
    private var urlMUsic:URL?
    private var playListSong:PlayList?
    
    
    init(urlString:String) {
        
        self.urlStr = urlString
        self.urlMUsic = URL(string: self.urlStr!)
    }
    
    func GetPlayList() -> PlayList{
        return self.playListSong!
    }
    
    func downloadMusic(){
        
        var musicList:[Music]?
       
        
        let queueUtility = DispatchQueue.global(qos: .utility)
        Alamofire.request(self.urlMUsic!).responseJSON(queue:queueUtility ) { (response) in
            
            guard response.result.isSuccess else {
                print("Error while fetching tags: \(String(describing: response.result.error))")
                //POST
                let nc = NotificationCenter.default
                 nc.post(name: Notification.Name(rawValue: "errorFetching"), object: nil)
                return
            }
            
            guard let responseJSON = response.result.value as? [String: Any] else {
                
                print("Invalid tag information received from the service")
                return
            }
            
            print(responseJSON.count)
            
            if let jValues =  responseJSON["results"] as? [[String: Any]] {
                var artistMusic:Music?
                musicList = [Music]()
                for songInfoList in jValues{
                    
                   // print(songInfoList)
                    artistMusic = Music()
                   	for (key, value) in songInfoList {
                        // access all key / value pairs in dictionary
                        
                        if key ==  "artistName"{
                            artistMusic?.artist = value as? String
                            
                        }
                        else if key == "trackName"{
                            
                             artistMusic?.trackName = value as! String
                        }
                        else if key == "trackTimeMillis"{
                            artistMusic?.durationInMilis = value as! CLongLong
                        }
                        else if key == "collectionCensoredName"{
                            artistMusic?.albumName = value as? String
                            
                        }
                        else if key == "previewUrl"{
                            
                            artistMusic?.previewSongURL = value as! String
                        }
                        else if key == "artworkUrl100"{
                            
                            artistMusic?.albumArtURL = value as! String
                        }
                        
                    }
                    
                    musicList?.append(artistMusic!)
                    
                }
                
                if (musicList?.count)! > 0 {
                    
                    self.playListSong = PlayList(list: musicList!)
                    
                    
                }
                
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name(rawValue: "listOfSongs"), object: nil)
                
                print("songs: \(String(describing: musicList?.count))")
                
            }
          
            
        }


    
    }
    
    
}
