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
    
    // MARK: - Properties. Private
    
    @State private var dragOffset: CGFloat = .zero
    @State private var progress: Double = .zero
    @State private var state: PlayerState = .collapsed
    @State private var isScrubbing: Bool = false
    
    // MARK: - Properties. Public
    
    let collapsedHeight: CGFloat = 50.0
    let topGap: CGFloat = 4.0
    let topOffset: CGFloat
    
    // MARK: - Main body
    
    var body: some View {
        GeometryReader { geo in
            let totalHeight: CGFloat = geo.size.height
            let topExpanded: CGFloat = topOffset + topGap
            let topCollapsed: CGFloat = totalHeight - collapsedHeight
            let expandedHeight: CGFloat = totalHeight - topExpanded
            
            ZStack {
                GradientBackgroundView()
                
                VStack(spacing: .zero) {
                    HeaderView(collapsedHeight: collapsedHeight)
                    
                    CustomPlayerView(isScrubbing: $isScrubbing, progress: $progress)
                    
                    CustomProgressView(isScrubbing: $isScrubbing, progress: $progress)
                    
                    ControlPanelView()
                    
                    CustomVolumeView()
                    
                    BottomView()
                }
            }
            .modifier(LoadViewModifier(state: $state, dragOffset: $dragOffset, topOffset: topOffset, expandedHeight: expandedHeight, topExpanded: topExpanded, topCollapsed: topCollapsed, geo: geo))
            .modifier(PlayerViewModifier(state: $state))
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
        @Environment(HomeViewModel.self) private var homeViewModel
        @Environment(PlayerViewModel.self) private var playerViewModel
        let collapsedHeight: CGFloat
        
        var body: some View {
            ZStack {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: collapsedHeight)
                
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        homeViewModel.isPlayerOpen = false
                    }
                }) {
                    Image(asset: Asset.openClose)
                        .renderingMode(.original)
                        .rotationEffect(playerViewModel.isPlayerOpen ? .degrees(180.0) : .degrees(.zero))
                }
                .disabled(homeViewModel.isPlayerOpen == false)
            }
        }
        
    }
    
    private struct CustomProgressView: View {
        @Environment(PlayerViewModel.self) private var playerViewModel
        @Binding var isScrubbing: Bool
        @Binding var progress: Double
        
        var body: some View {
            VStack(spacing: 17.0) {
                VStack {
                    Color.clear
                        .frame(height: 0.0)
                        .onAppear {
                            progress = playerViewModel.progress
                        }
                        .onChange(of: playerViewModel.progress) { _, newValue in
                            if isScrubbing == false {
                                progress = newValue.clamped(to: 0 ... 1)
                            }
                        }
                    
                    CustomSlider(
                        value: $progress,
                        onEditingChanged: { began in
                            isScrubbing = began
                            playerViewModel.isUserScrubbing = began
                            if began {
                                playerViewModel.pause()
                            }
                        },
                        onChange: { value in
                            if isScrubbing {
                                playerViewModel.previewSeek(toProgress: value)
                            }
                        },
                        onEnded: { newValue in
                            playerViewModel.seek(to: newValue)
                            playerViewModel.play()
                            isScrubbing = false
                            playerViewModel.isUserScrubbing = false
                        }
                    )
                    .transaction { $0.disablesAnimations = true }
                    
                    Spacer()
                    
                    HStack {
                        Text(playerViewModel.elapsedText)
                            .font(.system(size: 11.0, weight: .regular, design: .rounded))
                            .foregroundStyle(Asset.playerTransparentWhite70.swiftUIColor)
                            .monospaced()
                        
                        Spacer()
                        
                        Text(playerViewModel.remainingText)
                            .font(.system(size: 11.0, weight: .regular, design: .rounded))
                            .foregroundStyle(Asset.playerTransparentWhite70.swiftUIColor)
                            .monospaced()
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
                    
                    Text("\(playerViewModel.videoSnippet?.viewCount?.splitIntoThousandParts ?? "") \(L10n.views)")
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
                    let width: CGFloat = max(geo.size.width, 1.0)
                    let height: CGFloat = max(trackHeight, thumbHeight)
                    let progress: CGFloat = value.clamped(to: 0.0 ... 1.0)
                    let position: CGFloat = progress * width
                    let centerY: CGFloat = height / 2.0
                    
                    ZStack {
                        Capsule()
                            .fill(maxTrack)
                            .frame(height: trackHeight)
                            .position(x: width / 2.0, y: centerY)
                        
                        Capsule()
                            .fill(minTrack)
                            .frame(width: max(.zero, position), height: trackHeight)
                            .position(x: max(.zero, position) / 2.0, y: centerY)
                        
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
        @Environment(HomeViewModel.self) private var homeViewModel
        @Environment(PlayerViewModel.self) private var playerViewModel
        @Binding var isScrubbing: Bool
        @Binding var progress: Double
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
                    let items = homeViewModel.currentPlaylistItems
                    guard !items.isEmpty else {
                        return
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if playerViewModel.isRepeatModeEnable == false {
                            playerViewModel.pause()
                            playerViewModel.isPlaying = false
                        }
                        if playerViewModel.isRepeatModeEnable {
                            homeViewModel.currentTrackIndex = (homeViewModel.currentTrackIndex + 1) % items.count
                        }
                        if playerViewModel.isShuffleModeEnabled {
                            if items.count > 1 {
                                var randomIndex: Int
                                repeat {
                                    randomIndex = Int.random(in: .zero ..< items.count)
                                } while randomIndex == homeViewModel.currentTrackIndex
                                homeViewModel.currentTrackIndex = randomIndex
                            }
                        }
                    }
                }
            }
            .onAppear {
                if let id = homeViewModel.currentItem?.snippet.resourceId.videoId {
                    playerViewModel.loadVideo(id: id)
                    playerViewModel.fetchDuration()
                    playerViewModel.startTrackingCurrentTime()
                }
            }
            .onChange(of: homeViewModel.currentItem?.snippet.resourceId.videoId) { _, newId in
                guard let newId else {
                    return
                }
                playerViewModel.loadVideo(id: newId)
                isScrubbing = false
                progress = .zero
                playerViewModel.fetchDuration()
                playerViewModel.startTrackingCurrentTime()
            }
            .frame(height: 235.0)
        }
        
    }
    
    private struct ControlPanelView: View {
        @Environment(HomeViewModel.self) private var homeViewModel
        @Environment(PlayerViewModel.self) private var playerViewModel
        
        var body: some View {
            HStack {
                Button(action: {
                    playerViewModel.isRepeatModeEnable.toggle()
                    playerViewModel.isShuffleModeEnabled = false
                }) {
                    Image(systemName: L10n.repeatImageName)
                        .font(.system(size: 24.0))
                        .foregroundStyle(playerViewModel.isRepeatModeEnable ? .white : Asset.playerHeaderTitleTextColor.swiftUIColor)
                }
                
                Spacer()
                
                Button(action: {
                    guard !homeViewModel.currentPlaylistItems.isEmpty else {
                        return
                    }
                    homeViewModel.currentTrackIndex = max(.zero, homeViewModel.currentTrackIndex - 1)
                }) {
                    Image(asset: Asset.next)
                        .renderingMode(.original)
                        .rotationEffect(.degrees(180.0))
                    
                }
                
                Spacer()
                
                Button(action: {
                    if playerViewModel.isPlaying {
                        playerViewModel.pause()
                        playerViewModel.isPlaying = false
                    } else {
                        playerViewModel.play()
                        playerViewModel.isPlaying = true
                    }
                }) {
                    Image(asset: playerViewModel.isPlaying ? Asset.pause : Asset.play)
                        .renderingMode(.original)
                }
                
                Spacer()
                
                Button(action: {
                    guard homeViewModel.currentPlaylistItems.isEmpty == false else {
                        return
                    }
                    homeViewModel.currentTrackIndex = min(homeViewModel.currentPlaylistItems.count - 1, homeViewModel.currentTrackIndex + 1)
                }) {
                    Image(asset: Asset.next)
                        .renderingMode(.original)
                }
                
                Spacer()
                
                Button(action: {
                    playerViewModel.isShuffleModeEnabled.toggle()
                    playerViewModel.isRepeatModeEnable = false
                }) {
                    Image(systemName: L10n.shuffleImageName)
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
        @Environment(HomeViewModel.self) private var homeViewModel
        @Environment(PlayerViewModel.self) private var playerViewModel
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
                                    dragOffset = max(.zero, value.translation.height)
                                case .collapsed:
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
                                            homeViewModel.isPlayerOpen = false
                                            playerViewModel.isPlaying = true
                                        }
                                    case .collapsed:
                                        break
                                }
                                dragOffset = .zero
                            }
                        },
                    including: .gesture
                )
        }
    }
    
    private struct PlayerViewModifier: ViewModifier {
        @Environment(HomeViewModel.self) private var homeViewModel
        @Environment(PlayerViewModel.self) private var playerViewModel
        @Binding var state: PlayerState
        
        func body(content: Content) -> some View {
            content
                .onChange(of: homeViewModel.isPlayerOpen) {
                    if homeViewModel.isPlayerOpen {
                        playerViewModel.isPlayerOpen = true
                        playerViewModel.isPlaying = true
                        state = .expanded
                        let index = homeViewModel.currentTrackIndex
                        guard homeViewModel.currentPlaylistItems.indices.contains(index) else {
                            return
                        }
                        let id = homeViewModel.currentPlaylistItems[index].snippet.resourceId.videoId
                        let videoSnippet = homeViewModel.currentPlaylistItems[index].snippet
                        playerViewModel.videoSnippet = videoSnippet
                        playerViewModel.loadVideo(id: id)
                        playerViewModel.play()
                    } else {
                        playerViewModel.isPlayerOpen = false
                        playerViewModel.isPlaying = false
                        state = .collapsed
                        playerViewModel.pause()
                    }
                }
                .onChange(of: homeViewModel.currentTrackIndex) {
                    playerViewModel.videoSnippet = homeViewModel.currentPlaylistItems[homeViewModel.currentTrackIndex].snippet
                }
        }
    }
}

