//
//  PlayerViewModel.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 08.09.2025.
//

import Foundation

@Observable
class PlayerViewModel {
    
    // MARK: - Properties. Public
    
    var isPlayerOpen: Bool = false
    
    // MARK: - Properties. Private
    
    private let secondsInHour: Int = 60 * 60
    
    // MARK: - Methods
    
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
