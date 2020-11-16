//
//  CharacterElementsViewModel.swift
//  rxmarvel
//
//  Created by Francisco José Ruiz on 16/11/2020.
//  Copyright © 2020 Francisco José Ruiz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol CharacterElementsViewModelProtocol {
    func transform(_ input: CharacterElementsViewModel.Input) -> CharacterElementsViewModel.Output
}

class CharacterElementsViewModel: CharacterElementsViewModelProtocol {
    
    //MARK: Managers
    private var apiManager = CharacterApiManager()
    
    //MARK: Properties
    private var elements: [CharacterElement]!
    
    //MARK: Rx
    private let disposeBag = DisposeBag()
    
    
    //MARK: Rx Subjects
    internal let fetchedSubject: BehaviorSubject<[CharacterElement]>!
    
    
    //MARK: Input
    struct Input {
    }
    
    //MARK: output
    struct Output {
        /// elements
        let elements: Driver<[CharacterElement]>
    }
    
    private(set) var input: Input!
    private(set) var output: Output!
    
    
    //MARK: Construct
    init(elements: [CharacterElement]) {
        self.elements = elements
        self.fetchedSubject = BehaviorSubject<[CharacterElement]>(value: elements)
    }
    
    //MARK: Transform
    func transform(_ input: Input) -> Output {
        self.input = input
        self.output = Output(
            elements: fetch
        )
        
        return output
    }
    
    
    //MARK: Methods
  
    
    
    
}
//MARK: Output
extension CharacterElementsViewModel {
   var fetch: Driver<[CharacterElement]> {
       fetchedSubject.asDriver(onErrorDriveWith: Driver.never())
   }
}

