//
//  SpinnerView.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 08.09.2025.
//

import SwiftUI

struct SpinnerView: View {
    @State private var topInset: CGFloat = 0.0
    let isLoading: Bool
    
    var body: some View {
        GeometryReader { geo in
            HStack {
                Spacer()
                
                if isLoading {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .frame(width: 40.0, height: 40.0)
                        
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    }
                }
            }
            .padding(.trailing, 20.0)
            .padding(.top, topInset + 30.0)
            .padding(.bottom, 8.0)
            .background(.clear)
            .onAppear {
                topInset = geo.safeAreaInsets.top
            }
        }
        .frame(height: (40.0 + topInset))
    }
    
}
