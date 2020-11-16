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
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.disposeBag = DisposeBag()
        self.viewModel = CharacterListViewModel()
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
        
        let resultData = Bundle.main.decode(ResultData.self, from: "TestFilterCharacters.json")
        let characters = resultData.getListOfCharacters()
        
        let character0 = characters[0] // Personaje 00
        let character1 = characters[1] // Personaje 01
        let character2 = characters[2] // Personaje 02
        let character3 = characters[3] // Personaje 03
        let character4 = characters[4] // Personaje 04
        
        viewModel.characters = [character0, character1, character2, character3, character4]
        
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
        
        
        XCTAssertEqual(
            result.events,
            [
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

