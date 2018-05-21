//
//  SongsTableViewCell.swift
//  MusicPlayer
//
//  Created by Radovan Corovic on 5/20/18.
//  Copyright © 2018 Radovan Corovic. All rights reserved.
//

import UIKit

class SongsTableViewCell: UITableViewCell {

    @IBOutlet weak var songTile: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        
        print("Player se pojavljuje")
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
