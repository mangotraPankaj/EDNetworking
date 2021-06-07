//
//  FeedLoader.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 07/06/21.
//

import Foundation
enum LoadFeedResult {
    case success([FeedItem])
    case error([Error])
}

protocol FeedLoader {
    func load(completion: @escaping(LoadFeedResult) -> Void)
}
