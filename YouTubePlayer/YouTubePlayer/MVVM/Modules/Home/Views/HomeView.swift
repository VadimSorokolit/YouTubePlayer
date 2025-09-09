//
//  HomeView.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 25.08.2025.
//

import SwiftUI

struct HomeView: View {
    
    // MARK: - Main body
    
    var body: some View {
        VStack(spacing: 32.0) {
            HeaderView()
            
            ContentView()
        }
        .background(Asset.customBackground.swiftUIColor.ignoresSafeArea())
    }
    
    private struct HeaderView: View {
        
        var body: some View {
            HStack {
                Text(L10n.homeScreenTitle)
                    .foregroundColor(Asset.headerTitleTextColor.swiftUIColor)
                    .font(.custom(FontFamily.SFProDisplay.bold, size: 34.0))
                    .lineLimit(1)
                    .padding(.leading, 24.0)
                
                Spacer()
            }
        }
        
    }
    
    private struct ContentView: View {
        @Environment(YouTubeViewModel.self) private var viewModel
        
        var body: some View {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0.0) {
                    if let firstSection = viewModel.sections.first,
                       case .pageControl(let channels) = firstSection.items.first?.typeOfCell {
                        ChannelPagerView(channels: channels)
                            .padding(.bottom, 4.0)
                    }
                    
                    ForEach(Array(viewModel.sections.dropFirst().enumerated()), id: \.element.id) { sectionIndex, section in
                        VStack(alignment: .leading, spacing: sectionIndex % 2 == 0 ? 20.0 : 13.0) {
                            Text(section.title)
                                .font(.custom(FontFamily.SFProDisplay.bold, size: 23.0))
                                .foregroundStyle(Asset.headerTitleTextColor.swiftUIColor)
                                .lineLimit(2)
                                .padding(.horizontal, 18.0)
                            
                            if let cell = section.items.first,
                               case .playlist(let playlist) = cell.typeOfCell {
                                let isAltCardStyle = (sectionIndex % 2 == 1)
                                PlaylistView(playlist: playlist, isAltCardStyle: isAltCardStyle)
                            }
                        }
                        .padding(.top, sectionIndex == 0 ? 0.0 : 32.0)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        
        private struct ChannelPagerView: View {
            @Environment(YouTubeViewModel.self) private var viewModel
            @State private var currentPage = 0
            let channels: [Channel]
            private let imageHeight: CGFloat = 199.0
            private let dotsReserve: CGFloat = 44.0
            
            var body: some View {
                TabView(selection: $currentPage) {
                    ForEach(Array(channels.enumerated()), id: \.element.id) { index, channel in
                        VStack(spacing: 0.0) {
                            ZStack(alignment: .bottomLeading) {
                                AsyncImage(url: URL(string: channel.brandingSettings.image.bannerExternalUrl)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Image(Asset.placeholder.name)
                                        .resizable()
                                        .scaledToFill()
                                }
                                .frame(height: imageHeight)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(6.0)
                                
                                VStack(alignment: .leading, spacing: 4.0) {
                                    Text(channel.brandingSettings.channel.title)
                                        .font(.custom(FontFamily.SFProText.semibold, size: 16.0))
                                        .foregroundColor(Asset.channelTitleTextColor.swiftUIColor)
                                    
                                    Text("\(channel.statistics.subscriberCount) \(L10n.subscribers)")
                                        .font(.custom(FontFamily.SFProText.regular, size: 10.0))
                                        .foregroundColor(Asset.channelSubtitleTextColor.swiftUIColor)
                                    
                                }
                                .padding(.leading, 10.0)
                                .padding(.bottom, 14.0)
                            }
                            .padding(.horizontal, 18.0)
                            
                            Spacer().frame(height: dotsReserve)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .frame(height: imageHeight + dotsReserve)
                .onChange(of: channels.count) { _, _ in
                    currentPage = min(currentPage, max(channels.count - 1, 0))
                    viewModel.updateData(for: currentPage)
                }
                .onChange(of: viewModel.pagesCounter) { _, _ in
                    guard !channels.isEmpty else { return }
                    withAnimation(.easeInOut) {
                        currentPage = (currentPage + 1) % channels.count
                    }
                    viewModel.updateData(for: currentPage)
                }
                .onChange(of: currentPage) { _, newValue in
                    viewModel.updateData(for: newValue)
                }
                .onAppear {
                    viewModel.updateData(for: currentPage)
                    viewModel.startTimer()
                }
                .onDisappear {
                    viewModel.stopTimer()
                }
            }
            
        }
        
        struct PlaylistView: View {
            let playlist: Playlist
            let isAltCardStyle: Bool
            
            var body: some View {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10.0) {
                        let items = playlist.playlistItems ?? []
                        
                        ForEach(Array(items.enumerated()), id: \.element.id) { idx, item in
                            if isAltCardStyle {
                                VideoCardAlt(item: item)
                            } else {
                                VideoCard(item: item)
                            }
                        }
                    }
                    .padding(.leading, 18.0)
                }
            }
        }
        
        struct VideoCard: View {
            let item: PlaylistItem
            
            var body: some View {
                VStack(spacing: 9.0) {
                    AsyncImage(url: URL(string: item.snippet.thumbnails?.high?.url ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(Asset.placeholder.name)
                            .resizable()
                            .scaledToFill()
                    }                    .frame(width: 160.0, height: 70.0)
                    .cornerRadius(6.0)
                    
                    VStack(alignment: .leading, spacing: 4.0) {
                        Text(item.snippet.title)
                            .font(.custom(FontFamily.SFProText.medium, size: 17.0))
                            .foregroundColor(Asset.headerTitleTextColor.swiftUIColor)
                            .lineLimit(1)
                            .foregroundColor(.white)
                        
                        if let views = item.snippet.viewCount {
                            Text("\(views) \(L10n.subscribers)")
                                .font(.custom(FontFamily.SFProText.medium, size: 12.0))
                                .foregroundColor(Asset.headerTitleTextColor.swiftUIColor)
                                .opacity(0.42)
                        }
                    }
                    .frame(width: 160.0)
                }
            }
        }
        
        struct VideoCardAlt: View {
            let item: PlaylistItem
            
            var body: some View {
                VStack(alignment: .leading, spacing: 8) {
                    AsyncImage(url: URL(string: item.snippet.thumbnails?.high?.url ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(Asset.placeholder.name)
                            .resizable()
                            .scaledToFill()
                    }
                    .frame(width: 135.0, height: 135.0)
                    .cornerRadius(6.0)
                    
                    VStack(alignment: .leading, spacing: 4.0) {
                        Text(item.snippet.title)
                            .font(.custom(FontFamily.SFProText.medium, size: 17.0))
                            .foregroundColor(Asset.headerTitleTextColor.swiftUIColor)
                            .lineLimit(1)
                            .frame(width: 135, alignment: .leading)
                        
                        if let views = item.snippet.viewCount {
                            Text("\(views) \(L10n.subscribers)")
                                .font(.custom(FontFamily.SFProText.medium, size: 12.0))
                                .foregroundColor(Asset.headerTitleTextColor.swiftUIColor)
                                .opacity(0.42)
                        }
                    }
                    .frame(width: 135.0)
                }
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
