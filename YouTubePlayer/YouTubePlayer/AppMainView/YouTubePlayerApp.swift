//
//  YouTubePlayerApp.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 25.08.2025.
//
    
import SwiftUI

@main
struct YouTubePlayerApp: App {
    
    // MARK: - Properties. Private
    
    @State private var viewModel = YouTubeViewModel()
    
    // MARK: - Root Scene
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(self.viewModel)
    }
}
