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


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PlayerViewDelegate,UISearchControllerDelegate, UIScrollViewDelegate {

    @IBOutlet weak var trackListTable:UITableView!
    @IBOutlet weak var miniPlayer:PlayerView!
    var viewOverlay: UIView!
    var songsTableView:SongsTableView!
    var musicDownLoad:MusicDownloader!
    var selected:Bool = false
    var isLandscape:Bool = false
    var selectedIndex:IndexPath?
    var oldIndexPath:IndexPath?
    var musicPlayed:Music?
    var isPlaying:Bool = false
    
    /// Search controller to help us with filtering.
    var searchController: UISearchController!
    var filteredList:[Music]! = []
    var trackSearchBar:UISearchBar!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       // NotificationCenter.default.addObserver(self, selector: #selector(ViewController.CreateSearch), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    
       self.title = "Music Player"
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
            DispatchQueue.main.async {
                self.Overlay(start: false)
            }
            
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
             let itemSong = self.songsTableView.thePlayList?.arrayList?.object(at: indexPath.row)as? Music 
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
        
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        self.miniPlayer.alpha = 1.0
        if let oldIndex = self.selectedIndex{
            self.oldIndexPath = oldIndex
        }
       self.selectedIndex = indexPath
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }

    //MARk: - Play selected track
    func LaunchPlayer(index:IndexPath){
        
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
           self.viewOverlay =  self.songsTableView.AddOverLay(view: self.view)
            self.view.addSubview(self.viewOverlay)
            self.view.bringSubview(toFront: self.viewOverlay)
            self.Overlay(start: true)
        }
        
        DispatchQueue.global(qos: .default).async {
            self.miniPlayer.SetupMiniPlayer()
            self.miniPlayer.delegate = self
        }
        
        //Register Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.setTheTable), name: NSNotification.Name(rawValue: "listOfSongs"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.AlertMsg), name: NSNotification.Name(rawValue: "errorFetching"), object: nil)
        
    }
    
    
    //MARK: Setup SearchController
    func CreateSearch(){
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.sizeToFit()
        self.trackListTable.tableHeaderView = self.searchController.searchBar
        self.searchController.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.delegate = self
        definesPresentationContext = true
        
        self.trackSearchBar = UISearchBar(frame: CGRect(x: 0, y: 65, width: self.miniPlayer.bounds.width , height: 32))
        self.trackSearchBar.autoresizingMask = [.flexibleWidth]
        self.trackSearchBar.showsCancelButton = false
        self.trackSearchBar.delegate = self
        self.miniPlayer.addSubview(trackSearchBar)
        self.trackSearchBar.isHidden = true
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            self.isLandscape = true
            self.miniPlayer.alpha = 1.0
            self.trackSearchBar.isHidden = false
            self.trackListTable.tableHeaderView?.isHidden = true
        }
        
    }
    
    //MARK: Play Track
    @IBAction func PlaySong(_ sender:UIButton){
        
        if !self.isPlaying {
            
            self.isPlaying = true
            self.LaunchPlayer(index: self.selectedIndex!)
            
            var listOfSongs:[Music] = (self.songsTableView.thePlayList?.GetMusicList())!
            if self.filteredList.count > 0{
                listOfSongs = self.filteredList
            }
            
            self.miniPlayer.LoadImage(songIndex: self.selectedIndex!, listSong: listOfSongs)
            
            if let songIndex = self.oldIndexPath{
                self.trackListTable.reloadRows(at: [self.selectedIndex!,songIndex], with: .fade)
            }
            else{
                
                self.trackListTable.reloadRows(at: [self.selectedIndex!], with: .fade)
            }
            
        }
        else
        {
            if let songIndex = self.oldIndexPath{
                self.trackListTable.reloadRows(at: [songIndex], with: .fade)
            }
            self.miniPlayer.playButtonTapped()
            self.isPlaying = false
        }
        
        
        
    }

    
    //MARK: - Setup the table view
    func setTheTable(){
        
        self.songsTableView.SetPlayList(songList:self.musicDownLoad.GetPlayList())
    _ = self.songsTableView.ProcessArray()
        self.trackListTable?.delegate = self
        self.trackListTable?.dataSource = self
        DispatchQueue.main.async {
            self.trackListTable?.reloadData()
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
        self.miniPlayer.alpha = 0.0
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
        self.trackListTable.reloadRows(at: [oldIndex,index], with: .fade)
        
    }
    
    
    
    //MARK: Filtered Content
    func filterContentForSearchText(_ searchText: String) {
        let musicList:[Music] = self.songsTableView.thePlayList?.arrayList! as! [Music]
    
        
        self.filteredList =  musicList.filter {  item in
            return  item.trackName.lowercased().contains(searchText.lowercased()) || (item.artist?.lowercased().contains(searchText.lowercased()))!
        }
        
        
        self.trackListTable.reloadData()
    }

    //MARK: Orientation Changes
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            
            self.trackListTable.tableHeaderView?.isHidden = true
            self.isLandscape = true
            self.trackSearchBar.isHidden = false
            self.miniPlayer.alpha = 1.0
        } else {
            
            self.trackListTable.tableHeaderView?.isHidden = false
            self.trackSearchBar.isHidden = true
            self.isLandscape = false
            self.miniPlayer.alpha = 0.0
            if self.isPlaying{
                self.miniPlayer.alpha = 1.0
            }
            print("Portrait")
        }
    }
    
    
    
    func searchAutocompleteEntriesWithSubstring(_ subString: String){
        
        self.filterContentForSearchText(subString)
        
    }
    
    
    //MARK: - Scroll Delegates
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
         let newList =  self.songsTableView?.ProcessArray()
         AddNewRows(tableView: self.trackListTable!, theList: newList!)
        
    }

    //MARK: - Add New Rows
    func AddNewRows(tableView:UITableView, theList:[Music]){
        
        var i:Int = (self.songsTableView?.lastItem)!
        var indexs:[IndexPath] = [IndexPath]()
        while i < (self.songsTableView?.currentRows)!{
            let newIndex = IndexPath(row: i, section: 0)
            indexs.append(newIndex)
            i += 1
        }
        
        tableView.beginUpdates()
        tableView.insertRows(at: indexs, with: .none )
        tableView.endUpdates()
 
    }

    

}


//MARK: SearchController
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
        self.trackListTable.reloadData()
        if self.isLandscape {
            
           self.searchController.searchBar.isHidden = true
        }
        
    }
}

