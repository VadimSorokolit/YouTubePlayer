//
//  Comparable+clamped.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 11.09.2025.
//
    
extension Comparable {
    
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
    
}
