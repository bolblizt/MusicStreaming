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


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PlayerViewDelegate, SidePlayerDelegate,UISearchControllerDelegate {

   
    
    
    @IBOutlet weak var songTableView:UITableView!
    @IBOutlet weak var miniPlayer:PlayerView!
    @IBOutlet weak var sidePlayer:SidePlayerView!
    var viewOverlay: UIView!
    var songsTableView:SongsTableView!
    var musicDownLoad:MusicDownloader!
    var selected:Bool = false
    var isLandscape:Bool = false
    var selectedIndex:IndexPath?
    var musicPlayed:Music?
    
    /// Search controller to help us with filtering.
    var searchController: UISearchController!
    var filteredList:[Music]! = []
    
    
    
    //MARK: Setup SearchController
    func CreateSearch(){
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.sizeToFit()
        self.songTableView.tableHeaderView = self.searchController.searchBar
        self.searchController.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.delegate = self
        definesPresentationContext = true
        
        let trackSearchBar = UISearchBar(frame: CGRect(x: 10, y: 65, width: self.sidePlayer.frame.width-20, height: 32))
        trackSearchBar.showsCancelButton = false
        trackSearchBar.delegate = self
        self.sidePlayer.addSubview(trackSearchBar)

    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       // NotificationCenter.default.addObserver(self, selector: #selector(ViewController.CreateSearch), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    
       
        self.CreateSearch()
        self.PrepOperation()

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: - Tableviews
    
    //sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // if searchController.isActive && searchController.searchBar.text != "" {
        
         if self.searchController.isActive || self.filteredList.count > 0{
            if self.filteredList.count > 0{
                return self.filteredList.count
            }
        }
        
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
        let cell:UITableViewCell!
        self.selected = false
        if self.selectedIndex?.row == indexPath.row{
            self.selected = true
        }
        
        if self.filteredList.count > 0 {
            cell = self.songsTableView.GetTableViewCell(index: indexPath, tableView: tableView, selectedSong: self.selected, filteredResults: self.filteredList)
             self.selectedIndex = nil
            
        }
        else
        {
             let itemSong = self.songsTableView.thePlayList?.songList?.object(at: indexPath.row) as? Music
            if let trackSong =  self.musicPlayed?.trackName{
                if trackSong == itemSong?.trackName{
                    self.selected = true
                    self.selectedIndex = indexPath
                    self.musicPlayed = nil
                }
            }
            cell = self.songsTableView.GetTableViewCell(index: indexPath, tableView: tableView, selectedSong: self.selected)
        }
        
       
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
        self.LaunchPlayer(index: indexPath)
       
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

    //MARk: - Play selected track
    func LaunchPlayer(index:IndexPath){
        self.miniPlayer.alpha = 1.0
        if self.filteredList.count > 0 {
            
            self.miniPlayer.SetPlayerResult(index: index, filtered: self.filteredList)
            self.musicPlayed = self.filteredList[index.row]
            
        }
        else
        {
            
            self.miniPlayer.SetPlayer(index: index, playList: self.songsTableView.thePlayList!)
        }
    }
    
    //MARK: - Get Music and Setup the UI
    func PrepOperation(){
        
        self.musicDownLoad = MusicDownloader(urlString: "https://itunes.apple.com/search?term=beatles&entity=song&limit=50")
        self.musicDownLoad.downloadMusic()

        self.songsTableView = SongsTableView()
        
        
        DispatchQueue.main.async {
           //self.viewOverlay =  self.songsTableView.AddOverLay(view: self.view)
           // self.view.addSubview(self.viewOverlay)
            //self.view.bringSubview(toFront: self.viewOverlay)
            //self.Overlay(start: true)
            self.miniPlayer.alpha = 0.0
            self.miniPlayer.SetupMiniPlayer()
            self.miniPlayer.delegate = self
            self.sidePlayer.delegate = self
            
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
                
             //   self.viewOverlay!.alpha = 0.0
                
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
    
    
    //MARK:PlayerView Delegate
    func UpdateTableView(index:IndexPath, oldIndex:IndexPath){
        self.selectedIndex = index
        self.songTableView.reloadRows(at: [oldIndex,index], with: .fade)
        
    }
    
    
    
    //MARK: Filtered Content
    func filterContentForSearchText(_ searchText: String) {
        let musicList:[Music] = (self.songsTableView.thePlayList?.GetMusicList())!
        self.filteredList =  musicList.filter {  item in
            return  item.trackName.lowercased().contains(searchText.lowercased()) || (item.artist?.lowercased().contains(searchText.lowercased()))!
        }
        
        
        self.songTableView.reloadData()
    }

    //MARK: Orientation Changes
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            
            self.songTableView.tableHeaderView?.isHidden = true
            //self.searchController = nil
           // self.CreateSearch()
            self.isLandscape = true
        } else {
            
            self.songTableView.tableHeaderView?.isHidden = false
            //self.searchController = nil
            //self.CreateSearch()
            self.isLandscape = false
            print("Portrait")
        }
    }
    
    
    func searchAutocompleteEntriesWithSubstring(_ subString: String){
        
        self.filterContentForSearchText(subString)
        
    }
    
    

}


extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
       
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    
}

//MARK: SearchBarDelegate
extension ViewController: UISearchBarDelegate{
    
  
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
       
       
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
      
        
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var txtAfterUpdate:NSString = searchBar.text! as NSString
        txtAfterUpdate = txtAfterUpdate.replacingCharacters(in: range, with: text) as NSString
        searchAutocompleteEntriesWithSubstring(txtAfterUpdate as String)
        
        
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.showsCancelButton = false
        searchBar.text = nil
        searchBar.resignFirstResponder()
       self.filteredList.removeAll()
        self.songTableView.reloadData()
        
    }
}

