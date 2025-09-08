//
//  ContentView.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 25.08.2025.
//
    
import SwiftUI

struct HomeView: View {
    
    // MARK: - Main body
    
    var body: some View {
        ZStack {
            Asset.customBackground.swiftUIColor.ignoresSafeArea()
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Text("YouTube Player")
                    .foregroundColor(.white)
                    .font(.custom(FontFamily.SFProDisplay.bold, size: 34.0))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7)
                    .lineLimit(1)
                    .padding(.leading, 24.0)
                
                Spacer()
            }
        }
    }
    
    
    // MARK: - Modifiers
    
    struct LoadViewModifier: ViewModifier {
        @Environment(YouTubeViewModel.self) private var viewModel
        
        func body(content: Content) -> some View {
            content
                .onAppear {}
        }
    }
}
