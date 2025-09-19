//
//  NetworkServiceTests.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 25.08.2025.
//
    
import Testing
@testable import YouTubePlayer

struct NetworkServiceTests {
    
    @Test func testGetChannels() async throws {
        let testChannelId: String = "testMockChannelId"
        let testSubscriberCount: String = "test100000"
        let testBannerUrl: String = "testHttps://example.com/banner.png"
        let testTitle: String = "testMockTitle"
        
        let testMockService: MockNetworkService = MockNetworkService()
        testMockService.channelsResult = .success([
            Channel(
                id: testChannelId,
                statistics: Channel.Statistics(subscriberCount: testSubscriberCount),
                brandingSettings: Channel.Settings(channel: Channel.Settings.Setting(title: testTitle), image: Channel.Settings.Image(bannerExternalUrl: testBannerUrl))
            )
        ])
        
        let result = try await testMockService.getChannels(by: testChannelId)
        
        #expect(result.count == 1)
        #expect(result.first?.id == testChannelId)
    }
    
    @Test func testGetPlaylists() async throws {
        let testFirstPlaylistId: String = "testFirstId"
        let testSecondPlaylistId: String = "testSecondId"
        let testFirstPlaylistTitle: String = "testFirstPlaylistTitle"
        let testSecondPlaylistTitle: String = "testSecondPlaylistTitle"
        let testChannelId: String = "testMockChannelId"
        let testSubscriberCount: String = "test100000"
        let testBannerUrl: String = "testHttps://example.com/banner.png"
        let testTitle: String = "testMockTitle"
        
        let testMockService = MockNetworkService()
        
        let testFirstPlaylist = Playlist(id: testFirstPlaylistId, snippet: Playlist.Snippet(title: testFirstPlaylistTitle))
        let testSecondPlaylist = Playlist(id: testSecondPlaylistId, snippet: Playlist.Snippet(title: testSecondPlaylistTitle))
        
        let testChannel = Channel(id: testChannelId, statistics: Channel.Statistics(subscriberCount: testSubscriberCount), brandingSettings: Channel.Settings(channel: Channel.Settings.Setting(title: testTitle), image: Channel.Settings.Image(bannerExternalUrl: testBannerUrl)), playlists: [testFirstPlaylist, testSecondPlaylist])
        
        testMockService.playlistsResult = .success([
            testFirstPlaylist, testSecondPlaylist
        ])
        
        let result = try await testMockService.getPlaylists(by: testChannel.id, max: 2)
        
        #expect(result.count == 2)
        #expect(result[0].id == testFirstPlaylistId)
        #expect(result[0].snippet.title == testFirstPlaylistTitle)
        #expect(result[1].id == testSecondPlaylistId)
        #expect(result[1].snippet.title == testSecondPlaylistTitle)
    }

    @Test func testGetPlaylistItems() async throws {
        let testPlaylistId: String = "testPlaylistId"
        let testPlaylistTitle: String = "testPlaylistTitle"
        let testFirstPlaylistItemId: String = "testFirstPlaylistItemId"
        let testSecondPlaylistItemId: String = "testSecondPlaylistItemId"
        let testFirstResourceVideoId: String = "testResourceIdVideoId"
        let testSecondResourceVideoId: String = "testSecondResourceIdVideoId"
        let testFirstResouceViewCount: String = "test1000"
        let testSecondResouceViewCount: String = "test2000"
        let testFirstSnippetTitle: String = "testFirstSnippetTitle"
        let testSecondSnippetTitle: String = "testSecondSnippetTitle"
        
        let mockService = MockNetworkService()
        
        let testFirstItem = PlaylistItem(id: testFirstPlaylistItemId, snippet: PlaylistItem.Snippet(title: testFirstSnippetTitle, resourceId: PlaylistItem.Snippet.Resource(videoId: testFirstResourceVideoId), viewCount: testFirstResouceViewCount, thumbnails: nil))
        
        let testSecondItem = PlaylistItem(id: testSecondPlaylistItemId, snippet: PlaylistItem.Snippet(title: testSecondSnippetTitle, resourceId: PlaylistItem.Snippet.Resource(videoId: testSecondResourceVideoId), viewCount: testSecondResouceViewCount, thumbnails: nil))
        
        let testPlaylist = Playlist(id: testPlaylistId, snippet: Playlist.Snippet(title: testPlaylistTitle), playlistItems: [testFirstItem, testSecondItem])
        
        #expect(testPlaylist.playlistItems?.count == 2)
        #expect(testPlaylist.playlistItems?[0].id == testFirstPlaylistItemId)
        #expect(testPlaylist.playlistItems?[1].id == testSecondPlaylistItemId)
        
        mockService.playlistItemsResult = .success([
            testFirstItem,
            testSecondItem
        ])

        let result = try await mockService.getPlaylistItems(playlistId: testPlaylistId, max: 2)
        
        #expect(result.count == 2)

        #expect(result[0].id == testFirstPlaylistItemId)
        #expect(result[0].snippet.title == testFirstSnippetTitle)
        #expect(result[0].snippet.resourceId.videoId == testFirstResourceVideoId)
        #expect(result[0].snippet.viewCount == testFirstResouceViewCount)

        #expect(result[1].id == testSecondPlaylistItemId)
        #expect(result[1].snippet.title == testSecondSnippetTitle)
        #expect(result[1].snippet.resourceId.videoId == testSecondResourceVideoId)
        #expect(result[1].snippet.viewCount == testSecondResouceViewCount)
    }
    
    @Test func testGetVideos() async throws {
        let testMockTitle: String = "testMockTitle"
        let testViewCount: String = "test100000"
        let testMockVideoId: String = "testMockVideoId"
        
        let testMockService = MockNetworkService()
        
        let snippet = PlaylistItem.Snippet(
            title: testMockTitle,
            resourceId: PlaylistItem.Snippet.Resource(videoId: testMockVideoId),
            viewCount: testViewCount,
            thumbnails: nil
        )
        
        testMockService.videosResult = .success([
            Video(statistics: .init(viewCount: testViewCount)),
            Video(statistics: .init(viewCount: testViewCount))
        ])
        
        let result = try await testMockService.getVideos(by: snippet.resourceId.videoId)
        
        #expect(result.count == 2)
        #expect(result[0].statistics.viewCount == testViewCount)
        #expect(result[1].statistics.viewCount == testViewCount)
    }
    
}
