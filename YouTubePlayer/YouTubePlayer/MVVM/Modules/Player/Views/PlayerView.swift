//
//  PlayerView.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 08.09.2025.
//

import SwiftUI

enum PlayerState {
    case collapsed
    case expanded
}

struct PlayerView: View {
    @Environment(YouTubeViewModel.self) private var youTubeViewModel
    @State private var playerViewModel = PlayerViewModel()
    @State private var dragOffset: CGFloat = 0.0
    @State private var state: PlayerState = .collapsed
    var collapsedHeight: CGFloat = 50.0
    let topOffset: CGFloat
    
    var body: some View {
        GeometryReader { geo in
            let totalHeight = geo.size.height
            let topCollapsed = totalHeight - collapsedHeight
            let expandedHeight = totalHeight - topOffset
            
            ZStack {
                GradientBackgroundView()
                
                VStack(spacing: 0.0) {
                    ZStack {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 50.0)
                        
                        Image(asset: Asset.openClose)
                            .renderingMode(.original)
                            .rotationEffect(playerViewModel.isPlayerOpen ? .degrees(180.0) : .degrees(0.0))
                    }
                    
                    Rectangle()
                        .fill(Color.black)
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
                    
                    Rectangle()
                        .fill(Color.clear)
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
            .frame(width: geo.size.width, height: expandedHeight, alignment: .top)
            .offset(
                y: {
                    let base = (state == .expanded) ? topOffset : topCollapsed
                    let current = base + dragOffset
                    
                    return min(max(current, topOffset), topCollapsed)
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
                        let travel = (topCollapsed - topOffset)
                        let trigger = travel * 0.10
                        
                        let dy = value.translation.height
                        let dyEnd = value.predictedEndTranslation.height
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            switch state {
                                case .collapsed:
                                    if (-dy >= trigger) || (-dyEnd >= trigger) {
                                        state = .expanded
                                        playerViewModel.isPlayerOpen = true
                                        youTubeViewModel.isPlayerOpen = true
                                    }
                                case .expanded:
                                    if (dy >= trigger) || (dyEnd >= trigger) {
                                        state = .collapsed
                                        playerViewModel.isPlayerOpen = false
                                        youTubeViewModel.isPlayerOpen = false
                                    }
                            }
                            dragOffset = 0.0
                        }
                    }
            )
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
