//
//  CZHomemanufacturerRouter.swift
//  CarZone
//
//  Created by Venkatapathi Sure on 25/08/21.
//

import UIKit
import Combine

class CZListRouter {
    private weak var rootNavigationController:UINavigationController?
    private let storyboard = UIStoryboard(name: "CZMain", bundle: nil)
    private let listViewIdentifier = "listViewController"
    private var cancellable = Set<AnyCancellable>()
    
    var routeToScreen: AnyPublisher<sceneRoute, Never>?
    
    enum sceneRoute {
        case Models(Model)
        case alertScreen(Model)
    }
}

extension CZListRouter {
    func rootViewController(_ includedInNavigationController: NavigationBuilder.buildNavigation, listType:ListType) -> UINavigationController {
        let interacter = CZListInteracter()
        let presenter = CZListPresenter(router: self, interacter: interacter)
        let homeViewController = self.storyboard.instantiateViewController(identifier: listViewIdentifier) { coder in
            return CZCommonListViewController(coder: coder, presenter: presenter, listType: listType)
        }

        self.rootNavigationController = includedInNavigationController(homeViewController)
        
        return self.rootNavigationController!
    }
    
    
    func setup() {
        routeToScreen?.sink(receiveValue: { listType in
            switch listType {
            case .Models(let passedModel):
                let interacter = CZListInteracter()
                let presenter = CZListPresenter(router: self, interacter: interacter)
                
                let homeViewController = self.storyboard.instantiateViewController(identifier: self.listViewIdentifier) { coder in
                    return CZCommonListViewController(coder: coder,presenter: presenter, listType: .Models(passedModel))
                }

                homeViewController.listPresenter = presenter
                self.rootNavigationController?.pushViewController(homeViewController, animated: true)
                break
                
            case .alertScreen(let model):
                let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
                selectionFeedbackGenerator.selectionChanged()
                
                let uialert = UIAlertController(title: "Selected", message: "Manufacturer: \(model.manufacturerName ?? "") \n Model: \(model.name)", preferredStyle: UIAlertController.Style.alert)
                uialert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                self.rootNavigationController?.present(uialert, animated: true, completion: nil)
                break
            }
        }).store(in: &cancellable)
    }
}
