//
//  GenreInfo.swift
//  MusicPlayer
//
//  Created by Radovan Corovic on 5/18/18.
//  Copyright © 2018 Radovan Corovic. All rights reserved.
//

import Foundation

struct GenreInfo: Decodable {
    let genre_title: String
    let genre_handle: String
    let genre_parent_id: String?
    let genre_id: String
    let genre_color: String
}
