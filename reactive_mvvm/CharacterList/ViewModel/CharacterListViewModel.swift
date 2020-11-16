//
//  CharacterListViewModel.swift
//  reactive_mvvm
//
//  Created by Francisco José Ruiz on 15/11/2020.
//  Copyright © 2020 Francisco José Ruiz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol CharacterListViewModelProtocol {
    func transform(_ input: CharacterListViewModel.Input) -> CharacterListViewModel.Output
    func getData()
    func tableViewScroll(to index: Int)
    var output: CharacterListViewModel.Output! { get }
    var characters: [Character] { get set }
}

class CharacterListViewModel: CharacterListViewModelProtocol {
    
    //MARK: Managers
    private var apiManager = CharacterApiManager()
    
    
    //MARK: Properties
    var characters = [Character]()
    private var ds = DownloadPageStatus()

    
    //MARK: Rx
    private let disposeBag = DisposeBag()
    
    
    //MARK: Rx Subjects
    internal let characterFetchedSubject = PublishSubject<[Character]>()
    internal let downloadedFetchedSubject = PublishSubject<Bool>()
    internal let errorFetchedSubject = PublishSubject<CustomError>()
    
    
    //MARK: Input
    struct Input {
        /// String del searchbar para filtrar en local
        let filteredText: Observable<String>
        
        /// Recargar los datos
        let reloadData: Observable<Void>
    }
    
    //MARK: output
    struct Output {
        /// Texto del filtro
        let filter: Void
        
        /// Listado de películas filtradas o fin filtrar
        let characters: Driver<[Character]>
        
        /// Error
        let error: Driver<CustomError>
        
        /// Downloading
        let downloading: Driver<Bool>
    }
    
    private(set) var input: Input!
    private(set) var output: Output!
    
    //MARK: Transform
    func transform(_ input: Input) -> Output {
        self.input = input
        self.output = Output(
            filter: filterText(input),
            characters: characterFetch,
            error: ErrorFetch,
            downloading: downloaded
        )
        
        /// Subscribe reload data for Refresh control or fetch data
        input.reloadData.subscribe(
            onNext: {
                let page = self.ds.refreshDownload()
                self.getCharacters(page: page, byAppend: false)
        }).disposed(by: disposeBag)
        
        return output
    }
    
    
    //MARK: Methods
    func getData() {
        /// Ponemos nuestra variable de estado de "descargando" a true y obtenemos la siguiente página a descargar
        let page = self.ds.downloadNextPage()
        getCharacters(page: page, byAppend: true)
    }
    
    private func getCharacters(page: DownloadPageStatus.PageElements, byAppend: Bool) {
        self.downloadedFetchedSubject.asObserver().onNext(false)
        
        apiManager.getCharacterListWith(limit: "\(page.limit)", offset: "\(page.offset)")
        .subscribe(onNext: { characters in
            /// Si byAppend es true, añadimos los nuevos objetos al array de objetos actual
            if byAppend {
                self.characters += characters
            }
            else {
                self.characters = characters
            }
            
            self.characterFetchedSubject.asObserver().onNext(self.characters) /// Publicamos los objetos
            self.downloadedFetchedSubject.asObserver().onNext(true) /// Publicamos que hemos acabado de descargar
            self.ds.endDownloading() /// Ponemos nuestra variable de estado de "descargando" a false
            
        }, onError: { error in
            let e = error as! CustomError
            self.errorFetchedSubject.asObserver().onNext(e)
            self.downloadedFetchedSubject.asObserver().onNext(true)
            self.ds.endDownloadingWithError()
            
        }).disposed(by: disposeBag)
    }
    
    
    func tableViewScroll(to index: Int) {
        if availableDownload(index) {
            getData()
        }
    }
    
    /// Check characters index & is downloading
    private func availableDownload(_ index: Int) -> Bool {
        if index+1 >= characters.count && !ds.isDownloading {
            return true
        }
        return false
    }
}


//MARK: Output
extension CharacterListViewModel {
    func filterText(_ input: Input) {
        input.filteredText.subscribe(
            onNext: { text in
                if text.count == 0 {
                    self.characterFetchedSubject.asObserver().onNext(self.characters)
                    return
                }
                let filtered = self.characters.filter({ character in
                    return character.name.uppercased().contains(text.uppercased())
                })
                self.characterFetchedSubject.asObserver().onNext(filtered)
                
        }).disposed(by: disposeBag)
    }
    
    var downloaded: Driver<Bool> {
        downloadedFetchedSubject.asDriver(onErrorJustReturn: false)
    }
    
    var characterFetch: Driver<[Character]> {
        characterFetchedSubject.asDriver(onErrorDriveWith: Driver.never())
    }
    
    var ErrorFetch: Driver<CustomError> {
        errorFetchedSubject.asDriver(onErrorDriveWith: Driver.never())
    }
}

