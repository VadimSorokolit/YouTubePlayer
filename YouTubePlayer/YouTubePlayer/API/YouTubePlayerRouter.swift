//
//  YouTubePlayerRouter.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 27.08.2025.
//

import Foundation
import Moya

private struct Constants {
    struct API {
        static let url: URL? = URL(string: "https://www.googleapis.com")
        static let channelsPath: String = "youtube/v3/channels"
        static let playlistsPath: String = "youtube/v3//playlists"
        static let playlistItemsPath: String = "youtube/v3//playlistItems"
        static let videosPath: String = "youtube/v3//videos"
    }
    
    struct Parameters {
        static let part: String = "part"
        static let key: String = "key"
        static let id: String = "id"
        static let playlistId: String = "playlistId"
        static let channelId: String = "channelId"
        static let maxResults: String = "maxResults"
    }
    
    struct Values {
        static let brandingSettings: String = "brandingSettings"
        static let snippet: String = "snippet"
        static let statistics: String = "statistics"
    }
    
    static let defaultURL: URL? = URL(string: "https://www.google.com")
    static let fatalErrorMessage: String = "URL is invalid"
    static var apiKey: String {
        guard let key = Secrets.apiKey else {
            fatalError("Missing API Key. Add ApiKey.json to bundle (and unlock git-crypt)")
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
        guard let url = Constants.API.url ?? Constants.defaultURL else {
            fatalError(Constants.fatalErrorMessage)
        }
        return url
    }
    
    var path: String {
        switch self {
            case .getChannels:
                return Constants.API.channelsPath
            case .getPlaylists:
                return Constants.API.playlistsPath
            case .getPlaylistItems:
                return Constants.API.playlistItemsPath
            case .getVideos:
                return Constants.API.videosPath
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var params: [String : String] {
        switch self {
            case let .getChannels(id):
                return [
                    Constants.Parameters.part: Constants.Values.brandingSettings,
                    Constants.Parameters.key: Constants.apiKey,
                    Constants.Parameters.id: "\(id)",
                ]
            case let .getPlaylists(id, max):
                return [
                    Constants.Parameters.part: Constants.Values.snippet,
                    Constants.Parameters.key: Constants.apiKey,
                    Constants.Parameters.channelId: "\(id)",
                    Constants.Parameters.maxResults: "\(max)"
                ]
            case let .getPlaylistItems(id, max):
                return [
                    Constants.Parameters.part: Constants.Values.snippet,
                    Constants.Parameters.key: Constants.apiKey,
                    Constants.Parameters.playlistId: "\(id)",
                    Constants.Parameters.maxResults: "\(max)"
                ]
            case let .getVideos(id):
                return [
                    Constants.Parameters.part: Constants.Values.statistics,
                    Constants.Parameters.key: Constants.apiKey,
                    Constants.Parameters.id: "\(id)",
                ]
        }
    }
    
    var task: Task {
        switch self {
            case .getChannels, .getPlaylists, .getPlaylistItems, .getVideos:
                return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
