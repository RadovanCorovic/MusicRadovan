//
//  SongsListViewController.swift
//  MusicPlayer
//
//  Created by Radovan Corovic on 5/20/18.
//  Copyright © 2018 Radovan Corovic. All rights reserved.
//

import UIKit

class SongsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var artistID = String()
    var genreeID = String()
    var songDataset = [SongInfo]()
    var limit = 10
    var page = 1
    var totalPages = 0
    
    @IBOutlet weak var tableview: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        tableview.reloadData()
        tableview.delegate = self
        tableview.dataSource = self

        fetchSongs()
    }
    
    func fetchSongs() {
        var url = URLComponents(string: "https://freemusicarchive.org/api/get/tracks.json")!
        url.queryItems = [
            URLQueryItem(name: "api_key", value: "CFEFES9JPKBN4T7H"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "genre_id", value: genreeID)

        ]
        
        URLSession.shared.dataTask(with: url.url!) { (data, response, error) in
            
            guard let data = data else {return}
//            let dataString = String(data: data, encoding: .utf8)
            
            guard let songDescription = try? JSONDecoder().decode(SongDescription.self, from: data) else {
                print("Error: Couldn't decode data into dataset")
                return
            }
            
            self.songDataset.append(contentsOf: songDescription.dataset)
            self.totalPages = songDescription.total_pages

            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = songDataset[indexPath.row]
        artistID = data.artist_id
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if(indexPath.row == songDataset.count - 1){
            // Last row
            if(totalPages > page){
                // It there is no more pages
                page += 1
                
                print("Fetching page: \(page) of total pages: \(totalPages)")
                fetchSongs()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSongDetails" {
            if let selectedRowForIndexPath = tableview.indexPathForSelectedRow {
                
                let songDetils: SongInfo
                
                songDetils = songDataset[selectedRowForIndexPath.row]
                
                let destinationVC = segue.destination as? SongDetailsViewController
                
                destinationVC?.songName = songDetils.track_title
                destinationVC?.artistName = songDetils.artist_name
                destinationVC?.artistId = songDetils.artist_id
            }
        }
    }
}
