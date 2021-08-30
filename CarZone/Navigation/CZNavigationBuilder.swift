//
//  CZNavigationBuilder.swift
//  CarZone
//
//  Created by Venkatapathi Sure on 25/08/21.
//

import UIKit

class NavigationBuilder {
    
    typealias buildNavigation = (UIViewController) -> UINavigationController
    
    /// Factory method for creating navigation controller.
    /// - Parameter viewController: Instance of root view controller.
    /// - Returns: Navigation controller.
    static func build(_ viewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }
}
