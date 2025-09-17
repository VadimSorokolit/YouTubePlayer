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
    
    var isShuffleModeEnabled: Bool = false
    var isRepeatModeEnable: Bool = false
    var videoSnippet: PlaylistItem.Snippet?
    var isPlayerOpen: Bool = false
    var isPlaying: Bool = false
    var remainingText: String {
        let remain = max(0, self.durationSeconds - self.currentSeconds)
        
        return "-" + self.formatTime(remain)
    }
    var progress: Double {
        guard self.durationSeconds > 0.0 else {
            return 0.0
        }
        return min(max(self.currentSeconds / self.durationSeconds, 0.0), 1.0)
    }
    var elapsedText: String {
        self.formatTime(self.currentSeconds)
    }
    var isUserScrubbing: Bool = false
    
    // MARK: - Properties. Private
    
    private var previewSeekTask: Task<Void, Never>?
    private(set) var currentSeconds: Double = 0.0
    private(set) var durationSeconds: Double = 0.0
    private var trackerTask: Task<Void, Never>?

    @ObservationIgnored
    @Injected(\.youTubePlayer) private var player

    // MARK: - Methods. Public

    func startTrackingCurrentTime() {
        self.stopTrackingCurrentTime()
        self.trackerTask = Task {
            while !Task.isCancelled {
                do {
                    let time = try await player.getCurrentTime()
                    let seconds = time.converted(to: .seconds).value
                    await MainActor.run {
                        self.currentSeconds = seconds
                    }
                } catch {}
                try? await Task.sleep(nanoseconds: 120_000_000) 
            }
        }
    }

    func stopTrackingCurrentTime() {
        self.trackerTask?.cancel()
        self.trackerTask = nil
    }

    func fetchDuration() {
        Task {
            do {
                try? await Task.sleep(nanoseconds: 999_000_000)
                let duration = try await self.player.getDuration()
                let seconds = duration.converted(to: .seconds).value
                await MainActor.run {
                    if !self.isUserScrubbing {
                        self.durationSeconds = seconds
                    }
                }
            } catch {}
            try? await Task.sleep(nanoseconds: 180_000_000)
        }
    }
    
    func previewSeek(toProgress progress: Double) {
        guard self.durationSeconds > 0 else { return }
        let target = max(0.0, min(1.0, progress)) * self.durationSeconds

        self.previewSeekTask?.cancel()
        self.isUserScrubbing = true
        self.currentSeconds = target
        
        self.previewSeekTask = Task {
            try? await Task.sleep(nanoseconds: 120_000_000)
            try? await self.player.seek(to: .init(value: target, unit: .seconds))
        }
    }
    
    func seek(to progress: Double) {
        let target = max(0.0, min(1.0, progress)) * self.durationSeconds
        self.previewSeekTask?.cancel()
        self.isUserScrubbing = true
        self.currentSeconds = target
        Task {
            try? await self.player.seek(to: .init(value: target, unit: .seconds))
        }
    }
    
    func resetProgress() {
        self.currentSeconds = 0.0
        self.durationSeconds = 0.0
    }

    // MARK: - Methods. Private

    private func formatTime(_ seconds: Double) -> String {
        let total = Int(seconds.rounded(.down))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        
        if hours > 0 {
            return String(format: "%01d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%01d:%02d", minutes, seconds)
        }
    }
} 
