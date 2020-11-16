//
//  CharacterApiManager.swift
//  reactive_mvvm
//
//  Created by Francisco José Ruiz on 16/11/2020.
//  Copyright © 2020 Francisco José Ruiz. All rights reserved.
//

import Foundation
import RxSwift

class CharacterApiManager {
    
    var disposeBag = DisposeBag()
    
    
    // - Función para obtener el listado de personajes
    func getCharacterListWith(limit: String?, offset: String?, name: String? = nil) -> Observable<[Character]> {
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
    
    
    // - Función para obtener el detalle del personaje
    func getCharacterDetails(id: Int) -> Observable<Character> {
        let request = Request()
        
        return Observable.create { observer in
            let url = String(format: Constants.Character.details, "\(id)")
            request.regular(url: url)
                .subscribe(
                    onNext: { data in
                        do {
                            let decoder = JSONDecoder()
                            let result = try decoder.decode(ResultData.self, from: data)
                            
                            if let character = result.getListOfCharacters().first {
                                observer.onNext(character)
                            }
                            else {
                                let ce = CustomError(title: "Character not found")
                                observer.onError(ce)
                            }
                            
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
