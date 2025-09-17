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
    
    @State private var isShownLaunchView: Bool = false
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
                if self.isShownLaunchView == false {
                    LaunchView()
                } else {
                    HomeView()
                }
            }
            .environment(self.homeViewModel)
            .environment(self.playerViewModel)
            .environmentAlert($appAlert)
            .modifier(LoadViewModifier(isShownLaunchView: $isShownLaunchView, homeViewModel: $homeViewModel))
        }
    }
    
    // MARK: - Modifiers
    
    struct LoadViewModifier: ViewModifier {
        @Environment(\.appAlert) private var appAlert
        @Binding var isShownLaunchView: Bool
        @Binding var homeViewModel: HomeViewModel
        
        func body(content: Content) -> some View {
            content
                .onChange(of: homeViewModel.isLoading) {
                    if self.homeViewModel.isLoading == false {
                        self.isShownLaunchView = true
                    }
                }
                .onChange(of: homeViewModel.errorMessage) {
                    self.appAlert.error(Text(self.homeViewModel.errorMessage ?? ""))
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
