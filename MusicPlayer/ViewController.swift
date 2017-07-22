//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Dominic Edwayne Rivera on 1/7/17.
//  Copyright © 2017 Dominic Edwayne Rivera. All rights reserved.
//

import UIKit
import MediaPlayer
import StoreKit
import Alamofire


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var songTableView:UITableView!
    @IBOutlet weak var miniPlayer:PlayerView!
   
   
    @IBOutlet weak var playPauseButtonLandscape: UIButton!
    @IBOutlet weak var timeSliderLandscape: UISlider!
    @IBOutlet weak var sidePlayer:UIView!
    var viewOverlay: UIView!
    var songsTableView:SongsTableView!
    var musicDownLoad:MusicDownloader!
    var selected:Bool = false
    var selectedIndex:IndexPath?
    
       

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
     
        self.PrepOperation()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: - Tableviews
    
    //sections
    func numberOfSections(in tableView: UITableView) -> Int {
        let section:Int =  self.songsTableView.GetSection()
        return section
    }
    
    //rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows:Int =  self.songsTableView.GetRows()
            print(rows)
        return rows
    }
    
    //set table cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rows:Int =  self.songsTableView.GetRows()
        
        if (indexPath.row < rows) {
            print("dismiss")
            self.Overlay(start: false)
        }
        
        self.selected = false
        if self.selectedIndex?.row == indexPath.row{
            self.selected = true
        }
        
        
        let cell:UITableViewCell = self.songsTableView.GetTableViewCell(index: indexPath, tableView: tableView, selectedSong: self.selected)
       
        return cell
    }
    
    //row height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let rowHeight:CGFloat = 80.0
        return rowHeight
    }
    
    
    //select
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        ///Music Player
        //let theMusic = self.songsTableView.GetSong(index: indexPath)
        self.miniPlayer.alpha = 1.0
        self.miniPlayer.setPlayer(index: indexPath, playList: self.songsTableView.thePlayList!)
   //   self.miniPlayer.timeSlider.value = 0.0
    //    self.miniPlayer.timeSlider.maximumValue = Float(theMusic.durationInMilis)
       
        if let songIndex = self.selectedIndex{
            self.selectedIndex = indexPath
            self.songTableView.reloadRows(at: [indexPath,songIndex], with: .fade)
            
            
        }
        else{
             self.selectedIndex = indexPath
             self.songTableView.reloadRows(at: [indexPath], with: .fade)
        }
        
       
        

      
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      //  if indexPath.row == airportViewModel?.tempoList?.count{
            
        //}
        
    }

    
    //MARK: - Get Music and Setup the UI
    func PrepOperation(){
        
        self.musicDownLoad = MusicDownloader(urlString: "https://itunes.apple.com/search?term=beatles&entity=song&limit=50")
        self.musicDownLoad.downloadMusic()

        self.songsTableView = SongsTableView()
        
        
        DispatchQueue.main.async {
            self.viewOverlay =  self.songsTableView.AddOverLay(view: self.view)
            self.view.addSubview(self.viewOverlay)
            self.view.bringSubview(toFront: self.viewOverlay)
            self.Overlay(start: true)
            self.miniPlayer.alpha = 0.0
            self.miniPlayer.SetupMiniPlayer()
            
        }
        
        
        //
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.setTheTable), name: NSNotification.Name(rawValue: "listOfSongs"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.AlertMsg), name: NSNotification.Name(rawValue: "errorFetching"), object: nil)
        
      //  _ =  self.setupData(dataLoader: dataLoader!)
        
        
        
    }
    
    //MARK: - Setup the table view
    func setTheTable(){
        
        self.songsTableView.SetPlayList(songList:self.musicDownLoad.GetPlayList())
        self.songTableView?.delegate = self
        self.songTableView?.dataSource = self
        DispatchQueue.main.async {
            self.songTableView?.reloadData()
        }
        
    }

    
    
    //MARK: - Overlay View when data is fetch
    func Overlay(start:Bool){
        
        if start {
            UIView.animate(withDuration: 2.5, delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
                
                self.viewOverlay!.alpha = 0.8
                
            }, completion: { (finished: Bool) -> Void in
                
                // you can do this in a shorter, more concise way by setting the value to its opposite, NOT value
            })
        }
        else
        {
            UIView.animate(withDuration: 2.5, delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
                
                self.viewOverlay!.alpha = 0.0
                
            }, completion: { (finished: Bool) -> Void in
                
                // you can do this in a shorter, more concise way by setting the value to its opposite, NOT value
            })
        }
    }


    //MARK: - Alert Messages
    func AlertMsg(){
        
        let alertView = UIAlertController(title: "Music Player", message: "Please check your internet connection", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
            self.Overlay(start: false)
        }
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
        
    }
    

}

