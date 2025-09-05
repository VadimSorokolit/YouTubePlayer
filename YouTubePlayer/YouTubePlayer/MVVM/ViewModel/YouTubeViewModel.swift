//
//  YouTubeViewModel.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 28.08.2025.
//

import Foundation
import Factory

@Observable
final class YouTubeViewModel {
    
    // MARK: - Properties. Public
    
    var channels: [Channel] = []
    var errorMessage: String?
    
    // MARK: - Properties. Private
    
    @ObservationIgnored
    @Injected(\.youTubeNetworkService) private var service
    
    // MARK: - Methods. Public
    
    func loadChannels(by id: String) {
        Task {
            do {
                let result = try await self.service.getChannels(by: id)
                self.channels = result
                dump(channels)
            } catch {
                self.errorMessage = error.localizedDescription
                print(self.errorMessage ?? "")
            }
        }
    }
    
    func loadPlaylists(by id: String, max: Int) {
        Task {
            do {
                let result = try await self.service.getPlaylists(by: id, max: max)
                dump(result)
            } catch {
                self.errorMessage = error.localizedDescription
                print(errorMessage ?? "")
            }
        }
    }
    
    func loadPlaylistItems(playlistId: String, max: Int) {
        Task {
            do {
                let result = try await self.service.getPlaylistItems(playlistId: playlistId, max: max)
                dump(result)
            } catch {
                self.errorMessage = error.localizedDescription
                print(self.errorMessage ?? "")
            }
        }
    }
    
    func loadVideos(by id: String) {
        Task {
            do {
                let result = try await self.service.getVideos(by: id)
                dump(result)
            } catch {
                self.errorMessage = error.localizedDescription
                print(self.errorMessage ?? "")
            }
        }
    }
    
}
