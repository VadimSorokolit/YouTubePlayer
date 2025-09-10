//
//  PlayerBottomSheet.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 09.09.2025.
//

import SwiftUI

enum PlayerState {
    case collapsed
    case expanded
}

struct PlayerBottomSheet: View {
    @State private var dragOffset: CGFloat = 0.0
    @Binding var state: PlayerState
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
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 50.0)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(height: 200.0)
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(maxHeight: .infinity)
                }
            }
            .padding(.horizontal, 6.0)
            .frame(width: geo.size.width, height: expandedHeight, alignment: .top)
            .offset(y: {
                let base = (state == .expanded) ? topOffset : topCollapsed
                let current = base + dragOffset
                return min(max(current, topOffset), topCollapsed)
            }())
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
                                    }
                                case .expanded:
                                    if (dy >= trigger) || (dyEnd >= trigger) {
                                        state = .collapsed
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
            .ignoresSafeArea()
        }
        
    }
}


