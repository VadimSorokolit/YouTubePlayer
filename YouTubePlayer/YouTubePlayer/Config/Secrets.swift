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
            forResource: L10n.apiKeyFileName,
            withExtension: L10n.apiKeyFileExtension
        ) else {
            let errorMessage = L10n.apiKeyFileName + L10n.dot + L10n.apiKeyFileExtension + L10n.fileNotFound
            print(errorMessage)
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(AppConfig.self, from: data)
            return config.apiKey
        } catch {
            let errorMessage = String(
                format: L10n.apiKeyLoadFailed,
                error.localizedDescription
            )
            print(errorMessage)
            return nil
        }
    }()
}
