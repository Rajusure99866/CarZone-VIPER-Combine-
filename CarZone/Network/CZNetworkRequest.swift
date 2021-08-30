//
//  CZNetworkRequest.swift
//  CarZone
//
//  Created by Venkatapathi Sure on 25/08/21.
//

import Foundation

struct CZNetworkRequest: RequestProtocol {
    var requestContentType: HTTPContentType?
    var httpMethod: HTTPMethod?
    var resourcePath: String
    var pathParam: String?
    var queryParams: [String: String]?
    var body: Data?
    private var requestTimeoutInterval: TimeInterval = 180
    
    init(resourcePath: String,
         httpMethod: HTTPMethod? = .get,
         pathParam: String? = nil,
         queryParams: [String: String]? = nil,
         requestContentType: HTTPContentType? = .json,
         shouldIgnoreCacheData: Bool = false) {
        self.httpMethod = httpMethod
        self.resourcePath = resourcePath
        self.pathParam = pathParam
        self.queryParams = queryParams
        self.requestContentType = requestContentType
    }
    
    var timeoutInterval: TimeInterval {
        get {
            return requestTimeoutInterval
        } set {
            requestTimeoutInterval = newValue
        }
    }
}

extension CZNetworkRequest {
    
    /// Constructing the full URL from base URL, resource path and query params.
    public var fullResourceURL: URL? {
        var path = CZAPIEndpoints.baseURL + "\(resourcePath)"

        if let param = pathParam {
            path += "/\(param)"
        }
        
        var urlComps = URLComponents(string: path)
        
        if let queryParam = queryParams {
            let resultComponents = queryParam.map { URLQueryItem(name: $0, value: $1) }
            urlComps?.queryItems = resultComponents
        }
        
        return urlComps?.url
    }
}

