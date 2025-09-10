//
//  View+cornerRadius.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 10.09.2025.
//
    
import SwiftUI

extension View {
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedShape(radius: radius, corners: corners))
    }
    
}

struct RoundedShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
