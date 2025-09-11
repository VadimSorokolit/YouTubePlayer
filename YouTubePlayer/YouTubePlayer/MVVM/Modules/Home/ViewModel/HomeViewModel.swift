//
//  HomeViewModel.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 28.08.2025.
//

import Foundation
import Factory

@Observable
class HomeViewModel {
    
    // MARK: - Properties. Public
    
    var isPlayerOpen: Bool = false
    var selectedChannel: Channel?
    var currentPlaylistItems: [PlaylistItem] = []
    var currentTrackIndex: Int = 1
    var channels: [Channel] = []
    var errorMessage: String?
    var pagesCounter: Int = 0
    private(set) var sections: [ResourceSection] = []
    var isLoading: Bool = false
    var currentItem: PlaylistItem? {
        guard self.currentPlaylistItems.indices.contains(self.currentTrackIndex) else {
            return nil
        }
        return self.currentPlaylistItems[currentTrackIndex]
    }
    
    // MARK: - Properties. Private
    
    private let channelsIDs: [String] = [
        L10n.channelId1,
        L10n.channelId2,
        L10n.channelId3,
        L10n.channelId4,
    ]
    private var timerTask: Task<Void, Never>?
    
    @ObservationIgnored
    @Injected(\.youTubeNetworkService) private var service
    
    // MARK: - Methods. Public
    
    func startTimer() {
        self.stopTimer()
        self.timerTask = Task {
            do {
                for try await _ in AsyncThrowingStream.every(seconds: 5.0) {
                    if self.isPlayerOpen == false {
                        pagesCounter += 1
                    }
                }
            }
            catch {}
        }
    }
    
    func stopTimer() {
        self.timerTask?.cancel()
        self.timerTask = nil
    }
    
    
    func getSectionTitle(by sectionIndex: Int) -> String {
        guard self.sections.indices.contains(sectionIndex) else {
            return ""
        }
        return self.sections[sectionIndex].title
    }
    
    func updateData(for channelIndex: Int) {
        self.sections = self.createSections(for: channelIndex)
    }
    
    func getChannels() async throws {
        self.isLoading = true
        defer { self.isLoading = false }
        
        do {
            var loadedChannels: [Channel] = []
            
            for id in self.channelsIDs {
                guard let channels = await self.getChannels(by: id), channels.isEmpty == false else { continue }
                
                let playlists = try await self.getPlaylists(by: id, max: 2)
                var updatedPlaylists: [Playlist] = []
                
                for var playlist in playlists {
                    let items = try await self.getPlaylistItems(playlistId: playlist.id, max: 8)
                    var itemsWithViewCount: [PlaylistItem] = []
                    
                    for var item in items {
                        let videos = try await self.getVideos(by: item.snippet.resourceId.videoId)
                        
                        if let video = videos.first {
                            item.snippet.viewCount = video.statistics.viewCount
                        }
                        itemsWithViewCount.append(item)
                    }
                    playlist.playlistItems = itemsWithViewCount
                    updatedPlaylists.append(playlist)
                }
                guard var channel = channels.first else {
                    return
                }
                channel.playlists = updatedPlaylists
                loadedChannels.append(channel)
            }
            self.channels = loadedChannels
            self.sections = self.createSections(for: 0)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func selectChannel(_ channel: Channel) {
        self.selectedChannel = channel
        self.currentPlaylistItems = joinedPlaylistsItems(from: channel.playlists)
        self.currentTrackIndex = 0
        self.isPlayerOpen = true
    }
    
    func openPlayer(items: [PlaylistItem], startAt index: Int) {
        guard items.isEmpty == false else {
            return
        }
        let safeIndex = max(0, min(index, items.count - 1))
        self.currentPlaylistItems = items
        self.currentTrackIndex = safeIndex
        self.isPlayerOpen = true
    }
    
    // Methods. Private
    
    private func getChannels(by id: String) async  -> [Channel]? {
        (try? await self.service.getChannels(by: id)) ?? []
    }
    
    private func getPlaylists(by id: String, max: Int) async throws -> [Playlist] {
        do {
            let result = try await self.service.getPlaylists(by: id, max: max)
            return result
        } catch {
            self.errorMessage = error.localizedDescription
            return []
        }
    }
    
    private func getPlaylistItems(playlistId: String, max: Int) async throws -> [PlaylistItem] {
        do {
            let result = try await self.service.getPlaylistItems(playlistId: playlistId, max: max)
            return result
        } catch {
            self.errorMessage = error.localizedDescription
            return []
        }
    }
    
    private func getVideos(by id: String) async throws -> [Video] {
        do {
            let result = try await self.service.getVideos(by: id)
            return result
        } catch {
            self.errorMessage = error.localizedDescription
            return []
        }
    }
    
    private func createSections(for channelIndex: Int) -> [ResourceSection] {
        guard let channel = self.getChannel(by: channelIndex) else {
            return []
        }
        var sections: [ResourceSection] = []
        
        // Add first fixed section
        let cell = CellModel(title: "", typeOfCell: .pageControl(model: channels))
        let section = ResourceSection(title: "", items: [cell])
        sections.append(section)
        
        // Add sections depends of playlists count
        for playlist in channel.playlists ?? [] {
            let cell = CellModel(title: "", typeOfCell: .playlist(model: playlist))
            let section = ResourceSection(title: playlist.snippet.title, items: [cell])
            sections.append(section)
        }
        return sections
    }
    
    private func getChannel(by index: Int) -> Channel? {
        guard self.channels.indices.contains(index) else {
            return nil
        }
        return self.channels[index]
    }
    
    private func joinedPlaylistsItems(from playlists: [Playlist]?) -> [PlaylistItem] {
        guard let lists = playlists?.compactMap(\.playlistItems) else {
            return []
        }
        return Array(lists.joined())
    }
    
}
