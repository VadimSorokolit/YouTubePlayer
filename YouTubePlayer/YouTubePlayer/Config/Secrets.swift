//
//  Secrets.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 27.08.2025.
//

import Foundation

enum Secrets {
    static let apiKey: String? = {
        guard let url = Bundle.main.url(
            forResource: GlobalConstants.apiKeyFileName,
            withExtension: GlobalConstants.apiKeyFileExtension
        ) else {
            print("ApiKey.json not found")
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(AppConfig.self, from: data)
            return config.apiKey
        } catch {
            print("Failed to load API key: \(error)")
            return nil
        }
    }()
}
