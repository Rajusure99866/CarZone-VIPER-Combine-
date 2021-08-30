//
//  CZResponseHandler+Extensions.swift
//  CarZone
//
//  Created by Venkatapathi Sure on 24/08/21.
//

import Foundation

extension ResponseHandler {
    
    /// Decodes the response data to required entity object
    /// - Parameters:
    ///   - responseData: JSON Data
    ///   - response: HTTPURLResponse
    /// - Throws: APIError or ResponseError
    /// - Returns: Decoded object
    func defaultResponseParser<T:Codable>(_ responseData: Data?, _ response: HTTPURLResponse?) throws -> T {
        if response?.statusCode == 401 {
            throw NetworkErrorTypes.ResponseError
        }
        else {
            guard let data = responseData, let statusCode = response?.statusCode, 200...299 ~= statusCode else {
                throw NetworkErrorTypes.APIError
            }
            
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(T.self, from: data)
        }
    }
}

