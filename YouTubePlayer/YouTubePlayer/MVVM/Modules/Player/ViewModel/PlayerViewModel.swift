//
//  PlayerViewModel.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 08.09.2025.
//

import Foundation
import Factory

@Observable
class PlayerViewModel {
    
    // MARK: - Properties. Public
    
    var videoSnippet: PlaylistItem.Snippet?
    var isPlayerOpen: Bool = false
    var isPlaying: Bool = false
    var duration: String?
    var currentTime: String?
    var currentDuration: String?
    
    // MARK: - Properties. Private
    
    @ObservationIgnored
    @Injected(\.youTubePlayer) private var player
    private let secondsInHour: Int = 60 * 60
    
    // MARK: - Methods. Public
    
    func startTrackingCurrentTime() {
        Task {
            while !Task.isCancelled {
                do {
                    let currentTime = try await player.getCurrentTime()
                    await MainActor.run {
                        let seconds = currentTime.converted(to: .seconds).value
                        let convert = self.formattedTime(by: seconds)
                        self.currentTime = convert
                    }
                } catch {
                    print("Error: \(error)")
                }
                try? await Task.sleep(nanoseconds: 500_000_000)
            }
        }
    }
    
    func getDuration() {
        Task {
            do {
                try await Task.sleep(nanoseconds: 999_000_000)
                let duration = try await self.player.getDuration()
                let seconds = duration.converted(to: .seconds).value
                let convert = self.formattedTime(by: seconds)
                self.duration = convert
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    // MARK: - Methods. Private
    
    private func formattedTime(by seconds: Double) -> String {
        let (hours, minutes, seconds) = self.convertToHoursMinutesSeconds(from: Int(seconds))
        let formattedTimeString = self.formattedTimeStringBy(hours, minutes, seconds)
        
        return formattedTimeString
    }
    
    private func convertToHoursMinutesSeconds(from seconds: Int) -> (Int, Int, Int) {
        let hours = seconds / self.secondsInHour
        let minutes = (seconds % self.secondsInHour) / 60
        let seconds = (seconds % self.secondsInHour) % 60
        
        return (hours, minutes, seconds)
    }
    
    private func formattedTimeStringBy(_ hours: Int, _ minutes: Int, _ seconds: Int) -> String {
        if hours > 0 {
            return String(format: "%01i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%01i:%02i", minutes, seconds)
        }
    }
    
}
