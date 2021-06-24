//
//  URLSessionHTTPClient.swift
//  EDNLearn
//
//  Created by Pankaj Mangotra on 24/06/21.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
   public init(session: URLSession = .shared) {
        self.session = session
    }
  private struct UnexpectedValuesRepresentation: Error {}
    
    public func get(from url: URL, completion:@escaping (HTTPClientResult)-> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
    
    
}

extension URLSessionHTTPClient {
    public func post(_ data: Data, to url: URL, completion:@escaping (HTTPClientResult) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        
        session.dataTask(with: request) {_,_, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

extension URLRequest {
 public var httpBodyData: Data? {
    guard let stream = httpBodyStream else { return httpBody }
    
    let bufferSize = 1024
    var data = Data()
    var buffer = [UInt8](repeating: 0, count: bufferSize)
    
    stream.open()
    
    while stream.hasBytesAvailable {
      let length = stream.read(&buffer, maxLength: bufferSize)
      
      if length == 0 {
        break
      }
      data.append(&buffer, count: length)
    }
    stream.close()
    
    return data
  }
}
