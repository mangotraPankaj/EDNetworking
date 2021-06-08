//
//  RemoteFeedLoaderTests.swift
//  EDNLearnMacTests
//
//  Created by Pankaj Mangotra on 07/06/21.
//

import XCTest
import EDNLearnMac

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        
        let(_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
        
    }
    
    func test_load_requestDataFromURL() {
        
        let url = URL(string: "https://a-give-url.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
    //MARK: Helper
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut,client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        func get(from url: URL) {
            requestedURL = url
        }
    }

}
