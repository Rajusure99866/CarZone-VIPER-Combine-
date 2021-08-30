//
//  CZRequestProtocol.swift
//  CarZone
//
//  Created by Venkatapathi Sure on 25/08/21.
//

import Foundation

typealias QueryParam = [String: String]

public enum HTTPMethod: String {
    case post   = "POST"
    case get    = "GET"
    case put    = "PUT"
    case delete = "DELETE"
}

public enum HTTPContentType {
    case json, html
    
    var contentType: String {
        switch self {
        case .json:
            return "application/json"
        case .html:
            return "text/html;charset=utf-8"
        }
    }
}

protocol RequestProtocol {    
    var resourcePath: String { get }
    
    var pathParam: String? { get }
    
    var queryParams: QueryParam? { get }
    
    var httpMethod: HTTPMethod? { get }
    
    var requestContentType: HTTPContentType? { get set }
    
    var fullResourceURL: URL? { get }
    
    var timeoutInterval: TimeInterval { get set }
    
    var body: Data? { get set }
}

extension RequestProtocol {
    var timeoutInterval: TimeInterval {
        return 180
    }
}

