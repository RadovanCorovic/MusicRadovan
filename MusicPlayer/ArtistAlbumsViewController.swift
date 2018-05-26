//
//  ArtistAlbumsViewController.swift
//  MusicPlayer
//
//  Created by Radovan Corovic on 5/21/18.
//  Copyright © 2018 Radovan Corovic. All rights reserved.
//

import UIKit

struct AlbumDescription: Decodable {
    let dataset: [AlbumInfo]
    let total_pages: Int
    let page: String
}

class ArtistAlbumsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var urlAdress = String()
    var artistID = String()
    var albumDataset = [AlbumInfo]()
    var limit = 20
    var page = 1
    var totalPages = 0
    
    @IBOutlet weak var tableview: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchAlbums()
    }
    
    func fetchAlbums() {
        
        var url = URLComponents(string: "https://freemusicarchive.org/api/get/albums.json")!
        url.queryItems = [
            URLQueryItem(name: "api_key", value: "CFEFES9JPKBN4T7H"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "artist_id", value: "\(artistID)")
        ]
        
        URLSession.shared.dataTask(with: url.url!) { (data, response, error) in
            
            guard let data = data else {return}
            
            guard let albumDescription = try? JSONDecoder().decode(AlbumDescription.self, from: data) else {
                print("Error: Couldn't decode data into dataset")
                return
            }
            self.albumDataset.append(contentsOf: albumDescription.dataset)
            self.totalPages = albumDescription.total_pages
            
            
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
            
            }.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumDataset.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        
        let data = albumDataset[indexPath.row]
        urlAdress = data.album_url
        cell.textLabel?.text = data.album_title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = albumDataset[indexPath.row]
        urlAdress = data.album_url
        performSegue(withIdentifier: "showWeb", sender: self)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row == albumDataset.count - 1) {
            // Last row
            if(totalPages > page) {
                page += 1
                
                print("Fetching page \(page) of total pages \(totalPages)")
                fetchAlbums()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWeb" {
            if let indexPathForSelectedRow = tableview.indexPathForSelectedRow {
            let destinationVC = segue.destination as! WebViewController
            
            destinationVC.webAdress = urlAdress
            self.tableview.deselectRow(at: indexPathForSelectedRow, animated: false)
            print(urlAdress)
            }
        }
    }


}
