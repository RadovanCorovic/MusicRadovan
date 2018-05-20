//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Radovan Corovic on 5/18/18.
//  Copyright © 2018 Radovan Corovic. All rights reserved.
//

import UIKit

struct WebsiteDescription: Decodable {
    let title: String
    let total_pages: Int
    let page: String
    let dataset: [GenreInfo]
}

struct SongDescription: Decodable {
    let dataset: [SongInfo]
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableview: UITableView!
    var limit = 30
    var page = 1
    var totalPages = 0
    var dataset = [GenreInfo]()
    var songDataset = [SongInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.tableFooterView = UIView(frame: .zero)
        
        fetchData()
    }
    func fetchData() {
        var url = URLComponents(string: "https://freemusicarchive.org/api/get/genres.json")!
        url.queryItems = [
            URLQueryItem(name: "api_key", value: "CFEFES9JPKBN4T7H"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        URLSession.shared.dataTask(with: url.url!) { (data, response, error) in

            guard let data = data else {return}

            guard let websiteDescription = try? JSONDecoder().decode(WebsiteDescription.self, from: data) else {
                print("Error: Couldn't decode data into dataset")
                return
            }

            self.dataset.append(contentsOf: websiteDescription.dataset)
            self.totalPages = websiteDescription.total_pages
            
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
            
            }.resume()
    }
    
    // Tableview datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataset.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! GenreTableViewCell
        
        let data = dataset[indexPath.row]
        let songData = songDataset[indexPath.row]
        
        cell.genreName.text = data.genre_title
        cell.genreColor.backgroundColor = UIColor(hexString: data.genre_color)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let data = dataset[indexPath.row]
        let genreID = data.genre_id
        
        var url = URLComponents(string: "https://freemusicarchive.org/api/get/tracks.json?")!
        url.queryItems = [
            URLQueryItem(name: "api_key", value: "CFEFES9JPKBN4T7H"),
            URLQueryItem(name: "genre_id", value: "\(genreID)")
            
        ]
        
        URLSession.shared.dataTask(with: url.url!) { (data, response, error) in
            
            guard let data = data else {return}
            
            guard let songDescription = try? JSONDecoder().decode(SongDescription.self, from: data) else {
                print("Error: Couldn't decode data into dataset")
                return
            }
            print(SongDescription.self)
            self.songDataset.append(contentsOf: songDescription.dataset)
            
            }.resume()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if(indexPath.row == dataset.count - 1){
            // Last row
            if(totalPages > page){
                // It there is no more pages
                page += 1
                
                print("Fetching page: \(page) of total pages: \(totalPages)")
                fetchData()
            }
            
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

