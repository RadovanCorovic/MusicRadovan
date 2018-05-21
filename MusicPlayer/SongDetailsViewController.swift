//
//  SongDetailsViewController.swift
//  MusicPlayer
//
//  Created by Radovan Corovic on 5/21/18.
//  Copyright © 2018 Radovan Corovic. All rights reserved.
//

import UIKit

class SongDetailsViewController: UIViewController {

    var songName: String?
    var artistName: String?
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let songname = songName {
            songTitleLabel.text = songname
        }
        
        if let artistname = artistName {
            artistNameLabel.text = artistname
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func showAllArtistButtonTapepd(_ sender: Any) {
    }
    

}
