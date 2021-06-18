//
//  HTTPClient.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 15/06/21.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

