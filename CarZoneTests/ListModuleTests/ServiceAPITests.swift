//
//  ServiceAPITests.swift
//  CarZoneTests
//
//  Created by Venkatapathi Sure on 29/08/21.
//

import XCTest

@testable import CarZone

class ServiceAPITests: XCTestCase {
    
    var manufacturerRequest:CZNetworkRequest?
    var modelsRequest:CZNetworkRequest?

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let manufacturerResourcePath = CZAPIEndpoints.manufacturers
        let manufacturerQueryParams = [CZRequestConstants.page: "0", CZRequestConstants.pageSize:String(CZRequestConstants.defaultPageSize), CZRequestConstants.wa_key: CZRequestConstants.wa_Value]
        
        let modelsResourcePath = CZAPIEndpoints.models
        let modelsQueryParams = [CZRequestConstants.manufacturer : "107", CZRequestConstants.page: "0", CZRequestConstants.pageSize:String(CZRequestConstants.defaultPageSize), CZRequestConstants.wa_key: CZRequestConstants.wa_Value]
        
        manufacturerRequest = CZNetworkRequest(resourcePath: manufacturerResourcePath, httpMethod: .get, queryParams: manufacturerQueryParams, requestContentType: .json, shouldIgnoreCacheData: true)
        
        modelsRequest = CZNetworkRequest(resourcePath: modelsResourcePath, httpMethod: .get, queryParams: modelsQueryParams, requestContentType: .json, shouldIgnoreCacheData: true)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateCZNetworkRequest() throws {
        guard let request = self.manufacturerRequest else { XCTFail("Failed to create CZNetworkRequest object"); return }
        
        
        XCTAssertEqual(request.resourcePath, CZAPIEndpoints.manufacturers)
        XCTAssertEqual(request.httpMethod, HTTPMethod.get)
        XCTAssertEqual(request.queryParams?.count, 3)
        XCTAssertEqual(request.requestContentType, HTTPContentType.json)
    }

    func testManufacturerServiceAPI() throws {
        guard let request = self.manufacturerRequest else { XCTFail("Failed to create CZNetworkRequest object"); return }
        
        let manufacturerService = CZInformationAPI.shared
        
        let urlRequestObject = manufacturerService.makeRequest(request)
        
        XCTAssertNotNil(urlRequestObject, "Failed to create URLRequest from CZNetworkRequest")
        
        XCTAssertNotNil(urlRequestObject?.url, "Failed to create URL")
        
        guard let urlString = urlRequestObject?.url?.absoluteString else { XCTFail("Failed to create url string"); return }
        
        XCTAssertGreaterThan(urlString.count, 0)

        guard let httpMethod = urlRequestObject?.httpMethod else { XCTFail("Failed to set Http method"); return }
        XCTAssertEqual(httpMethod, HTTPMethod.get.rawValue)
    }
    
    func testModelsServiceAPI() throws {
        guard let request = self.modelsRequest else { XCTFail("Failed to create CZNetworkRequest object"); return }
        
        let modelsService = CZInformationAPI.shared
        
        let urlRequestObject = modelsService.makeRequest(request)
        
        XCTAssertNotNil(urlRequestObject, "Failed to create URLRequest from CZNetworkRequest")
        
        XCTAssertNotNil(urlRequestObject?.url, "Failed to create URL")
        
        guard let urlString = urlRequestObject?.url?.absoluteString else { XCTFail("Failed to create url string"); return }
        
        XCTAssertGreaterThan(urlString.count, 0)

        guard let httpMethod = urlRequestObject?.httpMethod else { XCTFail("Failed to set Http method"); return }
        XCTAssertEqual(httpMethod, HTTPMethod.get.rawValue)
    }
    
    func testManufactureListResponseParser() throws {
        guard let path = Bundle(for: type(of: self)).path(forResource: "MockManufacturerList", ofType: "json")
        else { XCTFail("Unable to get the path for mock plist"); return }
        
        let mockData = try Data(contentsOf: URL(fileURLWithPath: path))
        
        let manufacturerService = CZInformationAPI.shared
        
        let parsedResponse =  try manufacturerService.parseResponse(mockData, HTTPURLResponse(url: URL(string: CZAPIEndpoints.manufacturers)!, statusCode: 200, httpVersion: "", headerFields: [:]))
        
        XCTAssertNotNil(parsedResponse, "Failed to parse the response to Manufacture list")
        XCTAssertEqual(parsedResponse.pageSize, 10)
    }
    
    
    func testModelsListResponseParser() throws {
        guard let path = Bundle(for: type(of: self)).path(forResource: "MockModelsList", ofType: "json")
        else { XCTFail("Unable to get the path for mock plist"); return }
        
        let mockData = try Data(contentsOf: URL(fileURLWithPath: path))
        
        let modelsService = CZInformationAPI.shared
        
        let parsedResponse =  try modelsService.parseResponse(mockData, HTTPURLResponse(url: URL(string: CZAPIEndpoints.manufacturers)!, statusCode: 200, httpVersion: "", headerFields: [:]))
        
        XCTAssertNotNil(parsedResponse, "Failed to parse the response to Manufacture list")
        XCTAssertEqual(parsedResponse.pageSize, 10)
    }

}
