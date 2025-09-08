//
//  PlaylistDataWrapper.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 05.09.2025.
//

struct PlaylistDataWrapper: Decodable {
    let items: [Playlist]
}

struct Playlist: Decodable, Equatable {
    let id: String
    let snippet: Snippet
    var playlistItems: [PlaylistItem]?
    
    struct Snippet: Decodable, Equatable {
        let title: String
    }
}
