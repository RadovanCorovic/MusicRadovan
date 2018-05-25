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
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var showAllAlbumsOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let songname = songName {
            songTitleLabel.text = songname
        }
        
        if let artistname = artistName {
            artistNameLabel.text = artistname
        }
        customizeButton()
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
