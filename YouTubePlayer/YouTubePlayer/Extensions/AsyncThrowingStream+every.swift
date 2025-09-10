//
//  AsyncThrowingStream+every.swift
//  YouTubePlayer
//
//  Created by Vadim Sorokolit on 10.09.2025.
//
    
extension AsyncThrowingStream where Element == Void, Failure == Error {
    
    static func every(seconds: Double) -> AsyncThrowingStream<Void, Error> {
        AsyncThrowingStream { continuation in
            Task {
                let ns = UInt64(seconds * 1_000_000_000)
                do {
                    while !Task.isCancelled {
                        try await Task.sleep(nanoseconds: ns)
                        continuation.yield(())
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
}
