// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// json
  internal static let apiKeyFileExtension = L10n.tr("Localizable", "apiKeyFileExtension", fallback: "json")
  /// Localizable.strings
  ///   YouTubePlayer
  /// 
  ///   Created by Vadim  on 27.08.2025.
  internal static let apiKeyFileName = L10n.tr("Localizable", "apiKeyFileName", fallback: "ApiKey")
  /// https://www.googleapis.com
  internal static let baseURL = L10n.tr("Localizable", "baseURL", fallback: "https://www.googleapis.com")
  /// UCiMhD4jzUqG-IgPzUmmytRQ
  internal static let channelId1 = L10n.tr("Localizable", "channelId1", fallback: "UCiMhD4jzUqG-IgPzUmmytRQ")
  /// UC5OrDvL9DscpcAstz7JnQGA
  internal static let channelId2 = L10n.tr("Localizable", "channelId2", fallback: "UC5OrDvL9DscpcAstz7JnQGA")
  /// UCmvtGezn6LpfUN1QW0aEaTg
  internal static let channelId3 = L10n.tr("Localizable", "channelId3", fallback: "UCmvtGezn6LpfUN1QW0aEaTg")
  /// UC7fzrpTArAqDHuB3Hbmd_CQ
  internal static let channelId4 = L10n.tr("Localizable", "channelId4", fallback: "UC7fzrpTArAqDHuB3Hbmd_CQ")
  /// youtube/v3/channels
  internal static let channelsPath = L10n.tr("Localizable", "channelsPath", fallback: "youtube/v3/channels")
  /// https://www.google.com
  internal static let defaultURL = L10n.tr("Localizable", "defaultURL", fallback: "https://www.google.com")
  /// YouTube Player
  internal static let homeScreenTitle = L10n.tr("Localizable", "homeScreenTitle", fallback: "YouTube Player")
  /// Missing API Key. Add ApiKey.json to bundle and unlock git-crypt
  internal static let invalidAPIkeyErrorMessage = L10n.tr("Localizable", "invalidAPIkeyErrorMessage", fallback: "Missing API Key. Add ApiKey.json to bundle and unlock git-crypt")
  /// URL is invalid
  internal static let invalidURLErrorMessage = L10n.tr("Localizable", "invalidURLErrorMessage", fallback: "URL is invalid")
  /// channelId
  internal static let parameterChannelId = L10n.tr("Localizable", "parameterChannelId", fallback: "channelId")
  /// id
  internal static let parameterId = L10n.tr("Localizable", "parameterId", fallback: "id")
  /// key
  internal static let parameterKey = L10n.tr("Localizable", "parameterKey", fallback: "key")
  /// maxResults
  internal static let parameterMaxResults = L10n.tr("Localizable", "parameterMaxResults", fallback: "maxResults")
  /// part
  internal static let parameterPart = L10n.tr("Localizable", "parameterPart", fallback: "part")
  /// playlistId
  internal static let parameterPlaylistId = L10n.tr("Localizable", "parameterPlaylistId", fallback: "playlistId")
  /// My Music
  internal static let playerScreenTitle = L10n.tr("Localizable", "playerScreenTitle", fallback: "My Music")
  /// youtube/v3/playlistItems
  internal static let playlistItemsPath = L10n.tr("Localizable", "playlistItemsPath", fallback: "youtube/v3/playlistItems")
  /// youtube/v3/playlists
  internal static let playlistsPath = L10n.tr("Localizable", "playlistsPath", fallback: "youtube/v3/playlists")
  /// subscribers
  internal static let subscribers = L10n.tr("Localizable", "subscribers", fallback: "subscribers")
  /// brandingSettings
  internal static let valueBrandingSettings = L10n.tr("Localizable", "valueBrandingSettings", fallback: "brandingSettings")
  /// snippet
  internal static let valueSnippet = L10n.tr("Localizable", "valueSnippet", fallback: "snippet")
  /// statistics
  internal static let valueStatistics = L10n.tr("Localizable", "valueStatistics", fallback: "statistics")
  /// youtube/v3/videos
  internal static let videosPath = L10n.tr("Localizable", "videosPath", fallback: "youtube/v3/videos")
  /// views
  internal static let views = L10n.tr("Localizable", "views", fallback: "views")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
