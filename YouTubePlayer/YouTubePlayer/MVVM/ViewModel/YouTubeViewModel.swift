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
    
    // MARK: - Properties
    
    var channels: [Channel] = []
    
    var errorMessage: String?
    
    @ObservationIgnored
    @Injected(\.youTubeNetworkService) private var service
    
    // MARK: - Methods
    
    func loadChannels(by id: String) {
        Task {
            do {
                let result = try await self.service.getChannels(by: id)
                self.channels = result
                print(channels)
            } catch {
                self.errorMessage = error.localizedDescription
                print(errorMessage ?? "")
            }
        }
    }
    
}
