//
//  YouTubePlayerApp.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 25.08.2025.
//
    
import SwiftUI

@main
struct YouTubePlayerApp: App {
    
    // MARK: - Properties. Private
    
    @State private var isShowingLaunchView: Bool = false
    @State private var viewModel = YouTubeViewModel()
    
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
        }
        .environment(self.viewModel)
    }
    
    // MARK: - Modifiers
    
    struct LoadViewModifier: ViewModifier {
        @Binding var isShowingLaunchView: Bool
        @Binding var viewModel: YouTubeViewModel
        
        func body(content: Content) -> some View {
            content
                .onAppear {
                    self.isShowingLaunchView = true
                }
                .onChange(of: viewModel.isLoading) {
                    if !self.viewModel.isLoading {
                        self.isShowingLaunchView = false
                    }
                }
                .task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    self.viewModel.getChannels()
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
