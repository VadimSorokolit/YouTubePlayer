//
//  YouTubeNetworkService.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 28.08.2025.
//
 
import Foundation
import Moya

protocol YouTubeNetworkServiceProtocol {
    /**
     Retrieves channel information for the specified channel identifier
     
     - Parameter channelId: The unique identifier of the channel (Channel Id)
     - Returns: An array of `Channel` objects corresponding to the given identifier
     - Throws: An `Error` if the network request or decoding fails
     */
    func getChannels(by channelId: String) async throws -> [Channel]
    
    /**
     Retrieves playlists for the specified channel.
     
     - Parameters:
     - channelid: The unique identifier of the channel whose playlists should be fetched.
     - max: The maximum number of playlists to return (subject to API limits)
     - Returns: An array of `Playlist` objects associated with the given channel.
     - Throws: An `Error` if the network request or decoding fails
     */
    func getPlaylists(by channelid: String, max: Int) async throws -> [Playlist]
    
    /**
     Retrieves items (videos) contained in a specific playlist.
     
     - Parameters:
     - playlistId: The unique identifier of the playlist to fetch items from
     - max: The maximum number of playlist items to return (subject to API limits)
     - Returns: An array of `PlaylistItem` objects representing the contents of the playlist
     - Throws: An `Error` if the network request or decoding fails
     */
    func getPlaylistItems(playlistId: String, max: Int) async throws -> [PlaylistItem]
    
    /**
     Retrieves detailed information for a specific video by its identifier.
     
     - Parameter videoId: The unique identifier of the video
     - Returns: An array of `Video` objects containing detailed information about the requested video
     - Throws: An `Error` if the network request or decoding fails
     */
    func getVideos(by videoId: String) async throws -> [Video]
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
