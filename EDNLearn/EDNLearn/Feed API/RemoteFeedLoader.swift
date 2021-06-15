//
//  RemoteFeedLoader.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 08/06/21.
//

import Foundation


public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
        
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    //        case success([Feeditem])
   public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    public func load(completion:@escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                if  let items = try? FeedItemMapper.map(data, response) {
                    completion(.success(items))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                    completion(.failure(.connectivity))
            }
        }
    }
}




