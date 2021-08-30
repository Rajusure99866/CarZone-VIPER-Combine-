//
//  CZManufacturersAPI.swift
//  CarZone
//
//  Created by Venkatapathi Sure on 24/08/21.
//

import Foundation

struct CZInformationAPI: APIHandler {
    static var shared = CZInformationAPI()
    
    private init() {}
    
    func makeRequest(_ request: RequestProtocol) -> URLRequest? {
        let urlRequest = URLRequest(request: request)
        
        return urlRequest
    }

    func parseResponse(_ data: Data, _ response: HTTPURLResponse?) throws -> CZCarManufacturer {
        return try defaultResponseParser(data, response)
    }
}
