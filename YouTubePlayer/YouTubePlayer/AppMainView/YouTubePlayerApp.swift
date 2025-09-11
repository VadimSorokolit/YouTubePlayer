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
    
    @State private var isShowingLaunchView: Bool = false
    @State private var viewModel = HomeViewModel()
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
                if self.isShowingLaunchView {
                    LaunchView()
                } else {
                    HomeView()
                }
            }
            .modifier(LoadViewModifier(isShowingLaunchView: $isShowingLaunchView, viewModel: $viewModel))
            .environmentAlert($appAlert)
        }
        .environment(self.viewModel)
    }
    
    // MARK: - Modifiers
    
    struct LoadViewModifier: ViewModifier {
        @Environment(\.appAlert) private var appAlert
        @Binding var isShowingLaunchView: Bool
        @Binding var viewModel: HomeViewModel
        
        func body(content: Content) -> some View {
            content
                .onAppear {
                    self.isShowingLaunchView = true
                }
                .onChange(of: viewModel.isLoading) {
                    if self.viewModel.isLoading == false {
                        self.isShowingLaunchView = false
                    }
                }
                .task {
                    do {
                        try await Task.sleep(nanoseconds: 2_000_000_000)
                        try await self.viewModel.getChannels()
                    } catch {
                        self.viewModel.errorMessage = error.localizedDescription
                    }
                }
                .onChange(of: viewModel.errorMessage) {
                    self.appAlert.error(Text(self.viewModel.errorMessage ?? ""))
                }
                .overlay {
                    if self.viewModel.isLoading {
                        VStack(spacing: .zero) {
                            SpinnerView(isLoading: self.viewModel.isLoading)
                            
                            Spacer()
                        }
                        .ignoresSafeArea(edges: .top)
                    }
                }
        }
    }
}
