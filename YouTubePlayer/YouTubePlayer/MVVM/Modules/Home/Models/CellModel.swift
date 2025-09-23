//
//  CellModel.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 07.09.2025.
//

import Foundation

struct ResourceSection: Identifiable, Equatable {
    let id = UUID()
    let title: String
    var items: [CellModel]
}

struct CellModel: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let type: CellType
    
    enum CellType: Equatable {
        case pageControl(model: [Channel])
        case playlist(model: Playlist)
    }
}
