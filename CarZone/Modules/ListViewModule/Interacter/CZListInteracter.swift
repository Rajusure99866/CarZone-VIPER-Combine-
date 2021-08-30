//
//  CZManufactureInteracter.swift
//  CarZone
//
//  Created by Venkatapathi Sure on 25/08/21.
//

import Foundation
import Combine

class CZListInteracter {
    private var cancellable = Set<AnyCancellable>()  // store the publishers
    private var manufacturer: CZCarManufacturer?
    private var isListFetchingInProgress = false
    var fetchMorePages: AnyPublisher<ListType, Never>?
    var fetchedListOutput: CurrentValueSubject<Result<[Model], Error>, Never> = CurrentValueSubject<Result<[Model], Error>, Never>(.success([]))
    
    /// Setting subcriber for fetchMorePages
    func setup() {
        fetchMorePages?.sink { listType in
            // increasing the page count for fetching the next page.
            var pageNo = 0
            var totalPageCount = 1
            if let manufacturer = self.manufacturer {
                pageNo = manufacturer.page + 1
                totalPageCount = manufacturer.totalPageCount
            }
            
            if pageNo >= 0 && self.isListFetchingInProgress == false && pageNo < totalPageCount {
                self.isListFetchingInProgress = true
                
                if Reachability.isConnectedToNetwork() {
                    self.getListInformation(pageNo, listType: listType)
                }
                else {
                    self.isListFetchingInProgress = false
                    self.fetchedListOutput.send(.failure(NetworkErrorTypes.noInternetConnection))
                }
            }
        }.store(in: &cancellable)
    }
 
}

extension CZListInteracter {
    
    /// Makes the API request based on list type and publishes it to the subscriber.
    /// - Parameters:
    ///   - page: Page number
    ///   - listType: Manufacturer or Model
    func getListInformation(_ page:Int, listType: ListType) {
        var resourcePath:String
        var queryParams:[String:String]
        
        switch listType {
        case .Manufacturer:
            resourcePath = CZAPIEndpoints.manufacturers
            queryParams = [CZRequestConstants.page: "\(page)", CZRequestConstants.pageSize:String(CZRequestConstants.defaultPageSize), CZRequestConstants.wa_key: CZRequestConstants.wa_Value] // Creating query params for manufaturer
            break
        case .Models(let manufacturer):
            resourcePath = CZAPIEndpoints.models
            queryParams = [CZRequestConstants.manufacturer : "\(manufacturer.id)", CZRequestConstants.page: "\(page)", CZRequestConstants.pageSize:String(CZRequestConstants.defaultPageSize), CZRequestConstants.wa_key: CZRequestConstants.wa_Value] // Creating query params for models
            break
        }
        
        let apiLoader = CZAPILoader(CZInformationAPI.shared)
        let manufacturersRequest = CZNetworkRequest(resourcePath: resourcePath, httpMethod: .get, queryParams: queryParams, requestContentType: .json, shouldIgnoreCacheData: true) // Creating common request.
        
        // Adding subcriber for API request.
        apiLoader.loadAPIRequest(manufacturersRequest).sink { (completion) in
            self.isListFetchingInProgress = false
            switch completion {
            case .failure(let error):
                self.fetchedListOutput.send(.failure(error))
                break
                
            case .finished:
            break
            }
        } receiveValue: { manufacturer in
            self.manufacturer = manufacturer
            self.isListFetchingInProgress = false
            self.fetchedListOutput.send(.success(manufacturer.objectList)) // Notifying data.
        }
        .store(in: &cancellable)
    }
    
}
