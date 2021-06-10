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
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
        
    }
    
    func test_load_requestDataFromURL() {
        
        let url = URL(string: "https://a-give-url.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURL() {
        
        let url = URL(string: "https://a-give-url.com")!
        let (sut,client) = makeSUT(url: url)
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs,[url,url])
    }
    
    func test_load_deliversErrorOnClientError() {
        //Arrange
        let (sut,client) = makeSUT()
       
        //Act
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load {capturedError.append($0)}
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
       
        //Assert
        XCTAssertEqual(capturedError,[.connectivity])
    }
    

    //MARK: Helper
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut,client)
    }
    

    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var completions = [(Error)->Void]()
        func get(from url: URL,completion: @escaping (Error)->Void) {
            completions.append(completion)
            requestedURLs.append(url)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](error)
        }
    }
}
