//
//  CZAPIPath.swift
//  CarZone
//
//  Created by Venkatapathi Sure on 24/08/21.
//

import Foundation

struct CZAPIEndpoints {
    static let baseURL = "http://api-aws-eu-qa-1.auto1-test.com"
    static let manufacturers = "/v1/car-types/manufacturer"
    static let models = "/v1/car-types/main-types"
}

struct CZRequestConstants {
    static let wa_Value = "coding-puzzle-client-449cc9d"
    static let wa_key = "wa_key"
    static let pageSize = "pageSize"
    static let page = "page"
    static let manufacturer = "manufacturer"
    static let defaultPageSize = 15
}
