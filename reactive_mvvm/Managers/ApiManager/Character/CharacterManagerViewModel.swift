//
//  CharacterManagerViewModel.swift
//  rxmarvel
//
//  Created by Francisco José Ruiz on 16/11/2020.
//  Copyright © 2020 Francisco José Ruiz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol CharacterManagerViewModelProtocol {
    
}

//MARK: DELETEME
//TODO: DELETEME
class CharacterManagerViewModel: CharacterManagerViewModelProtocol {
    
    //MARK: Structs
    struct DownloadPageStatus {
        struct PageElements {
            var offset: Int = 0
            var limit: Int = 100
        }
        private(set) var isDownloading: Bool = false
        private(set) var page = PageElements()
        private var firstDownload = true
        
        /// Descargamos la siguiente página
        mutating func downloadNextPage() -> PageElements {
            if !firstDownload {
                page.offset += 100
            }
            firstDownload = false
            isDownloading = true
            
            return PageElements(offset: page.offset, limit: page.limit)
        }
        
        /// Recargamos todos los elementos
        mutating func refreshDownload() -> PageElements {
            isDownloading = true
            return PageElements(offset: 0, limit: page.limit)
        }
        
        mutating func endDownloading() {
            isDownloading = false
        }
        mutating func endDownloadingWithError() {
            page.offset -= 100
            isDownloading = false
        }
    }
    
    //MARK: Rx
    var disposeBag = DisposeBag()
    
    //MARK: Rx Subjects
    internal let dataFetchedSubject = PublishSubject<[Character]>()
    internal let isDownloadingFetchedSubject = PublishSubject<Bool>()
    internal let errorFetchedSubject = PublishSubject<CustomError>()
    
    //MARK: ApiManager
    var apiManager = CharacterApiManager()
    
    
    //MARK: Input
    struct Input {
        /// Recargar los datos desde el principio
        let downloadData: Observable<Void>
        
        /// Obtener siguiente página
        let downloadNextData: Observable<Bool>
    }
    
    
    //MARK: output
    struct Output {
        /// Listado de objetos
        let elements: Driver<[Character]>
        
        /// Error devuelto por la API
        let error: Driver<CustomError>
        
        /// Descargando?
        let isDownloading: Driver<Bool>
    }
    
    
    private(set) var input: Input!
    private(set) var output: Output!
    
    //MARK: Transform
    func transform(_ input: Input) -> Output {
        self.input = input
        self.output = Output(
            elements: dataFetch,
            error: errorFetch,
            isDownloading: downloading
        )
        
        downloadData(input)
        downloadNextData(input)
        
        return output
    }
    
    private func downloadData(_ input: Input) {
        input.downloadData.subscribe(
            onNext: {
                
        }).disposed(by: disposeBag)
    }
    
    private func downloadNextData(_ input: Input) {
        input.downloadNextData.subscribe(
            onNext: { result in
                
        }).disposed(by: disposeBag)
    }
    
    //MARK: MEthods
    private func getCharacterListWith(limit: String?, offset: String?, name: String? = nil) -> Observable<[Character]> {
        let request = Request()
        
        return Observable.create { observer in
            let params = self.addPageParameters(limit: limit, offset: offset, name: name)
            
            let url = Constants.Character.list
            request.regular(url: url, extraParams: params)
                .subscribe(
                    onNext: { data in
                        do {
                            let decoder = JSONDecoder()
                            let result = try decoder.decode(ResultData.self, from: data)
                            
                            observer.onNext(result.getListOfCharacters())
                        }
                        catch let error {
                            print("API_ERROR: \(error.localizedDescription)")
                            let ce = CustomError(title: error.localizedDescription)
                            observer.onError(ce)
                        }
                    },
                    onError: { error in
                        let ce = CustomError(title: error.localizedDescription)
                        observer.onError(ce)
                    },
                    onCompleted: {
                        observer.onCompleted()
                    }
                )
                .disposed(by: self.disposeBag)
            
            return Disposables.create{}
        }
        
    }
    
    
    private func addPageParameters(limit: String?, offset: String?, name: String?) -> String {
        return (name != nil ? ("&nameStartsWith=" + name!) : "") + (offset != nil ? ("&offset=" + offset!) : "") + (limit != nil ? ("&limit=" + limit!) : "")
    }
}

//MARK: Output
extension CharacterManagerViewModel {
    var downloading: Driver<Bool> {
        isDownloadingFetchedSubject.asDriver(onErrorJustReturn: false)
    }
    
    var errorFetch: Driver<CustomError> {
        errorFetchedSubject.asDriver(onErrorDriveWith: Driver.never())
    }
    
    var dataFetch: Driver<[Character]> {
        dataFetchedSubject.asDriver(onErrorDriveWith: Driver.never())
    }
}

