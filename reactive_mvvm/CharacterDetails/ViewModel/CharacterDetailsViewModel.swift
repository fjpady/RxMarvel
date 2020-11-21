//
//  CharacterDetailsViewModel.swift
//  rxmarvel
//
//  Created by Francisco José Ruiz on 16/11/2020.
//  Copyright © 2020 Francisco José Ruiz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol CharacterDetailsViewModelProtocol {
    func getData()
    func transform(_ input: CharacterDetailsViewModel.Input) -> CharacterDetailsViewModel.Output
}

class CharacterDetailsViewModel: CharacterDetailsViewModelProtocol {
    
    //MARK: Construct
    init(character: Character, apiManager: CharacterApiManagerProtocol) {
        self.character = character
        self.apiManager = apiManager
        
        /// Esta variable es BehaviorSubject para que cuando entremos en la vista tengamos cargado el último valor, osea, el que teníamos en el listado. Después se descarga de la API el nuevo valor para la variable ya mas completo.
        self.characterFetchedSubject = BehaviorSubject<Character>(value: character)
    }
    
    //MARK: Managers
    private var apiManager: CharacterApiManagerProtocol!
    
    //MARK: Properties
    private var character: Character!
    
    //MARK: Rx
    private let disposeBag = DisposeBag()
    
    
    //MARK: Rx Subjects
    internal let characterFetchedSubject: BehaviorSubject<Character>!
    internal let comicsFetchedSubject = PublishSubject<Comics>()
    internal let storiesFetchedSubject = PublishSubject<Stories>()
    internal let urlsFetchedSubject = PublishSubject<[URLElement]>()
    internal let errorFetchedSubject = PublishSubject<CustomError>()
    
    
    //MARK: Input
    struct Input {
        let getComics: Observable<Void>
        let getSeries: Observable<Void>
        let getStories: Observable<Void>
        let getEvents: Observable<Void>
        let getUrls: Observable<Void>
    }
    
    //MARK: output
    struct Output {
        /// Personaje
        let character: Driver<Character>
        
        let comics: Driver<Comics>
        let stories: Driver<Stories>
        let urls: Driver<[URLElement]>
        
        /// Error
        let error: Driver<CustomError>
    }
    
    
    //MARK: Transform
    func transform(_ input: Input) -> Output {
        let output = Output(
            character: characterFetch,
            comics: comicsFetch,
            stories: storiesFetch,
            urls: urlsFetch,
            error: errorFetch
        )
        
        getResources(input)
        
        return output
    }
    
    func getResources(_ input: Input) {
        input.getComics.subscribe(
            onNext: {
                if !self.character.comics.items.isEmpty {
                    self.comicsFetchedSubject.asObserver().onNext(self.character.comics)
                }
        }).disposed(by: disposeBag)
        
        input.getSeries.subscribe(
            onNext: {
                if !self.character.series.items.isEmpty {
                    self.comicsFetchedSubject.asObserver().onNext(self.character.series)
                }
        }).disposed(by: disposeBag)
        
        input.getStories.subscribe(
            onNext: {
                if !self.character.stories.items.isEmpty {
                    self.storiesFetchedSubject.asObserver().onNext(self.character.stories)
                }
        }).disposed(by: disposeBag)
        
        input.getEvents.subscribe(
            onNext: {
                if !self.character.events.items.isEmpty {
                    self.comicsFetchedSubject.asObserver().onNext(self.character.events)
                }
        }).disposed(by: disposeBag)
        
        input.getUrls.subscribe(
            onNext: {
                if !self.character.urls.isEmpty {
                    self.urlsFetchedSubject.asObserver().onNext(self.character.urls)
                }
        }).disposed(by: disposeBag)
    }
    
    //MARK: Methods
    func getData() {
        apiManager
            .getCharacterDetails(id: character.id)
            .subscribe(onNext: { character in
                self.character = character
                self.characterFetchedSubject.asObserver().onNext(self.character)
                
            }, onError: { error in
                let e = error as! CustomError
                self.errorFetchedSubject.asObserver().onNext(e)
                
            }).disposed(by: disposeBag)
    }
    
    
    
}
//MARK: Output
extension CharacterDetailsViewModel {
    var characterFetch: Driver<Character> {
        characterFetchedSubject.asDriver(onErrorDriveWith: Driver.never())
    }
    
    var comicsFetch: Driver<Comics> {
        comicsFetchedSubject.asDriver(onErrorDriveWith: Driver.never())
    }
    var storiesFetch: Driver<Stories> {
        storiesFetchedSubject.asDriver(onErrorDriveWith: Driver.never())
    }
    var urlsFetch: Driver<[URLElement]> {
        urlsFetchedSubject.asDriver(onErrorDriveWith: Driver.never())
    }
    
    var errorFetch: Driver<CustomError> {
        errorFetchedSubject.asDriver(onErrorDriveWith: Driver.never())
    }
}

