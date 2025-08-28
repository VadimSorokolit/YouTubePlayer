//
//  MoyaProvider+MoyaConcurrency.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 28.08.2025.
//

import Foundation
import Moya

extension MoyaProvider {
    
    class MoyaConcurrency {
        
        private let provider: MoyaProvider
        
        init(provider: MoyaProvider) {
            self.provider = provider
        }
        
        func request<T: Decodable>(_ target: Target) async throws -> T {
            return try await withCheckedThrowingContinuation { continuation in
                self.provider.request(target) { result in
                    switch result {
                        case .success(let response):
                            guard let result = try? JSONDecoder.default.decode(T.self, from: response.data) else {
                                continuation.resume(throwing: MoyaError.jsonMapping(response))
                                return
                            }
                            continuation.resume(returning: result)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    var async: MoyaConcurrency {
        MoyaConcurrency(provider: self)
    }
    
}

extension JSONDecoder {
    
    static var `default`: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
}
