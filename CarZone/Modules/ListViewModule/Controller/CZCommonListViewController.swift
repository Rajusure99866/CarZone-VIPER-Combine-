//
//  CZHomeManufacturerViewController.swift
//  CarZone
//
//  Created by Venkatapathi Sure on 25/08/21.
//

import UIKit
import Combine

class CZCommonListViewController: UIViewController {
    
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var refreshButton: UIButton!
    
    lazy var dataSource = createDataSource()
    var shouldRefreshCellsManually = false
    
    var fetchMorePages = PassthroughSubject<ListType, Never>()
    var searchText = PassthroughSubject<String, Never>()
    var routeToScreenForSelectedRow = PassthroughSubject<CZListRouter.sceneRoute, Never>()
    
    var listPresenter: CZListPresenter
    private var cancellable = Set<AnyCancellable>()
    var listType: ListType

    required init?(coder: NSCoder, presenter: CZListPresenter ,listType: ListType) {
        self.listType = listType
        self.listPresenter = presenter
        super.init(coder: coder)
        
        self.setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingIndicator.startAnimating()
        self.refreshButton.isHidden = true
        self.title = listType.toString
        
        if self.listType.toString == ListType.Manufacturer.toString {
            let searchController = UISearchController()
            searchController.obscuresBackgroundDuringPresentation = false
            navigationItem.searchController = searchController
            navigationItem.searchController?.searchResultsUpdater = self
        }

        listTableView.delegate = self
        listTableView.dataSource = self.dataSource
        listTableView.separatorStyle = .none

        let cellNib = UINib(nibName: CZCommonListTableViewCell.nibName, bundle: nil)
        listTableView.register(cellNib, forCellReuseIdentifier: CZCommonListTableViewCell.reuseIdentifer)
        
        self.fetchMorePages.send(self.listType)
    }
    
    
    /// Setting up all the inputs which need to be passed to the Presenter from ViewController.
    private func setup() {
        let output = listPresenter.transform(input: CZListPresenter.Input(searchText: self.searchText.eraseToAnyPublisher(), fetchMorePages: self.fetchMorePages.eraseToAnyPublisher(), routeToScreenForSelectedRow: self.routeToScreenForSelectedRow.eraseToAnyPublisher()))
        
        output.listUpdate.receive(on: DispatchQueue.main).sink(receiveValue: { result in
            switch result {
            case .failure(let error):
                self.errorHandlers(error: error)
                break
            case .success(let objectList):
                self.applySnapshot(objectList)
                break
            }
        }).store(in: &cancellable)
    }
    
    @IBAction func refreshList(_ sender: UIButton) {
        self.fetchMorePages.send(self.listType)
    }
    
}



// MARK: TableView Diffable DataSource
extension CZCommonListViewController {
    
    private func createDataSource() -> UITableViewDiffableDataSource<CZListPresenter.listSection, Model> {
        let dataSource = UITableViewDiffableDataSource<CZListPresenter.listSection, Model>(tableView: listTableView)
        { [weak self] tableview, indexPath, model in
            return self?.dequeueReusableCell(tableview, indexPath: indexPath, model: model)
        }
        return dataSource
    }
    
    private func dequeueReusableCell(_ tableView: UITableView, indexPath: IndexPath, model: Model) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CZCommonListTableViewCell.reuseIdentifer, for: indexPath)
        let itemCell = (cell as? CZCommonListTableViewCell)
        itemCell?.configure(with: model)
        
        if listType.toString != ListType.Manufacturer.toString {
            itemCell?.disclosureIndicater.isHidden = true
        }
        
        return cell
    }
    
    private func applySnapshot(_ manufacturer: [Model]) {
        self.updateUI(manufacturer.count > 0)
        var snapshot = NSDiffableDataSourceSnapshot<CZListPresenter.listSection, Model>()
        snapshot.appendSections(self.listType.toString == ListType.Manufacturer.toString ? [.manufacturer] : [.models])
        let modelObjects = manufacturer.filter { !$0.name.isEmpty }.compactMap { $0 }
        snapshot.appendItems(modelObjects.sorted(by: { $0.name < $1.name }))
        
        // Due to Diffable data source behavior, when a new snapshot is applied, the cells which are exiting in the previous snapshot will not be loaded again. Due to which alternating row colors might mismatch. hence manually updating the cell's background color during the search process.
        dataSource.apply(snapshot, animatingDifferences: true) {
            if (self.shouldRefreshCellsManually) {
                var counter = 0
                self.listTableView.visibleCells.forEach { cell in
                    if let customCell = cell as? CZCommonListTableViewCell {
                        if (counter % 2 == 0)
                        {
                            customCell.setColor(UIColor.systemGray6)
                        } else {
                            customCell.setColor(UIColor.systemGray4)
                        }
                    }
                    
                    counter += 1
                }
                
                self.shouldRefreshCellsManually = false
            }
        }
    }
}






