//
//  CharacterElementsView.swift
//  rxmarvel
//
//  Created by Francisco José Ruiz on 16/11/2020.
//  Copyright © 2020 Francisco José Ruiz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CharacterElementsView: UIViewController {

    //MARK: IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var characterName: String!
    
    //MARK: Rx
    private var disposeBag = DisposeBag()
    
    
    //MARK: ViewModel
    private var viewModel: CharacterElementsViewModelProtocol!
    
    //MARK: Construct
    static func create(title: String, viewModel: CharacterElementsViewModelProtocol) -> CharacterElementsView {
        let vc = CharacterElementsView(nibName: "CharacterElementsView", bundle: nil)
        vc.characterName = title
        vc.viewModel = viewModel
        return vc
    }
    
    
    
    //MARK: UIVIewController
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupBindings()
    }
    
    private func configureView() {
        titleLabel.text = characterName
        
        /// Register cell for tableview
        tableView.register(
            UINib(nibName: "ElementCell", bundle: nil),
            forCellReuseIdentifier: "ElementCell"
        )
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        
    }
    
    private func setupBindings() {
        /// Set up viewmodel output
        let output = viewModel.transform(CharacterElementsViewModel.Input())
        
        /// tableview configuration
        //tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        /// On fetch
        output.elements.asObservable().bind(to: tableView.rx.items(cellIdentifier: "ElementCell", cellType: ElementCell.self)) { row, item, cell in
            cell.label.text = item.title ?? ""
        }.disposed(by: disposeBag)
        
        /// On tap
        Observable
        .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(CharacterElement.self))
        .bind { [unowned self] indexPath, item in
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.presentDetails(item)
        }
        .disposed(by: disposeBag)
        
    }
    
    private func presentDetails(_ item: CharacterElement) {
        guard let url = item.url else { return }
        if let _url = URL(string: url) {
            UIApplication.shared.open(_url)
        }
    }
    
    //MARK: IBActions
    @IBAction func dismissTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    

}

//MARK: UITableViewDelegate
extension CharacterElementsView: UITableViewDelegate {
    
}
