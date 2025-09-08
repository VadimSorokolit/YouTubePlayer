//
//  VideoDataWrapper.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 05.09.2025.
//

import Foundation

struct VideoDataWrapper: Decodable {
    let items: [Video]
}

struct Video: Decodable {
    let statistics: Statistics
    
    struct Statistics: Decodable {
        let viewCount: String
    }
}
