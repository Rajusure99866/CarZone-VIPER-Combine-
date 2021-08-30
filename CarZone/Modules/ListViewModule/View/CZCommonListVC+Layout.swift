//
//  CZHomeManufacturerListVC+Layout.swift
//  CarZone
//
//  Created by Venkatapathi Sure on 28/08/21.
//

import UIKit
import Combine

extension CZCommonListViewController {
    
    /// Updating the UI for Tableview
    /// - Parameter status: Bool
    func updateUI(_ status:Bool) {
        if self.loadingIndicator.isAnimating {
            self.loadingIndicator.stopAnimating()
        }
        
        if status {
            messageLabel.isHidden = status
            self.refreshButton.isHidden = status
        }
        else {
            messageLabel.isHidden = status
        }
    }
    
    func errorHandlers(error: Error) {
        switch error {
        case _ as DecodingError:
            self.messageLabel.text = "Unable to process"
        case let apiError as NetworkErrorTypes:
            switch apiError {
            case .APIError,.ResponseError,.URLRequestFailed,.Unknown:
                self.messageLabel.text = "Unknown Error"
                break
            case .noInternetConnection:
                self.messageLabel.text = "No Internet Connection!"
                break
            }
            break
        default:
            self.messageLabel.text = "Unknown Error"
            break
        }
        
        self.refreshButton.isHidden = false
        self.updateUI(false)
    }
}

// MARK: TableView Delegates
extension CZCommonListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Adding the animation for the cells
        cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.9) {
            cell.transform = CGAffineTransform.identity
        }
        
        // Setting alternate row color
        if let customCell = cell as? CZCommonListTableViewCell {
            if (indexPath.row % 2 == 0)
            {
                customCell.setColor(UIColor.systemGray6)
            } else {
                customCell.setColor(UIColor.systemGray4)
            }
        }
        
        // Fetching the next page list when the last row is loaded.
        if let lastSection = tableView.dataSource?.numberOfSections?(in: tableView), let lastRow = tableView.dataSource?.tableView(tableView, numberOfRowsInSection: indexPath.section) {
            if lastSection == (indexPath.section+1) && lastRow == (indexPath.row+1){
                self.fetchMorePages.send(self.listType)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = self.dataSource.itemIdentifier(for: indexPath) else { return }
        
        // Routing to selected option.
        let backButtonItem = UIBarButtonItem()
        backButtonItem.title = model.name
        navigationItem.backBarButtonItem = backButtonItem
        
        switch listType {
        case .Manufacturer:
            self.routeToScreenForSelectedRow.send(.Models(model))
            break
        case .Models(let passedObject):
            self.routeToScreenForSelectedRow.send(.alertScreen(Model(id: passedObject.id, name: model.name, manufacturerName: passedObject.name)))
            break
    }
}
}


// MARK: Search Text
extension CZCommonListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        
        if let searchtext = searchBar.text {
            self.shouldRefreshCellsManually = true
            
            // Sending the search text to subcriber in presenter.
            self.searchText.send(searchtext)
        }
    }
}
