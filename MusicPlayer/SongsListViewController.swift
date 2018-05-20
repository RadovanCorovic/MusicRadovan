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
    var genreeID = String()
    var songDataset = [SongInfo]()
    @IBOutlet weak var tableview: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        tableview.reloadData()
        tableview.delegate = self
        tableview.dataSource = self

        fetchSongs()
    }
    
    func fetchSongs() {
        var url = URLComponents(string: "https://freemusicarchive.org/api/get/tracks.json?")!
        url.queryItems = [
            URLQueryItem(name: "api_key", value: "CFEFES9JPKBN4T7H"),
            URLQueryItem(name: "page", value: "\(genreeID)")
        ]
        
        URLSession.shared.dataTask(with: url.url!) { (data, response, error) in
            
            guard let data = data else {return}
            
            guard let songDescription = try? JSONDecoder().decode(SongDescription.self, from: data) else {
                print("Error: Couldn't decode data into dataset")
                return
            }
            
            self.songDataset.append(contentsOf: songDescription.dataset)
            
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
            
            }.resume()
    }
    


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songDataset.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell") as! SongsTableViewCell
        let song = songDataset[indexPath.row]
        cell.songTile.text = song.track_title
        cell.songArtist.text = song.artist_name

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
