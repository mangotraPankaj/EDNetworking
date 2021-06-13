//
//  RemoteFeedLoader.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 08/06/21.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

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

private class FeedItemMapper {
     struct Root: Decodable {
        let items: [Item]
    }

     struct Item: Decodable {
       public let id: UUID
       public let description: String?
       public let location: String?
       public let image: URL

        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    static var OK_200: Int {return 200}
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard  response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map {$0.item}
    }
}


