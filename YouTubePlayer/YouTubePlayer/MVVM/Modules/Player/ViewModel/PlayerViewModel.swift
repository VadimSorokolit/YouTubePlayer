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
    var errorMessage: String?
    var remainingText: String {
        let remain: Double = max(.zero, self.durationSeconds - self.currentSeconds)
        
        return L10n.remainingTimePrefix + self.formatTime(remain)
    }
    var progress: Double {
        guard self.durationSeconds > .zero else {
            return .zero
        }
        return min(max(self.currentSeconds / self.durationSeconds, .zero), 1.0)
    }
    var elapsedText: String {
        self.formatTime(self.currentSeconds)
    }
    var isUserScrubbing: Bool = false
    
    // MARK: - Properties. Private
    
    private var previewSeekTask: Task<Void, Never>?
    private(set) var currentSeconds: Double = .zero
    private(set) var durationSeconds: Double = .zero
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
                    try await Task.sleep(nanoseconds: 120_000_000)
                    let seconds = time.converted(to: .seconds).value
                    self.currentSeconds = seconds
                } catch {
                    self.errorMessage = error.localizedDescription
                }
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
                try await Task.sleep(nanoseconds: 999_000_000)
                let duration = try await self.player.getDuration()
                let seconds = duration.converted(to: .seconds).value
                
                if self.isUserScrubbing == false {
                    self.durationSeconds = seconds
                }
                try await Task.sleep(nanoseconds: 180_000_000)
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func previewSeek(toProgress progress: Double) {
        guard self.durationSeconds > .zero else {
            return
        }
        let target = max(.zero, min(1.0, progress)) * self.durationSeconds
        self.previewSeekTask?.cancel()
        self.isUserScrubbing = true
        self.currentSeconds = target
        
        self.previewSeekTask = Task {
            do {
                try await Task.sleep(nanoseconds: 120_000_000)
                try await self.player.seek(to: .init(value: target, unit: .seconds))
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func seek(to progress: Double) {
        let target = max(.zero, min(1.0, progress)) * self.durationSeconds
        self.previewSeekTask?.cancel()
        self.isUserScrubbing = true
        self.currentSeconds = target
        
        Task {
            do {
                try await self.player.seek(to: .init(value: target, unit: .seconds))
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func resetProgress() {
        self.currentSeconds = .zero
        self.durationSeconds = .zero
    }
    
    func play() {
        Task {
            do {
                try await self.player.play()
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func pause() {
        Task {
            do {
                try await self.player.pause()
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func loadVideo(id: String) {
        Task {
            do {
                try await player.load(source: .video(id: id), startTime: .init(value: .zero, unit: .seconds))
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Methods. Private
    
    private func formatTime(_ seconds: Double) -> String {
        let total = Int(seconds.rounded(.down))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        
        if hours > 0 {
            return L10n.videoTimeHms(hours, minutes, seconds)
        } else {
            return L10n.videoTimeMs(minutes, seconds)
        }
    }
}
