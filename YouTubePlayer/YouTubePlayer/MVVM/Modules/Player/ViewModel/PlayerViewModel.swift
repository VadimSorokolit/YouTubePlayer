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
    private(set) var currentSeconds: Double = 0.0
    private(set) var durationSeconds: Double = 0.0
    var elapsedText: String { self.formatTime(self.currentSeconds)
    }
    var remainingText: String {
        let remain = max(0, self.durationSeconds - self.currentSeconds)
        return "-" + self.formatTime(remain)
    }

    var progress: Double {
        guard durationSeconds > 0 else { return 0 }
        return min(max(currentSeconds / durationSeconds, 0), 1)
    }

    // MARK: - Properties. Private

    @ObservationIgnored
    @Injected(\.youTubePlayer) private var player
    private var trackerTask: Task<Void, Never>?

    // MARK: - Methods. Public

    func startTrackingCurrentTime() {
        stopTrackingCurrentTime()
        trackerTask = Task {
            while !Task.isCancelled {
                do {
                    let t = try await player.getCurrentTime()
                    let secs = t.converted(to: .seconds).value
                    await MainActor.run { self.currentSeconds = secs }
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
                let secs = duration.converted(to: .seconds).value
                self.durationSeconds = secs
            } catch {}
        }
    }
    
    func seek(to progress: Double) {
        
        let target = max(0, min(1, progress)) * self.durationSeconds
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
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%01d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%01d:%02d", m, s)
        }
    }
} 
