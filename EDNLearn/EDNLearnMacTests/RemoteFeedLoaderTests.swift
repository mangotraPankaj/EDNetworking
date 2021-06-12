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
        let (sut, client) = makeSUT(url: url)
        sut.load {_ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURL() {
        
        let url = URL(string: "https://a-give-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load {_ in }
        sut.load {_ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        // Arrange
        let (sut, client) = makeSUT()
       
        // Act
        
        expect(sut, toCompleteWithResult: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        //Arrange
        let (sut, client) = makeSUT()
       
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWithResult: .failure(.invalidData), when: {
                client.complete(withStatusCode: code, at: index)
            })
        }
    }
    
    func test_load_deliverErrorON200ReponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
       
        expect(sut, toCompleteWithResult:.failure(.invalidData), when: {
                let invalidJSON = Data("invalidData".utf8)
                client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliverNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success([]), when: {
            let emptyListJSON = Data("{\"items\":[]}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }

    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
    
        let item1 = FeedItem(
            id: UUID(),
            description: nil,
            location: nil,
            imageURL: URL(string: "http://a-url.com")!)
        
        let item1JSON = [
            "id": item1.id.uuidString,
            "image": item1.imageURL.absoluteString
        ]
        
        let item2 = FeedItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "http://another-url.com")!)
        
        let item2JSON = [
            "id": item2.id.uuidString,
            "description": item2.description,
            "location": item2.location,
            "image": item2.imageURL.absoluteString
        ]
        
        let itemsJSON = [
            "items": [item1JSON, item2JSON]
        ]
        
        expect(sut, toCompleteWithResult: .success([item1, item2]), when: {
            let json = JSONSerialization.data(withJSONObject: itemsJSON)
            client.complete(withStatusCode: 200, data: json)
        })
        
    }
    
    
    // MARK: Helper
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) ->
    (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    
    // Creating a helper class to load the errors and do an assertion
    
    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWithResult result: RemoteFeedLoader.Result,
                        when action:() -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load {capturedResults.append($0)}
        action()
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }

    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion:(HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
