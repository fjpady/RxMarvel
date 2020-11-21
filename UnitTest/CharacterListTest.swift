//
//  CharacterListTest.swift
//  UnitTest
//
//  Created by Francisco José Ruiz on 16/11/2020.
//  Copyright © 2020 Francisco José Ruiz. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import Foundation

@testable import rxmarvel

class CharacterListTest: XCTestCase {

    var viewModel : CharacterListViewModelProtocol!
    var apiManager: CharacterApiManager!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.disposeBag = DisposeBag()
        self.apiManager = CharacterApiManager()
        self.viewModel = CharacterListViewModel(apiManager: apiManager)
    }
    
    override class func tearDown() {
        //self.viewModel = nil
        super.tearDown()
    }
    
    func testFetchCharactersCorrect() throws {
        let expectation = XCTestExpectation(description: "testFetchCharactersCorrect")
        let trigger = scheduler.createHotObservable([.next(0, "best")])
        let triggerReload = scheduler.createHotObservable([.next(0, ())])
        
        let output = viewModel.transform(
            CharacterListViewModel.Input(
                filteredText: trigger.asObservable(),
                reloadData: triggerReload.asObservable()
            )
        )
        
        output.characters.drive(
            onNext: { character in
                expectation.fulfill()
        }).disposed(by: disposeBag)
        
        output.error.drive(
            onNext: { error in
                XCTFail("testFetchCharactersCorrect Failed \(error.title)")
        }).disposed(by: disposeBag)
        
        viewModel.getData()
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    
    
    func testFilterCorrect() throws {
        let triggerReload = scheduler.createHotObservable([.next(0, ())])
        let result = scheduler.createObserver([Character].self)

        let apiManager = MockCharacterListApiManager()
        let viewModel = CharacterListViewModel(apiManager: apiManager)
        
        let resultData = Bundle.main.decode(ResultData.self, from: "TestFilterCharacters.json")
        let characters = resultData.getListOfCharacters()
        let character0 = characters[0] // Personaje 00
        let character1 = characters[1] // Personaje 01
        let character2 = characters[2] // Personaje 02
        let character3 = characters[3] // Personaje 03
        let character4 = characters[4] // Personaje 04
        
        
        /// Set up trigger
        let trigger = scheduler.createHotObservable(
            [
                .next(0, "Personaje"),
                .next(0, "Personaje 0"),
                .next(0, "Personaje 01"),
                .next(0, "Personaje 04"),
                .next(0, "PERSONAJE"),
                .next(0, "personaje"),
                .next(0, "e 0"),
                .next(0, "nada")
            ]
        )
        
        let output = viewModel.transform(
            CharacterListViewModel.Input(
                filteredText: trigger.asObservable(),
                reloadData: triggerReload.asObservable()
            )
        )
        
        output.characters
        .drive(result)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        /// La primera vez los devuelve todos por cargarlos de la API.
        /// La segunda vez filtra
        XCTAssertEqual(
            result.events,
            [
                .next(0, [character0, character1, character2, character3, character4]), /// MOCK api fetch
                .next(0, [character0, character1, character2, character3, character4]),
                .next(0, [character0, character1, character2, character3, character4]),
                .next(0, [character1]),
                .next(0, [character4]),
                .next(0, [character0, character1, character2, character3, character4]),
                .next(0, [character0, character1, character2, character3, character4]),
                .next(0, [character0, character1, character2, character3, character4]),
                .next(0, [])
            ],
            "El resultado no ha sido el esperado"
        )
        
        
    }
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

}

class MockCharacterListApiManager: CharacterApiManagerProtocol {
    var disposeBag = DisposeBag()
    
    // - Función para obtener el listado de personajes
    func getCharacterListWith(limit: String?, offset: String?, name: String? = nil) -> Observable<[Character]> {
        
        return Observable.create { observer in
            let resultData = Bundle.main.decode(ResultData.self, from: "TestFilterCharacters.json")
            let characters = resultData.getListOfCharacters()
            observer.onNext(characters)
            return Disposables.create{}
        }
        
    }
    
    func getCharacterDetails(id: Int) -> Observable<Character> {
        return Observable.create { observer in
            return Disposables.create{}
        }
    }
}
