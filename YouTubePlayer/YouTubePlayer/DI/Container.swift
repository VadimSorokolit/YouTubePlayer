//
//  Container.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 28.08.2025.
//

import Moya
import YouTubePlayerKit
import Factory

extension Container {
    
    var youTubeProvider: Factory<MoyaProvider<YouTubeRouter>> {
        self { MoyaProvider<YouTubeRouter>() }
    }
    
    var youTubeNetworkService: Factory<YouTubeNetworkService> {
        self { YouTubeNetworkService(provider: self.youTubeProvider()) }
    }
    
    var youTubePlayer: Factory<YouTubePlayer> {
        self { YouTubePlayer() }
            .scope(.shared)
    }
    
}
