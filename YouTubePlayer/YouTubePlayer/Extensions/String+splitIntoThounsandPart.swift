//
//  String+splitIntoThounsandPart.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 14.09.2025.
//
    
import Foundation

extension String {
    
    var splitIntoThounsandParts: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter.string(for: Int(self))
    }
    
}
