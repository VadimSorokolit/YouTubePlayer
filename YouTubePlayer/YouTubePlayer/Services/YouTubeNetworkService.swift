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
    
    // MARK: - Methods. Public
    
    func getChannels(by channelId: String) async throws -> [Channel] {
        let wrapper: ChannelsDataWrapper = try await self.provider.async.request(.getChannels(id: channelId))
        let channels = wrapper.items
        
        return channels
    }
    
    func getPlaylists(by channelid: String, max: Int) async throws -> [Playlist] {
        let wrapper: PlaylistDataWrapper = try await self.provider.async.request(.getPlaylists(channelId: channelid, max: max))
        let playlists = wrapper.items
        
        return playlists
    }
    
    func getPlaylistItems(playlistId: String, max: Int) async throws -> [PlaylistItem] {
        let wrapper: PlaylistItemsDataWrapper = try await self.provider.async.request(.getPlaylistItems(playlistId: playlistId, max: max))
        let playlistItems = wrapper.items
        
        return playlistItems
    }
    
    func getVideos(by videoId: String) async throws -> [Video] {
        let wrapper: VideoDataWrapper = try await self.provider.async.request(.getVideos(videoId: videoId))
        let videos = wrapper.items
        
        return videos
    }
    
}
