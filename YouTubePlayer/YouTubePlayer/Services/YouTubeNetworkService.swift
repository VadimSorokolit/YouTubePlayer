//
//  YouTubeNetworkService.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 28.08.2025.
//
 
import Foundation
import Moya

protocol YouTubeNetworkServiceProtocol {
    func getChannels(by id: String) async throws -> [Channel]
}

class YouTubeNetworkService: YouTubeNetworkServiceProtocol {
    
    
    // MARK: - Properties. Private
    
    private let provider: MoyaProvider<YouTubeRouter>
    
    // MARK: - Initializer
    
    init(provider: MoyaProvider<YouTubeRouter>) {
        self.provider = provider
    }
    
    // MARK: - Methods
    
    func getChannels(by id: String) async throws -> [Channel] {
        let wrapper: ChannelsDataWrapper = try await provider.async.request(.getChannels(id: id))
        let channels = wrapper.items
        return channels
    }
}
