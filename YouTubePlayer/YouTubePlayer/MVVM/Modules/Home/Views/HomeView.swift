//
//  HomeView.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 25.08.2025.
//

import SwiftUI

struct HomeView: View {
    
    // MARK: - Properties. Private
    
    private let topOffSet: CGFloat = 50.0
    
    // MARK: - Main body
    
    var body: some View {
        ZStack {
            HomeBodyView(topOffSet: topOffSet)
            
            PlayerView(topOffset: topOffSet)
        }
    }
    
    private struct HomeBodyView: View {
        let topOffSet: CGFloat
        
        var body: some View {
            VStack(spacing: 32.0) {
                HeaderView(topOffSet: topOffSet)
                
                ContentView()
            }
            .background(
                Asset.customBackground.swiftUIColor
                    .ignoresSafeArea()
            )
        }
        
        private struct HeaderView: View {
            @Environment(HomeViewModel.self) private var viewModel
            let topOffSet: CGFloat
            
            var body: some View {
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: topOffSet)
                        .ignoresSafeArea(edges: .top)
                    
                    Text(viewModel.isPlayerOpen ? L10n.playerScreenTitle : L10n.homeScreenTitle)
                        .foregroundColor(viewModel.isPlayerOpen ? Asset.playerHeaderTitleTextColor.swiftUIColor : Asset.homeHeaderTitleTextColor.swiftUIColor)
                        .font(.custom(FontFamily.SFProDisplay.bold, size: 34.0))
                        .lineLimit(1)
                        .padding(.leading, 24.0)
                }
            }
        }
        
        private struct ContentView: View {
            @Environment(HomeViewModel.self) private var viewModel
            
            var body: some View {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0.0) {
                        if let firstSection = viewModel.sections.first,
                           case .pageControl(let channels) = firstSection.items.first?.typeOfCell {
                            ChannelPagerView(channels: channels, onChannelTap: { channel in
                                viewModel.selectChannel(channel)
                            })
                            .padding(.bottom, 4.0)
                        }
                        
                        ForEach(Array(viewModel.sections.dropFirst().enumerated()), id: \.element.id) { sectionIndex, section in
                            VStack(alignment: .leading, spacing: sectionIndex % 2 == 0 ? 20.0 : 13.0) {
                                Text(section.title)
                                    .font(.custom(FontFamily.SFProDisplay.bold, size: 23.0))
                                    .foregroundStyle(Asset.homeHeaderTitleTextColor.swiftUIColor)
                                    .lineLimit(2)
                                    .padding(.horizontal, 18.0)
                                
                                if let cell = section.items.first,
                                   case .playlist(let playlist) = cell.typeOfCell {
                                    let isAltCardStyle = (sectionIndex % 2 == 1)
                                    let offset = viewModel.sections
                                        .dropFirst()
                                        .prefix(sectionIndex)
                                        .reduce(0) { itemCount, section in
                                            if case .playlist(let playlist) = section.items.first?.typeOfCell {
                                                return itemCount + (playlist.playlistItems?.count ?? 0)
                                            }
                                            return itemCount
                                        }
                                    let allItems: [PlaylistItem] = viewModel.sections
                                        .dropFirst()
                                        .compactMap { section -> Playlist? in
                                            if case .playlist(let playlist) = section.items.first?.typeOfCell { return playlist }
                                            return nil
                                        }
                                        .flatMap { $0.playlistItems ?? [] }
                                    
                                    PlaylistView(
                                        playlist: playlist,
                                        isAltCardStyle: isAltCardStyle,
                                        onItemTap: { index in
                                            let globalIndex = offset + index
                                            viewModel.openPlayer(items: allItems, startAt: globalIndex)
                                        
                                        }
                                    )
                                }
                            }
                            .padding(.top, sectionIndex == 0 ? 0.0 : 32.0)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            
            private struct ChannelPagerView: View {
                @Environment(HomeViewModel.self) private var viewModel
                @State private var currentPage = 0
                let channels: [Channel]
                private let imageHeight: CGFloat = 199.0
                private let dotsReserve: CGFloat = 44.0
                var onChannelTap: (Channel) -> Void
                
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
                                    .onTapGesture {
                                        onChannelTap(channel)
                                    }
                                    
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
                    .onChange(of: viewModel.isPlayerOpen) {
                        if viewModel.isPlayerOpen {
                            viewModel.stopTimer()
                        } else {
                            viewModel.startTimer()
                        }
                    }
                    .onChange(of: currentPage) { _, newPage in
                        viewModel.updateData(for: currentPage)
                    }
                    .onChange(of: viewModel.pagesCounter) { _, _ in
                        guard !channels.isEmpty else {
                            return
                        }
                        currentPage = (currentPage + 1) % channels.count
                    }
                    .onAppear {
                        viewModel.startTimer()
                    }
                }
                
            }
            
            struct PlaylistView: View {
                let playlist: Playlist
                let isAltCardStyle: Bool
                let onItemTap: (Int) -> Void
                
                var body: some View {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(alignment: .top, spacing: 10.0) {
                            let items = playlist.playlistItems ?? []
                            
                            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                                Group {
                                    if isAltCardStyle {
                                        VideoCardAlt(item: item)
                                    } else {
                                        VideoCard(item: item)
                                    }
                                }
                                .onTapGesture {
                                    onItemTap(index)
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
                        if let urlString = item.snippet.thumbnails?.high?.url,
                           let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } else if phase.error != nil {
                                    Image(Asset.placeholder.name)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    ProgressView()
                                }
                            }
                            .frame(width: 160.0, height: 70.0)
                            .cornerRadius(6.0)
                        } else {
                            Image(Asset.placeholder.name)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 160.0, height: 70.0)
                                .cornerRadius(6.0)
                        }
                        
                        VStack(alignment: .leading, spacing: 4.0) {
                            Text(item.snippet.title)
                                .font(.custom(FontFamily.SFProText.medium, size: 17.0))
                                .foregroundColor(Asset.homeHeaderTitleTextColor.swiftUIColor)
                                .lineLimit(1)
                                .foregroundColor(.white)
                            
                            if let views = item.snippet.viewCount {
                                Text("\(views) \(L10n.subscribers)")
                                    .font(.custom(FontFamily.SFProText.medium, size: 12.0))
                                    .foregroundColor(Asset.homeHeaderTitleTextColor.swiftUIColor)
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
                        if let urlString = item.snippet.thumbnails?.high?.url,
                           let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } else if phase.error != nil {
                                    Image(Asset.placeholder.name)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    ProgressView()
                                }
                            }
                            .frame(width: 135.0, height: 135.0)
                            .cornerRadius(6.0)
                        } else {
                            Image(Asset.placeholder.name)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 135.0, height: 135.0)
                                .cornerRadius(6.0)
                        }

                        VStack(alignment: .leading, spacing: 4.0) {
                            Text(item.snippet.title)
                                .font(.custom(FontFamily.SFProText.medium, size: 17.0))
                                .foregroundColor(Asset.homeHeaderTitleTextColor.swiftUIColor)
                                .lineLimit(1)
                                .frame(width: 135, alignment: .leading)
                            
                            if let views = item.snippet.viewCount {
                                Text("\(views) \(L10n.subscribers)")
                                    .font(.custom(FontFamily.SFProText.medium, size: 12.0))
                                    .foregroundColor(Asset.homeHeaderTitleTextColor.swiftUIColor)
                                    .opacity(0.42)
                            }
                        }
                        .frame(width: 135.0)
                    }
                }
                
            }
        }
    }
}
