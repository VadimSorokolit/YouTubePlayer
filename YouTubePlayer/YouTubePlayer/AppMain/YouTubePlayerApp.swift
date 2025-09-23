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
                if self.isShownHomeView {
                    HomeView()
                } else {
                    LaunchView()
                }
            }
            .environment(self.homeViewModel)
            .environment(self.playerViewModel)
            .environmentAlert($appAlert)
            .modifier(LoadViewModifier(isShownHomeView: self.$isShownHomeView, homeViewModel: self.homeViewModel, playerViewModel: self.playerViewModel))
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
                .onChange(of: self.homeViewModel.isLoading) { oldValue, newValue in
                    if oldValue == true, newValue == false, self.homeViewModel.errorMessage == nil, self.isShownHomeView == false {
                        self.isShownHomeView = true
                    }
                }
                .onChange(of: self.homeViewModel.errorMessage) { oldValue, newValue in
                    if oldValue != newValue {
                        self.appAlert.error(
                            Text(self.homeViewModel.errorMessage ?? L10n.errorMessage),
                            onConfirm:  {
                                self.homeViewModel.errorMessage = nil
                            }
                        )
                    }
                }
                .onChange(of: self.playerViewModel.errorMessage) { oldValue, newValue in
                    if oldValue != newValue {
                        self.appAlert.error(
                            Text(self.playerViewModel.errorMessage ?? L10n.errorMessage),
                            onConfirm: {
                                self.homeViewModel.errorMessage = nil
                            }
                        )
                    }
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
