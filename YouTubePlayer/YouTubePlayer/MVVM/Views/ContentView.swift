//
//  ContentView.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 25.08.2025.
//
    
import SwiftUI
import SwiftGenPluginKit

struct ContentView: View {
    
    // MARK: - Main body
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .modifier(LoadViewModifier())
    }
    
    
    // MARK: - Modifiers
    
    struct LoadViewModifier: ViewModifier {
        @Environment(YouTubeViewModel.self) private var viewModel
        
        func body(content: Content) -> some View {
            content
                .onAppear {
                    self.viewModel.loadChannels(by: L10n.channelId2)
                }
        }
    }
}

#Preview {
    ContentView()
}
