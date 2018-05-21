//
//  SongInfo.swift
//  MusicPlayer
//
//  Created by Radovan Corovic on 5/20/18.
//  Copyright © 2018 Radovan Corovic. All rights reserved.
//

import Foundation

struct SongInfo: Decodable {
    let track_title: String
    let artist_name: String
    let artist_id: String
}
