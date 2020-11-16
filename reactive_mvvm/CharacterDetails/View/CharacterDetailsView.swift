//
//  CharacterDetailsView.swift
//  reactivemvvm
//
//  Created by Francisco José Ruiz on 16/11/2020.
//  Copyright © 2020 Francisco José Ruiz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CharacterDetailsView: UIViewController {

    //MARK: IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var descriptionName: UILabel!
    @IBOutlet var titleLabels: [UILabel]!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var comicsName: UILabel!
    @IBOutlet weak var seriesName: UILabel!
    @IBOutlet weak var storiesName: UILabel!
    @IBOutlet weak var eventsName: UILabel!
    @IBOutlet weak var urlsName: UILabel!
    
    @IBOutlet weak var comicsAmount: UILabel!
    @IBOutlet weak var seriesAmount: UILabel!
    @IBOutlet weak var storiesAmount: UILabel!
    @IBOutlet weak var eventsAmount: UILabel!
    @IBOutlet weak var urlsAmount: UILabel!
    
    @IBOutlet weak var comicsButton: UIButton!
    @IBOutlet weak var seriesButton: UIButton!
    @IBOutlet weak var storiesButton: UIButton!
    @IBOutlet weak var eventsButton: UIButton!
    @IBOutlet weak var urlsButton: UIButton!
    
    
    //MARK: Constaints
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var topScrollView: NSLayoutConstraint!
    
    
    private lazy var characterElementsView = CharacterElementsView()
    
    //MARK: Viewmodel
    private var viewModel: CharacterDetailsViewModelProtocol!
    
    //MARK: Managers
    private var alertManager = AlertManager()
    
    //MARK: Rx
    private var disposeBag = DisposeBag()
    
    
    //MARK: Construct
    static func create(viewModel: CharacterDetailsViewModelProtocol) -> CharacterDetailsView {
        let vc = CharacterDetailsView(nibName: "CharacterDetailsView", bundle: nil)
        vc.viewModel = viewModel
        return vc
    }
    
    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        translate()
        setupBindings()
        viewModel.getData()
    }
    
    override func viewDidLayoutSubviews() {
        topScrollView.constant = -45
    }
    
    /// Configure status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func configureView() {
        /// Configure imageview
        imageHeight.constant = view.frame.width
    }
    
    private func translate() {
        titleName.text = Localizable.CharacterDetailsView.title.localized
        descriptionName.text = Localizable.CharacterDetailsView.description.localized
        
        comicsName.text = Localizable.CharacterDetailsView.comics.localized
        seriesName.text = Localizable.CharacterDetailsView.series.localized
        storiesName.text = Localizable.CharacterDetailsView.stories.localized
        eventsName.text = Localizable.CharacterDetailsView.events.localized
        urlsName.text = Localizable.CharacterDetailsView.urls.localized
    }
    
    private func setupBindings() {
        /// Set up viewmodel output
        let output = viewModel.transform(
            CharacterDetailsViewModel.Input(
                getComics: comicsButton.rx.tap.asObservable(),
                getSeries: seriesButton.rx.tap.asObservable(),
                getStories: storiesButton.rx.tap.asObservable(),
                getEvents: eventsButton.rx.tap.asObservable(),
                getUrls: urlsButton.rx.tap.asObservable()
            )
        )
        
        /// On handle error
        onHandleError(output)
        
        onFetchData(output)
        
        onGetResources(output)
    }
    
    private func onFetchData(_ output: CharacterDetailsViewModel.Output) {
        output.character.asObservable()
            .subscribe(
                onNext: { character in
                    self.loadCharacterDetails(character)
            }).disposed(by: disposeBag)
    }
    
    private func onGetResources(_ output: CharacterDetailsViewModel.Output) {
        output.comics.asObservable()
            .subscribe(onNext: { elements in
                var objs = [CharacterElement]()
                for elem in elements.items {
                    objs.append(
                        CharacterElement(title: elem.name, url: nil)
                    )
                }
                self.showElementDetails(objs)
            }).disposed(by: disposeBag)
        
        output.stories.asObservable()
            .subscribe(onNext: { elements in
                var objs = [CharacterElement]()
                for elem in elements.items {
                    objs.append(
                        CharacterElement(title: elem.name, url: nil)
                    )
                }
                self.showElementDetails(objs)
            }).disposed(by: disposeBag)
        
        output.urls.asObservable()
            .subscribe(onNext: { elements in
                var objs = [CharacterElement]()
                for elem in elements {
                    objs.append(
                        CharacterElement(title: elem.url, url: elem.url)
                    )
                }
                self.showElementDetails(objs)
            }).disposed(by: disposeBag)
    }
    
    private func showElementDetails(_ elements: [CharacterElement]) {
        characterElementsView = CharacterElementsView.create(
            title: titleLabels[0].text!, viewModel: CharacterElementsViewModel(elements: elements)
        )
        characterElementsView.modalPresentationStyle = .fullScreen
        self.present(characterElementsView, animated: true, completion: nil)
    }
    
    /// On handle Error
    private func onHandleError(_ output: CharacterDetailsViewModel.Output) {
        output.error.drive(
            onNext: {
                self.alertManager.showWarning(parentView: self.view, message: $0.title)
        }).disposed(by: disposeBag)
    }
    
    //MARK: Methods
    private func loadCharacterDetails(_ character: Character) {
        for label in titleLabels {
            label.text = character.name
        }
        
        if character.resultDescription == "" {
            descriptionName.isHidden = true
        }
        descriptionLabel.text = character.resultDescription
        
        if let image = character.thumbnail, let url = image.getUrl() {
            imageView.load(
                url: url,
                placeholder: UIImage(named: "ic_placeholder")
            )
        }
        
        /// Elements
        comicsAmount.text = Localizable.CharacterDetailsView.comics_amount
        .localized("\(character.comics.available)")
        
        seriesAmount.text = Localizable.CharacterDetailsView.series_amount
        .localized("\(character.series.available)")
        
        storiesAmount.text = Localizable.CharacterDetailsView.stories_amount
        .localized("\(character.stories.available)")
        
        eventsAmount.text = Localizable.CharacterDetailsView.events_amount
        .localized("\(character.events.available)")
        
        urlsAmount.text = Localizable.CharacterDetailsView.urls_amount
            .localized("\(character.urls.count)")
    }
    
    
    //MARK: IBActions
    @IBAction func dismissTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

