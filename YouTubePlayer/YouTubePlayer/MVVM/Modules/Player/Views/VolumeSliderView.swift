//
//  VolumeSliderView.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 11.09.2025.
//
    
import SwiftUI
import MediaPlayer

struct VolumeSliderView: UIViewRepresentable {
    
    // MARK: - Objects. Public
    
    struct Style {
        var minTrack: UIColor = .white
        var maxTrack: UIColor = UIColor.white.withAlphaComponent(0.35)
        var thumb: Thumb = .circle(diameter: 16.0, color: .white)
        var hideRouteButton: Bool = true
        var height: CGFloat = 32.0
    }
    
    enum Thumb {
        case circle(diameter: CGFloat, color: UIColor)
        case bar(width: CGFloat, height: CGFloat, color: UIColor)
        case hidden
    }
    
    // MARK: - Properties. Public
    
    var style: Style = .init()
    
    // MARK: - Methods. Public
    
    func makeUIView(context: Context) -> MPVolumeView {
        let view = MPVolumeView(frame: .zero)
        view.showsVolumeSlider = true
        applyStyle(on: view)
        
        return view
    }
    
    func updateUIView(_ uiView: MPVolumeView, context: Context) {
        applyStyle(on: uiView)
    }
    
    // MARK: - Methods. Private
    
    private func applyStyle(on volumeView: MPVolumeView) {
        if style.hideRouteButton {
            volumeView.subviews
                .compactMap { $0 as? UIButton }
                .forEach { $0.isHidden = true }
        }
        if let slider = volumeView.subviews.compactMap({ $0 as? UISlider }).first {
            slider.minimumTrackTintColor = style.minTrack
            slider.maximumTrackTintColor = style.maxTrack
            
            switch style.thumb {
                case .circle(let diameter, let color):
                    slider.setThumbImage(makeCircleThumb(diameter: diameter, color: color), for: .normal)
                    slider.setThumbImage(makeCircleThumb(diameter: diameter, color: color), for: .highlighted)
                    
                case .bar(let width, let height, let color):
                    slider.setThumbImage(makeBarThumb(width: width, height: height, color: color), for: .normal)
                    slider.setThumbImage(makeBarThumb(width: width, height: height, color: color), for: .highlighted)
                    
                case .hidden:
                    slider.setThumbImage(UIImage(), for: .normal)
                    slider.setThumbImage(UIImage(), for: .highlighted)
            }
            slider.bounds.size.height = max(slider.bounds.height, style.height)
        }
    }
    
    private func makeCircleThumb(diameter: CGFloat, color: UIColor) -> UIImage {
        let size = CGSize(width: diameter, height: diameter)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { ctx in
            let rectangle = CGRect(origin: .zero, size: size)
            color.setFill()
            UIBezierPath(ovalIn: rectangle)
                .fill()
        }
    }
    
    private func makeBarThumb(width: CGFloat, height: CGFloat, color: UIColor) -> UIImage {
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { _ in
            color.setFill()
            UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: width / 2.0)
                .fill()
        }
    }
}
