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
    public func load(completion: @escaping(Result) -> Void) {
        client.get(from: url) {[weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
               completion(FeedItemMapper.map(data, from: response))
                
            case .failure:
                    completion(.failure(.connectivity))
            }
        }
    }
    
   
}





