//
//  CharacterListView.swift
//  reactive_mvvm
//
//  Created by Francisco José Ruiz on 15/11/2020.
//  Copyright © 2020 Francisco José Ruiz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CharacterListView: UIViewController {

    //MARK: Construct
    static func create(viewModel: CharacterListViewModelProtocol) -> CharacterListView {
        let vc = UIStoryboard(
            name: Constants.Storyboards.Main,
            bundle: nil
        ).instantiateViewController(
            withIdentifier: "CharacterListView"
        ) as! CharacterListView
        vc.viewModel = viewModel
        return vc
    }
    
    //MARK: IBOutlet
    @IBOutlet weak var scrollToTopView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    private lazy var searchController: UISearchController = ({
        let controller = UISearchController(searchResultsController: nil)
        controller.hidesNavigationBarDuringPresentation = true
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.sizeToFit()
        controller.searchBar.barStyle = .black
        controller.searchBar.backgroundColor = .clear
        controller.searchBar.placeholder = Localizable.CharacterListView.search_bar.localized
        return controller
    })()
    
    private lazy var refreshControl = UIRefreshControl()
    
    private lazy var characterDetailsView = CharacterDetailsView()
    
    
    //MARK: Viewmodel
    private var viewModel: CharacterListViewModelProtocol!
    
    
    //MARK: Managers
    private var alertManager = AlertManager()
    
    //MARK: Rx
    private var disposeBag = DisposeBag()
    
    
    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        translate()
        configureView()
        setupBindings()
        viewModel.getData()
    }
    
    private func translate() {
        titleLabel.text = Localizable.CharacterListView.title.localized
    }
    
    private func configureView() {
        /// Set up scroll button
        scrollToTopView.layer.cornerRadius = scrollToTopView.frame.height / 2
        scrollToTopView.isHidden = true
        
        /// tableview configuration
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        /// Register cell for tableview
        tableView.register(
            UINib(nibName: "CharacterCell", bundle: nil),
            forCellReuseIdentifier: "CharacterCell"
        )
        
        /// Add a search controller
        addSearchController()
        
        /// Add a refresh control
        addPullToRefresh()
    }
    
    
    private func addPullToRefresh() {
        /// End refreshing when appears
        refreshControl.rx
            .controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.refreshControl.endRefreshing()
            }).disposed(by: disposeBag)
        
        /// Add pull to refresh
        tableView.addSubview(refreshControl)
    }
    
    private func addSearchController() {
        let searchBar = searchController.searchBar
        searchController.delegate = self
        tableView.tableHeaderView = searchBar
        tableView.contentOffset = CGPoint(x: 0, y: searchBar.frame.size.height)
    }
    
    private func setupBindings() {
        /// Set up viewmodel output
        let output = viewModel.transform(
            CharacterListViewModel.Input(
                filteredText: searchController.searchBar.rx
                    .text
                    .orEmpty
                    .asObservable(),
                reloadData: refreshControl.rx.controlEvent(.valueChanged).asObservable()
            )
        )
        
        output.downloading.drive(spinner.rx.isHidden).disposed(by: disposeBag)
        
        /// Configure table view
        configureTableView(output)
        
        /// On handle error
        onHandleError(output)
        
    }
    
    /// On fetch Data
    private func configureTableView(_ output: CharacterListViewModel.Output) {
        /// On fetch
        output.characters.asObservable().bind(to: tableView.rx.items(cellIdentifier: "CharacterCell", cellType: CharacterCell.self)) { row, item, cell in
            cell.setCell(item)
            self.viewModel.tableViewScroll(to: row)
        }.disposed(by: disposeBag)
        
        /// On tap
        Observable
        .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Character.self))
        .bind { [unowned self] indexPath, character in
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.presentDetails(character)
        }
        .disposed(by: disposeBag)
        
        tableView.rx.contentOffset.subscribe(
            onNext: { (offset) in
                self.scrollToTopView.isHidden = (offset.y <= 1000)
        }).disposed(by: disposeBag)
    }
    
    /// On handle Error
    private func onHandleError(_ output: CharacterListViewModel.Output) {
        output.error.drive(
            onNext: {
                self.alertManager.showWarning(parentView: self.view, message: $0.title)
        }).disposed(by: disposeBag)
    }
    
    /// Present details
    private func presentDetails(_ character: Character) {
        searchController.isActive = false
        
        let vm = CharacterDetailsViewModel(character: character)
        characterDetailsView = CharacterDetailsView.create(viewModel: vm)
        
        characterDetailsView.modalPresentationStyle = .fullScreen
        self.present(characterDetailsView, animated: true, completion: nil)
    }

    //MARK: IBActions
    @IBAction func scrollToTopTapped(_ sender: Any) {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    
}

//MARK: UITableViewDelegate
extension CharacterListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145.0
    }
}

//MARK: UISearchControllerDelegate
extension CharacterListView: UISearchControllerDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.isActive = false
    }
}
