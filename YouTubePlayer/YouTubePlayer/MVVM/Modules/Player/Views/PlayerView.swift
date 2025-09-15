//
//  PlayerView.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 08.09.2025.
//

import SwiftUI
import Factory
import MediaPlayer
import YouTubePlayerKit

enum PlayerState {
    case collapsed
    case expanded
}

struct PlayerView: View {
    @Environment(HomeViewModel.self) private var youTubeViewModel
    @State private var playerViewModel = PlayerViewModel()
    @Injected(\.youTubePlayer) private var player
    @State private var dragOffset: CGFloat = 0.0
    @State private var progress: Double = 0.0
    @State private var durationSec: Double = 0
    @State private var state: PlayerState = .collapsed
    let collapsedHeight: CGFloat = 50.0
    let topGap: CGFloat = 4.0
    let topOffset: CGFloat
    
    var body: some View {
        GeometryReader { geo in
            let totalHeight: CGFloat = geo.size.height
            let topExpanded: CGFloat = topOffset + topGap
            let topCollapsed: CGFloat = totalHeight - collapsedHeight
            let expandedHeight: CGFloat = totalHeight - topExpanded
            
            ZStack {
                GradientBackgroundView()
                
                VStack(spacing: .zero) {
                    HeaderView(playerViewModel: $playerViewModel, collapsedHeight: collapsedHeight)
                    
                    CustomPlayerView(playerViewModel: $playerViewModel)
                    
                    CustomProgressView(playerViewModel: $playerViewModel, durationSec: $durationSec)
                    
                    ControlPanelView(playerViewModel: $playerViewModel)
                    
                    CustomVolumeView()
                    
                    BottomView()
                }
            }
            .modifier(LoadViewModifier(playerViewModel: $playerViewModel, state: $state, dragOffset: $dragOffset, topOffset: topOffset, expandedHeight: expandedHeight, topExpanded: topExpanded, topCollapsed: topCollapsed, geo: geo))
            .modifier(PlayerViewModifier(state: $state, playerViewModel: $playerViewModel))
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
    
    private struct HeaderView: View {
        @Environment(HomeViewModel.self) private var youTubeViewModel
        @Binding var playerViewModel: PlayerViewModel
        let collapsedHeight: CGFloat
        
        var body: some View {
            ZStack {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: collapsedHeight)
                
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        youTubeViewModel.isPlayerOpen = false
                    }
                }) {
                    Image(asset: Asset.openClose)
                        .renderingMode(.original)
                        .rotationEffect(playerViewModel.isPlayerOpen ? .degrees(180.0) : .degrees(.zero))
                }
                .disabled(!youTubeViewModel.isPlayerOpen)
            }
        }
        
    }
    
    private struct CustomProgressView: View {
        @Binding var playerViewModel: PlayerViewModel
        @State var isScrubbing: Bool = false
        @Binding var durationSec: Double
        @Injected(\.youTubePlayer) private var player
        
        var body: some View {
            VStack(spacing: 17.0) {
                VStack {
                    Color.clear
                        .frame(height: 0.0)
                        .onAppear { durationSec = playerViewModel.progress }
                        .onChange(of: playerViewModel.progress) { _, new in
                            if !isScrubbing { durationSec = new }
                        }
                    
                    CustomSlider(
                        value: $durationSec,
                        onEditingChanged: { began in
                            isScrubbing = began
                            if began {
                                Task { try? await player.pause() }
                            }
                        },
                        onChange: { _ in
                        },
                        onEnded: { newValue in
                            playerViewModel.seek(to: newValue)
                            Task { try? await player.play() }
                            isScrubbing = false
                        }
                    )
                    .transaction { $0.disablesAnimations = true }
                    
                    Spacer()
                    
                    HStack {
                        Text(playerViewModel.elapsedText)
                            .font(.custom(FontFamily.SFProText.regular, size: 11.0))
                            .foregroundStyle(Asset.playerTransparentWhite70.swiftUIColor)
                        
                        Spacer()
                        
                        Text(playerViewModel.remainingText)
                            .font(.custom(FontFamily.SFProText.regular, size: 11.0))
                            .foregroundStyle(Asset.playerTransparentWhite70.swiftUIColor)
                    }
                }
                .frame(height: 33.0)
                .padding(.horizontal, 13.0)
                
                
                VStack {
                    Text(playerViewModel.videoSnippet?.title ?? "")
                        .font(.custom(FontFamily.SFProText.medium, size: 18.0))
                        .foregroundStyle(Asset.homeHeaderTitleTextColor.swiftUIColor)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("\(playerViewModel.videoSnippet?.viewCount?.splitIntoThounsandParts ?? "") \(L10n.views)")
                        .font(.custom(FontFamily.SFProText.regular, size: 16.0))
                        .foregroundStyle(Asset.playerTransparentWhite70.swiftUIColor)
                        .lineLimit(1)
                        .padding(.horizontal, 44.0)
                }
                .frame(height: 49.0)
                .padding(.horizontal, 53.5)
            }
            .padding(.top, 19.0)
        }
        
        private struct CustomSlider: View {
            @Binding var value: Double
            var trackHeight: CGFloat = 4.0
            var minTrack: Color = Asset.homeHeaderTitleTextColor.swiftUIColor
            var maxTrack: Color = Asset.playerTransparentWhite35.swiftUIColor
            var thumbWidth: CGFloat = 2.0
            var thumbHeight: CGFloat = 12.0
            var thumbColor: Color = Asset.homeHeaderTitleTextColor.swiftUIColor
            
            var onEditingChanged: ((Bool) -> Void)? = nil
            var onChange: ((Double) -> Void)? = nil
            var onEnded: ((Double) -> Void)? = nil
            
            var body: some View {
                GeometryReader { geo in
                    let width = geo.size.width
                    let height = max(trackHeight, thumbHeight)
                    let progress = CGFloat(value.clamped(to: 0...1))
                    let position = progress * width
                    let centerY = height / 2.0
                    
                    ZStack {
                        Capsule()
                            .fill(maxTrack)
                            .frame(height: trackHeight)
                            .position(x: width / 2.0, y: centerY)
                        
                        Capsule()
                            .fill(minTrack)
                            .frame(width: max(0.0, position), height: trackHeight)
                            .position(x: max(0.0, position) / 2.0, y: centerY)
                        
                        Rectangle()
                            .fill(thumbColor)
                            .frame(width: thumbWidth, height: thumbHeight)
                            .position(x: position, y: centerY)
                    }
                    .contentShape(Rectangle())
                    .highPriorityGesture(
                        DragGesture(minimumDistance: .zero)
                            .onChanged { geo in
                                let clampedX = min(max(.zero, geo.location.x), width)
                                let newValue = Double(clampedX / width)
                                if newValue != value {
                                    if onEditingChanged != nil && (geo.startLocation == geo.location) {
                                        onEditingChanged?(true)
                                    }
                                    value = newValue
                                    onChange?(newValue)
                                }
                            }
                            .onEnded { geo in
                                let clampedX = min(max(.zero, geo.location.x), width)
                                let newValue = Double(clampedX / width)
                                value = newValue
                                onEnded?(newValue)
                                onEditingChanged?(false)
                            }
                    )
                }
                .frame(height: max(trackHeight, thumbHeight))
            }

        }
    }
    
    private struct CustomPlayerView: View {
        @Environment(HomeViewModel.self) private var youTubeViewModel
        @Binding var playerViewModel: PlayerViewModel
        @Injected(\.youTubePlayer) private var player
        
        var body: some View {
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
            .onReceive(player.playbackStatePublisher) { state in
                if state == .ended {
                    let items = youTubeViewModel.currentPlaylistItems
                    guard !items.isEmpty else {
                        return
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if playerViewModel.isRepeatModeEnable == false {
                            Task { try? await player.pause() }
                            playerViewModel.isPlaying = false
                        }
                        if playerViewModel.isRepeatModeEnable {
                            youTubeViewModel.currentTrackIndex = (youTubeViewModel.currentTrackIndex + 1) % items.count
                        }
                        if playerViewModel.isShuffleModeEnabled {
                            if items.count > 1 {
                                var randomIndex: Int
                                repeat {
                                    randomIndex = Int.random(in: 0 ..< items.count)
                                } while randomIndex == youTubeViewModel.currentTrackIndex
                                youTubeViewModel.currentTrackIndex = randomIndex
                            }
                        }
                    }
                }
            }
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
                playerViewModel.fetchDuration()
                playerViewModel.startTrackingCurrentTime()

            }
            .frame(height: 235.0)
        }
        
    }
    
    private struct ControlPanelView: View {
        @Environment(HomeViewModel.self) private var youTubeViewModel
        @Binding var playerViewModel: PlayerViewModel
        @Injected(\.youTubePlayer) private var player
        
        var body: some View {
            HStack {
                Button(action: {
                    playerViewModel.isRepeatModeEnable.toggle()
                    playerViewModel.isShuffleModeEnabled = false
                }) {
                    Image(systemName: "repeat")
                        .font(.system(size: 24.0))
                        .foregroundStyle(playerViewModel.isRepeatModeEnable ? .white : Asset.playerHeaderTitleTextColor.swiftUIColor)
                }
                
                Spacer()
                
                Button(action: {
                    guard !youTubeViewModel.currentPlaylistItems.isEmpty else {
                        return
                    }
                    youTubeViewModel.currentTrackIndex = max(0, youTubeViewModel.currentTrackIndex - 1)
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
                    Image(asset: playerViewModel.isPlaying ? Asset.pause : Asset.play)
                        .renderingMode(.original)
                }
                
                Spacer()
                
                Button(action: {
                    guard youTubeViewModel.currentPlaylistItems.isEmpty == false else {
                        return
                    }
                    youTubeViewModel.currentTrackIndex = min(youTubeViewModel.currentPlaylistItems.count - 1, youTubeViewModel.currentTrackIndex + 1)
                }) {
                    Image(asset: Asset.next)
                        .renderingMode(.original)
                }
                
                Spacer()
                
                Button(action: {
                    playerViewModel.isShuffleModeEnabled.toggle()
                    playerViewModel.isRepeatModeEnable = false
                }) {
                    Image(systemName: "shuffle")
                        .font(.system(size: 24.0))
                        .foregroundStyle(playerViewModel.isShuffleModeEnabled ? .white : Asset.playerHeaderTitleTextColor.swiftUIColor)
                }
            }
            .frame(height: 30.0)
            .padding(.horizontal, 30.0)
            .padding(.top, 41.0)
        }
        
    }
    
    private struct CustomVolumeView: View {
        
        var body: some View {
            ZStack {
                HStack {
                    Image(asset: Asset.soundMin)
                        .renderingMode(.original)
                    
                    VolumeSliderView(style: .init(
                        minTrack: Asset.homeHeaderTitleTextColor.color,
                        maxTrack: Asset.playerTransparentWhite35.color,
                        thumb: .circle(diameter: 21.0, color: Asset.homeHeaderTitleTextColor.color),
                        hideRouteButton: true,
                    ))
                    
                    Image(asset: Asset.soundMax)
                        .renderingMode(.original)
                }
            }
            .frame(height: 21.0)
            .padding(.horizontal, 18.0)
            .padding(.top, 46.0)
        }
        
    }
    
    private struct BottomView: View {
        
        var body: some View {
            Rectangle()
                .fill(Color.clear)
                .frame(maxHeight: .infinity)
        }
        
    }
    
    private struct LoadViewModifier: ViewModifier {
        @Environment(HomeViewModel.self) private var youTubeViewModel
        @Binding var playerViewModel: PlayerViewModel
        @Binding var state: PlayerState
        @Binding var dragOffset: CGFloat
        let topOffset: CGFloat
        let expandedHeight: CGFloat
        let topExpanded: CGFloat
        let topCollapsed: CGFloat
        let geo: GeometryProxy
        
        func body(content: Content) -> some View {
            content
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
                                    // dragOffset = min(0.0, value.translation.height)
                                    break
                            }
                        }
                        .onEnded { value in
                            let travel = (topCollapsed - topExpanded)
                            let trigger = travel * 0.20
                            let dy = value.translation.height
                            let dyEnd = value.predictedEndTranslation.height
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                switch state {
                                    case .expanded:
                                        if (dy >= trigger) || (dyEnd >= trigger) {
                                            state = .collapsed
                                            youTubeViewModel.isPlayerOpen = false
                                            playerViewModel.isPlaying = true
                                        }
                                    case .collapsed:
//                                        if (-dy >= trigger) || (-dyEnd >= trigger) {
//                                            state = .expanded
//                                            youTubeViewModel.isPlayerOpen = true
//                                            playerViewModel.isPlaying = true
//                                        }
                                        break
                                }
                                dragOffset = .zero
                            }
                        }
                )
        }
    }
    
    private struct PlayerViewModifier: ViewModifier {
        @Environment(HomeViewModel.self) private var youTubeViewModel
        @Binding var state: PlayerState
        @Binding var playerViewModel: PlayerViewModel
        @Injected(\.youTubePlayer) private var player
        
        func body(content: Content) -> some View {
            content
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
                        let videoSnippet = youTubeViewModel.currentPlaylistItems[index].snippet
                        playerViewModel.videoSnippet = videoSnippet
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
                .onChange(of: youTubeViewModel.currentTrackIndex) {
                    playerViewModel.videoSnippet = youTubeViewModel.currentPlaylistItems[youTubeViewModel.currentTrackIndex].snippet
                }
        }
    }
}
