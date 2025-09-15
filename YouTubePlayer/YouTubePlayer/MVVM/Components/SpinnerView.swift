//
//  SpinnerView.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 08.09.2025.
//

import SwiftUI

struct SpinnerView: View {
    let isLoading: Bool
    var offsetY: CGFloat = 80.0
    
    var body: some View {
        if isLoading {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
                .offset(y: offsetY)
        }
    }
    
}
