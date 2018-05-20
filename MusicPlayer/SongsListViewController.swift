//
//  SongsListViewController.swift
//  MusicPlayer
//
//  Created by Radovan Corovic on 5/20/18.
//  Copyright © 2018 Radovan Corovic. All rights reserved.
//

import UIKit

class SongsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var songsArray = [SongInfo]()
    
    @IBOutlet weak var tableview: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        tableview.reloadData()
        tableview.delegate = self
        tableview.dataSource = self

        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell") as! SongsTableViewCell
        let songs = songsArray[indexPath.row]

        cell.songTile.text = songs.track_title
        cell.songArtist.text = songs.artist_name

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
