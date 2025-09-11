//
//  PlayerView.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 08.09.2025.
//

import SwiftUI
import YouTubePlayerKit

enum PlayerState {
    case collapsed
    case expanded
}

struct PlayerView: View {
    @Environment(HomeViewModel.self) private var youTubeViewModel
    @State private var playerViewModel = PlayerViewModel()
    @State private var player = YouTubePlayer()
    @State private var dragOffset: CGFloat = 0.0
    @State private var state: PlayerState = .collapsed
    let collapsedHeight: CGFloat = 50.0
    let topGap: CGFloat = 4.0
    let topOffset: CGFloat
    
    var body: some View {
        GeometryReader { geo in
            let totalHeight = geo.size.height
            let topExpanded = topOffset + topGap
            let topCollapsed = totalHeight - collapsedHeight
            let expandedHeight = totalHeight - topExpanded
            
            ZStack {
                GradientBackgroundView()
                
                VStack(spacing: 0.0) {
                    ZStack {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: collapsedHeight)
                        
                        Image(asset: Asset.openClose)
                            .renderingMode(.original)
                            .rotationEffect(playerViewModel.isPlayerOpen ? .degrees(180.0) : .degrees(0.0))
                    }
                    
                    YouTubePlayerView(player) { state in
                        switch state {
                            case .idle:
                                ProgressView()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.black)
                            case .ready:
                                EmptyView()
                            case .error(let error):
                                Text("Error: \(error.localizedDescription)")
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.black)
                        }
                    }
                    .background(Color.black)
                    .onAppear {
                        Task {
                            if let id = youTubeViewModel.currentItem?.snippet.resourceId.videoId {
                                try? await player.load(source: .video(id: id))
                            }
                        }
                    }
                    .onChange(of: youTubeViewModel.currentItem?.snippet.resourceId.videoId) { _, newId in
                        guard let newId else { return }
                        Task {
                            try? await player.load(source: .video(id: newId))
                        }
                    }
                    .frame(height: 235.0)
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 33.0)
                        .padding(.horizontal, 13.0)
                        .padding(.top, 19.0)
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 49.0)
                        .padding(.horizontal, 53.5)
                        .padding(.top, 17.0)
                    
                    HStack {
                        Button(action: {
                            guard !youTubeViewModel.currentPlaylistItems.isEmpty else {
                                return
                            }
                            youTubeViewModel.currentTrackIndex = max(
                                0,
                                youTubeViewModel.currentTrackIndex - 1
                            )
                        }) {
                            Image(asset: Asset.next)
                                .renderingMode(.original)
                                .rotationEffect(.degrees(180.0))
                            
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            Task {
                                if playerViewModel.isPlaying {
                                    try? await player.pause()
                                    playerViewModel.isPlaying = false
                                } else {
                                    try? await player.play()
                                    playerViewModel.isPlaying = true
                                }
                            }
                        }) {
                            Image(asset: playerViewModel.isPlayerOpen ? Asset.pause : Asset.play)
                                .renderingMode(.original)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            guard youTubeViewModel.currentPlaylistItems.isEmpty == false else {
                                return
                            }
                            youTubeViewModel.currentTrackIndex = min(
                                youTubeViewModel.currentPlaylistItems.count - 1,
                                youTubeViewModel.currentTrackIndex + 1
                            )
                        }) {
                            Image(asset: Asset.next)
                                .renderingMode(.original)
                        }
                    }
                    .frame(height: 30.0)
                    .padding(.horizontal, 94.5)
                    .padding(.top, 41.0)
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 21.0)
                        .padding(.horizontal, 18.0)
                        .padding(.top, 46.0)
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(maxHeight: .infinity)
                }
            }
            .padding(.horizontal, 6.0)
            .frame(width: geo.size.width, height: expandedHeight, alignment: .top)
            .offset(
                y: {
                    let base = (state == .expanded) ? topOffset : topCollapsed
                    let current = base + dragOffset
                    
                    return min(max(current, topExpanded), topCollapsed)
                }()
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        switch state {
                            case .expanded:
                                dragOffset = max(0.0, value.translation.height)
                            case .collapsed:
                                dragOffset = min(0.0, value.translation.height)
                        }
                    }
                    .onEnded { value in
                        let travel = (topCollapsed - topExpanded)
                        let trigger = travel * 0.20
                        
                        let dy = value.translation.height
                        let dyEnd = value.predictedEndTranslation.height
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            switch state {
                                case .collapsed:
                                    if (-dy >= trigger) || (-dyEnd >= trigger) {
                                        state = .expanded
                                        youTubeViewModel.isPlayerOpen = true
                                    }
                                case .expanded:
                                    if (dy >= trigger) || (dyEnd >= trigger) {
                                        state = .collapsed
                                        youTubeViewModel.isPlayerOpen = false
                                    }
                            }
                            dragOffset = 0.0
                        }
                    }
            )
        }
        .onChange(of: youTubeViewModel.isPlayerOpen) {
            if youTubeViewModel.isPlayerOpen {
                playerViewModel.isPlayerOpen = true
                playerViewModel.isPlaying = true
                state = .expanded
                let index = youTubeViewModel.currentTrackIndex
                guard youTubeViewModel.currentPlaylistItems.indices.contains(index) else {
                    return
                }
                let id = youTubeViewModel.currentPlaylistItems[index].snippet.resourceId.videoId
                Task {
                    try? await player.load(source: .video(id: id),
                                           startTime: .init(value: 0, unit: .seconds))
                    try? await player.play()
                }
            } else {
                playerViewModel.isPlayerOpen = false
                playerViewModel.isPlaying = false
                state = .collapsed
                Task {
                    try? await player.pause()
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private struct GradientBackgroundView: View {
        
        var body: some View {
            LinearGradient(
                colors: [
                    Asset.playerUpperBoundGradient.swiftUIColor,
                    Asset.playerLowerBoundGradient.swiftUIColor
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(20.0, corners: [.topLeft, .topRight])
        }
        
    }
}
