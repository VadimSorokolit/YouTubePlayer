//
//  MockNetworkService.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 19.09.2025.
//
    
import Foundation
@testable import YouTubePlayer

final class MockNetworkService: YouTubeNetworkServiceProtocol {
    
    // MARK: - Properties. Public
    
    var channelsResult: Result<[Channel], Error> = .success([])
    var playlistsResult: Result<[Playlist], Error> = .success([])
    var playlistItemsResult: Result<[PlaylistItem], Error> = .success([])
    var videosResult: Result<[Video], Error> = .success([])
    
    // MARK: - Methods. Public
    
    func getChannels(by id: String) async throws -> [Channel] {
        try channelsResult.get()
    }
    
    func getPlaylists(by channelid: String, max: Int) async throws -> [Playlist] {
        try playlistsResult.get()
    }
    
    func getPlaylistItems(playlistId: String, max: Int) async throws -> [PlaylistItem] {
        try playlistItemsResult.get()
    }
    
    func getVideos(by videoId: String) async throws -> [Video] {
        try videosResult.get()
    }
    
}
