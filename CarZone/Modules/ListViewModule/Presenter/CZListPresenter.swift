//
//  CZHomeManufacturerPresenter.swift
//  CarZone
//
//  Created by Venkatapathi Sure on 25/08/21.
//

import UIKit
import Combine

enum ListType {
    case Manufacturer
    case Models(Model)
}

extension ListType {
    public var toString: String {
           switch self {
           case .Manufacturer:
               return "Manufacturer"
           case .Models(_):
               return "Models"
           }
    }
}

class CZListPresenter {

    enum listSection {
        case manufacturer
        case models
    }

    /// Using struct to keep input operations from view
    struct Input {
        let searchText: AnyPublisher<String, Never>
        let fetchMorePages: AnyPublisher<ListType, Never>
        let routeToScreenForSelectedRow: AnyPublisher<CZListRouter.sceneRoute, Never>
    }
    
    /// Using struct to keep output operations to view
    struct Output {
        let listUpdate: AnyPublisher<Result<[Model], Error>, Never>
    }
    
    private var router: CZListRouter? // list router
    private var interactor: CZListInteracter? // list interacter
    private var cancellable = Set<AnyCancellable>() // store the publishers
    private lazy var objectList = [Model]()
    private var listUpdate = PassthroughSubject<Result<[Model], Error>, Never>() // binding fetched list to view
    private var currentSearchText:String = ""
    
    /// Initialising from list router with dependencies.
    /// - Parameters:
    ///   - listRouter: The presenter uses a router to navigate to different screens.
    ///   - listInteracter: The presenter uses Interacter to fetch data.
    init(router listRouter: CZListRouter, interacter listInteracter: CZListInteracter) {
        self.router = listRouter
        self.interactor = listInteracter
        
        
        self.setupfetchedListOutput()
    }
    
    
    /// Adding subcriber to fetched list data.
    private func setupfetchedListOutput() {
        interactor?.fetchedListOutput.sink(receiveValue: { result in
            switch result {
            case .failure(let error):
                self.listUpdate.send(.failure(error))
                break
            case .success(let objectList):
                self.objectList.append(contentsOf: objectList)
                self.filterResultsForSearch()
                break
            }
        }).store(in: &cancellable)
    }
}

extension CZListPresenter {

    /// Tranforms the Input to Output
    /// - Parameter input: Passing Input Operations
    /// - Returns: Returns Output Object
    func transform(input: Input) -> Output {
        interactor?.fetchMorePages = input.fetchMorePages.eraseToAnyPublisher() // Asssinging fetchMorePages operation to interacter for fetching new data.
        interactor?.setup() // adding subcriber
        router?.routeToScreen = input.routeToScreenForSelectedRow.eraseToAnyPublisher() // Asssinging routeToScreen operation to router for navigating to different screen.
        router?.setup() // adding subcriber
        
        
        // Adding subcriber for search bar.
        input.searchText.sink { [weak self] search in
            self?.currentSearchText = search
            self?.filterResultsForSearch()
        }.store(in: &cancellable)
        
        return Output(listUpdate: listUpdate.eraseToAnyPublisher())
    }
    
    /// Filters the results for the search text and publishes the result.
    private func filterResultsForSearch() {
        if currentSearchText.isEmpty == false {
            let filteredList = self.objectList.filter { $0.name.lowercased().contains(currentSearchText.lowercased()) }
            self.listUpdate.send(.success(filteredList))
        }
        else {
            self.listUpdate.send(.success(self.objectList))
        }
    }
}
