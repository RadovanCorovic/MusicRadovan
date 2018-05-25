//
//  SongDetailsViewController.swift
//  MusicPlayer
//
//  Created by Radovan Corovic on 5/21/18.
//  Copyright © 2018 Radovan Corovic. All rights reserved.
//

import UIKit

class SongDetailsViewController: UIViewController {

    var artistId = String()
    var songName: String?
    var artistName: String?
    var trackArtwork = String()
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var showAllAlbumsOutlet: UIButton!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchArtwork()
        print(trackArtwork)
        if let songname = songName {
            songTitleLabel.text = songname
        }
        
        if let artistname = artistName {
            artistNameLabel.text = artistname
        }
        customizeButton()
        
    }
    
    func fetchArtwork() {

        artworkImageView.layer.masksToBounds = true
        artworkImageView.layer.cornerRadius = artworkImageView.frame.width / 2
        artworkImageView.layer.borderWidth = 2
        artworkImageView.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
        if let url = URL(string: "") {
            do {
                let data = try Data(contentsOf: url)
                self.artworkImageView.image = UIImage(data: data)
            } catch let error {
                print("Error \(error.localizedDescription)")
            }
        } else {
            self.artworkImageView.image = UIImage(named:"defaultArtwork")
            self.artworkImageView.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 0).cgColor
        }
        
        
    }
    
    func customizeButton() {
        showAllAlbumsOutlet.layer.cornerRadius = 10
    }

    @IBAction func showAllArtistButtonTapepd(_ sender: Any) {
        performSegue(withIdentifier: "showAlbums", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAlbums" {
            let destinationVC = segue.destination as! ArtistAlbumsViewController
            
            destinationVC.artistID = artistId
            
        }
    }

}
