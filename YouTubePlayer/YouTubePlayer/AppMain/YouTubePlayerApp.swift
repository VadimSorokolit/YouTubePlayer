//
//  YouTubePlayerApp.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 25.08.2025.
//
    
import SwiftUI
import CustomAlerts

@main
struct YouTubePlayerApp: App {
    
    // MARK: - Properties. Private
    
    @State private var isShownHomeView: Bool = false
    @State private var homeViewModel = HomeViewModel()
    @State private var playerViewModel = PlayerViewModel()
    @State private var appAlert: AlertNotice?
    
    // MARK: - Initializer
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Asset.pagerActiveDotColor.swiftUIColor)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Asset.pagerInactiveDotColor.swiftUIColor)
    }
    
    // MARK: - Root Scene
    
    var body: some Scene {
        WindowGroup {
            Group {
                if self.isShownHomeView == false {
                    LaunchView()
                } else {
                    HomeView()
                }
            }
            .environment(self.homeViewModel)
            .environment(self.playerViewModel)
            .environmentAlert($appAlert)
            .modifier(LoadViewModifier(isShownHomeView: $isShownHomeView, homeViewModel: homeViewModel, playerViewModel: playerViewModel))
        }
    }
    
    // MARK: - Modifiers
    
    struct LoadViewModifier: ViewModifier {
        @Environment(\.appAlert) private var appAlert
        @Binding var isShownHomeView: Bool
        let homeViewModel: HomeViewModel
        let playerViewModel: PlayerViewModel
        
        func body(content: Content) -> some View {
            content
                .onChange(of: homeViewModel.isLoading) {
                    if homeViewModel.isLoading == false, homeViewModel.errorMessage == nil {
                        isShownHomeView = true
                    }
                }
                .onChange(of: homeViewModel.errorMessage) {
                    self.appAlert.error(Text(self.homeViewModel.errorMessage ?? ""))
                }
                .onChange(of: playerViewModel.errorMessage) {
                    self.appAlert.error(Text(self.playerViewModel.errorMessage ?? ""))
                }
                .task {
                    do {
                        try await Task.sleep(nanoseconds: 2_000_000_000)
                        try await self.homeViewModel.getChannels()
                    } catch {
                        self.homeViewModel.errorMessage = error.localizedDescription
                    }
                }
                .overlay {
                    if self.homeViewModel.isLoading {
                        VStack(spacing: .zero) {
                            SpinnerView(isLoading: self.homeViewModel.isLoading)
                            
                            Spacer()
                        }
                        .ignoresSafeArea(edges: .top)
                    }
                }
        }
    }
}
