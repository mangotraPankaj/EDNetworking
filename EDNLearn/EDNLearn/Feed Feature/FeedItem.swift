//
//  FeedItem.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 07/06/21.
//

import Foundation

public struct FeedItem: Equatable {
   public let id: UUID
   public let description: String?
   public let location: String?
   public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}

//the below codingKeys enum is used as the json key is image instead of imageURL. If the key in the JSON contract is imageURL we dont need to create the below enum
extension FeedItem: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case description
        case location
        case imageURL = "image"
    }
}
