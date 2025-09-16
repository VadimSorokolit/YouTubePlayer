//
//  LaunchView.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 08.09.2025.
//
    
import SwiftUI

struct LaunchView: View {
    
    var body: some View {
        ZStack {
            Asset.launchBackgroundColor.swiftUIColor
                .ignoresSafeArea()
            Image(Asset.launchIcon.name)
                .resizable()
                .scaledToFit()
                .frame(width: 150.0, height: 50.0)
        }
    }
    
}
