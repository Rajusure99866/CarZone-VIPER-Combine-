//
//  CZAPILoader.swift
//  CarZone
//
//  Created by Venkatapathi Sure on 24/08/21.
//

import Foundation
import Combine



class CZAPILoader<T: APIHandler> {
    private let request:T
    private let session:URLSession
    private var cancellable = Set<AnyCancellable>()
    
    /// Initializes CZAPILoader
    /// - Parameters:
    ///   - request: APIHandler request
    ///   - session: Default session.
    init(_ request: T, _ session: URLSession = .shared ) {
        self.request = request
        let sessionConfig = URLSessionConfiguration.default
        self.session = URLSession(configuration: sessionConfig)
    }
    
    /// Makes the network call for the passed request.
    /// - Parameter requestData: API request information
    /// - Returns: Future Publisher for the response
    func loadAPIRequest(_ requestData: RequestProtocol) -> Future<T.ResponseDataType, Error> {
        return Future<T.ResponseDataType, Error> { promise in
            if let urlRequest = self.request.makeRequest(requestData) {
                self.session.dataTaskPublisher(for: urlRequest)
                    .tryMap { (data: Data, response: URLResponse) in
                        return try self.request.parseResponse(data, response as? HTTPURLResponse)
                    }.sink(receiveCompletion: { (completion) in
                        if case let .failure(error) = completion {
                            switch error {
                            case let decodingError as DecodingError:
                                promise(.failure(decodingError))
                            case let apiError as NetworkErrorTypes:
                                promise(.failure(apiError))
                            default:
                                promise(.failure(NetworkErrorTypes.Unknown))
                            }
                        }
                    }, receiveValue: { promise(.success($0)) })
                    .store(in: &self.cancellable)
            }
            else {
                return promise(.failure(NetworkErrorTypes.URLRequestFailed))
            }
        }
    }
}

