//
//  ListPresenterTests.swift
//  CarZoneTests
//
//  Created by Venkatapathi Sure on 29/08/21.
//

import XCTest
import Combine
@testable import CarZone

class ListPresenterTests: XCTestCase {
    var presenter: CZListPresenter?
    let mockInteractor = CZListInteracter()
    let mockRouter = CZListRouter()
    var cancellable = Set<AnyCancellable>()
    var mockManufacturerListResponseData:CZCarManufacturer?
    var mockModelsListResponseData:CZCarManufacturer?
    var mockFetchMorePages = PassthroughSubject<ListType, Never>()
    var mockSearchText = PassthroughSubject<String, Never>()
    var mockRouteToScreenForSelectedRow = PassthroughSubject<CZListRouter.sceneRoute, Never>()

    var mockOutput: AnyPublisher<Result<[Model], Error>,Never>?
    
    
    
    override func setUpWithError() throws {

        guard let manufacturerListpath = Bundle(for: type(of: self)).path(forResource: "MockManufacturerList", ofType: "json")
        else { XCTFail("Unable to get the path for mock plist"); return }
        
        guard let modelsListpath = Bundle(for: type(of: self)).path(forResource: "MockModelsList", ofType: "json")
        else { XCTFail("Unable to get the path for mock plist"); return }
        
        let manufacturerListMockData = try Data(contentsOf: URL(fileURLWithPath: manufacturerListpath))
        mockManufacturerListResponseData = try JSONDecoder().decode(CZCarManufacturer.self, from: manufacturerListMockData)
        
        
        let modelsListMockData = try Data(contentsOf: URL(fileURLWithPath: modelsListpath))
        mockModelsListResponseData = try JSONDecoder().decode(CZCarManufacturer.self, from: modelsListMockData)
        
        presenter = CZListPresenter(router: mockRouter, interacter: mockInteractor)
        
        mockOutput =  presenter?.transform(input: CZListPresenter.Input(searchText: self.mockSearchText.eraseToAnyPublisher(), fetchMorePages: self.mockFetchMorePages.eraseToAnyPublisher(), routeToScreenForSelectedRow: self.mockRouteToScreenForSelectedRow.eraseToAnyPublisher())).listUpdate
        
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        
    }
    
    func testManufacturerListObjects() throws {
        guard let responseData = mockManufacturerListResponseData?.objectList else { XCTFail("Failed to get response data"); return }

        let expectation = self.expectation(description: "Fetch Manufacturer list")
        
        var objects = [Model]()
        
        mockOutput?.sink(receiveValue: { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error:\(error)")
                break
            case .success(let objectList):
                objects = objectList
                break
            }
            
            
            expectation.fulfill()
        }).store(in: &cancellable)
        
        
        mockInteractor.fetchedListOutput.send(.success(responseData))
        
       
        waitForExpectations(timeout: 1)
        print(objects)
        XCTAssertEqual(objects.count, 10)
    }
    
    
    func testModelsListUpdatePublisher() throws {
        guard let responseData = mockModelsListResponseData?.objectList else { XCTFail("Failed to get response data"); return }
       
        let expectation = self.expectation(description: "Fetch Manufacturer list")
        
        var objects = [Model]()
        
        mockOutput?.sink(receiveValue: { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error:\(error)")
                break
            case .success(let objectList):
                objects = objectList
                break
            }
            
            expectation.fulfill()
        }).store(in: &cancellable)
        
        mockInteractor.fetchedListOutput.send(.success(responseData))
        
       
        waitForExpectations(timeout: 1)
        print(objects)
        XCTAssertEqual(objects.count, 6)
    }
    
    func testSearchTextPublisher() throws {
        guard let responseData = mockManufacturerListResponseData?.objectList else { XCTFail("Failed to get response data"); return }
        let expectation = self.expectation(description: "Search Text Testing")
        
        var objects = [Model]()
        
        mockInteractor.fetchedListOutput.send(.success(responseData))
      
        mockOutput?.sink(receiveValue: { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error:\(error)")
                break
            case .success(let objectList):
                objects = objectList
                break
            }
            
            expectation.fulfill()
        }).store(in: &cancellable)
       
        self.mockSearchText.send("Alp")
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(objects.count, 2)
    }
    
    func testEmptySearchTextPublisher() throws {
        guard let responseData = mockManufacturerListResponseData?.objectList else { XCTFail("Failed to get response data"); return }
        let expectation = self.expectation(description: "Empty Search Text Testing")
        
        var objects = [Model]()
        
        mockInteractor.fetchedListOutput.send(.success(responseData))
      
        mockOutput?.sink(receiveValue: { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error:\(error)")
                break
            case .success(let objectList):
                objects = objectList
                break
            }
            
            expectation.fulfill()
        }).store(in: &cancellable)
       
        self.mockSearchText.send("")
        
        waitForExpectations(timeout: 1)
        XCTAssertEqual(objects.count, 10)
    }
    
    
    func testFailedFetchingManufacturerList() throws {
        let expectation = self.expectation(description: "Failed fetching list Testing")
        
        var objects = [Model]()
        
        var didReceivedError = false
        
        mockInteractor.fetchedListOutput.sink(receiveValue: { result in
            switch result {
            case .failure(_):
                didReceivedError = true
                expectation.fulfill()
                break
            case .success(let objectList):
                objects = objectList
                break
            }
            
            
        }).store(in: &cancellable)
        
        mockInteractor.fetchedListOutput.send(.failure(NetworkErrorTypes.ResponseError))
        
        waitForExpectations(timeout: 1)
        XCTAssertTrue(didReceivedError, "Should failed to fetch the list")
    }
    
    func testFinishedFetchingManufacturerList() throws {
        let expectation = self.expectation(description: "Finished fetching list Testing")
        
        var didReceiveList = false
        
        mockInteractor.fetchedListOutput.sink(receiveValue: { result in
            switch result {
            case .failure(let error):
                XCTFail("Failed with error:\(error)")
                break
            case .success(_):
                didReceiveList = true
                expectation.fulfill()
                break
            }
            
            
        }).store(in: &cancellable)
        
        mockInteractor.fetchedListOutput.send(completion: .finished)
        
        waitForExpectations(timeout: 1)
        XCTAssertTrue(didReceiveList, "Suppose to fetch the list but failed.")
    }
}
