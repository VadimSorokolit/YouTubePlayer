//
//  PlaylistItemsDataWrapper.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 05.09.2025.
//

import Foundation

struct PlaylistItemsDataWrapper: Decodable {
    let items: [PlaylistItem]
}

struct PlaylistItem: Decodable {
    let id: String
    var snippet: Snippet
    
    struct Snippet: Decodable {
        let title: String
        let resourceId: Resource
        var viewCount: String?
        let thumbnails: Thumbnail?
        
        struct Resource: Decodable {
            let videoId: String
        }
        
        struct Thumbnail: Decodable {
            let `default`, medium, high: Info?
            
            struct Info: Decodable {
                let url: String
            }
        }
    }
}

// MARK: - Equatable

extension PlaylistItem: Equatable {
    
    static func == (lhs: PlaylistItem, rhs: PlaylistItem) -> Bool {
        return lhs.id == rhs.id
    }
    
}

extension PlaylistItem {
    
    static var placeholder: PlaylistItem {
        let resourceId = PlaylistItem.Snippet.Resource(videoId: "")
        let snippetThumbInfo = PlaylistItem.Snippet.Thumbnail.Info(url: "")
        let thumbnails = PlaylistItem.Snippet.Thumbnail(default: snippetThumbInfo, medium: snippetThumbInfo, high: snippetThumbInfo)
        let snippet = PlaylistItem.Snippet(title: "", resourceId: resourceId, viewCount: nil, thumbnails: thumbnails)
        return PlaylistItem(id: "", snippet: snippet)
    }
    
}
