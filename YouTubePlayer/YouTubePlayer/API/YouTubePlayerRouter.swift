//
//  YouTubePlayerRouter.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 27.08.2025.
//

import Foundation
import Moya

private struct Constants {
    static var apiKey: String {
        guard let key = Secrets.apiKey else {
            fatalError(L10n.invalidAPIkeyErrorMessage)
        }
        return key
    }
}

enum YouTubePlayerRouter {
    case getChannels(id: String)
    case getPlaylists(channelId: String, max: Int)
    case getPlaylistItems(playlistId: String, max: Int)
    case getVideos(videoId: String)
}

// MARK: - TargetType Protocol

extension YouTubePlayerRouter: TargetType {
    
    var baseURL: URL {
        guard let url = URL(string: L10n.baseURL) ?? URL(string: L10n.defaultURL) else {
            fatalError(L10n.invalidURLErrorMessage)
        }
        return url
    }
    
    var path: String {
        switch self {
            case .getChannels:
                return L10n.channelsPath
            case .getPlaylists:
                return L10n.playlistsPath
            case .getPlaylistItems:
                return L10n.playlistItemsPath
            case .getVideos:
                return L10n.videosPath
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var parameters: [String : String] {
        switch self {
            case let .getChannels(id):
                return [
                    L10n.parameterPart: L10n.valueBrandingSettings,
                    L10n.parameterKey: Constants.apiKey,
                    L10n.parameterId: "\(id)",
                ]
            case let .getPlaylists(id, max):
                return [
                    L10n.parameterPart: L10n.valueSnippet,
                    L10n.parameterKey: Constants.apiKey,
                    L10n.parameterChannelId: "\(id)",
                    L10n.parameterMaxResults: "\(max)"
                ]
            case let .getPlaylistItems(id, max):
                return [
                    L10n.parameterPart: L10n.valueSnippet,
                    L10n.parameterKey: Constants.apiKey,
                    L10n.parameterPlaylistId: "\(id)",
                    L10n.parameterMaxResults: "\(max)"
                ]
            case let .getVideos(id):
                return [
                    L10n.parameterPart: L10n.valueStatistics,
                    L10n.parameterKey: Constants.apiKey,
                    L10n.parameterId: "\(id)",
                ]
        }
    }
    
    var task: Task {
        switch self {
            case .getChannels, .getPlaylists, .getPlaylistItems, .getVideos:
                return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
