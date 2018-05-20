//
//  GenreTableViewCell.swift
//  MusicPlayer
//
//  Created by Radovan Corovic on 5/18/18.
//  Copyright © 2018 Radovan Corovic. All rights reserved.
//

import UIKit

class GenreTableViewCell: UITableViewCell {

    @IBOutlet var genreName: UILabel!
 
    @IBOutlet weak var genreColor: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
