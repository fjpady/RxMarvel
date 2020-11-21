//
//  CharacterDetailTest.swift
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

class CharacterDetailTest: XCTestCase {

    var viewModel: CharacterDetailsViewModel!
    var character: Character!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var apiManager: CharacterApiManager!
    
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.disposeBag = DisposeBag()
        self.apiManager = CharacterApiManager()
        
        let resultData = Bundle.main.decode(
            ResultData.self,
            from: "TestCharacterDetails.json"
        )
        self.character = resultData.getListOfCharacters().first!
        self.viewModel = CharacterDetailsViewModel(character: character, apiManager: apiManager)
    }
    
    override class func tearDown() {
        //self.viewModel = nil
        super.tearDown()
    }
    
    
    func testFetchCharacterDetailsCorrect() throws {
        /// EN este test el CharacterDetailsViewModel tiene que devolver el character con el que se creó,
        /// después se hace la llamada de charatcer details a la api para devolver el character mas completo
        /// y después el viewmodel lo devuelve de nuevo para pintarlo.
        let expectation = XCTestExpectation(description: "testFetchCharacterDetailsCorrect")
        let triggerVoid = scheduler.createHotObservable([.next(0, ())])
        
        
        let output = viewModel.transform(
            CharacterDetailsViewModel.Input(
                getComics: triggerVoid.asObservable(),
                getSeries: triggerVoid.asObservable(),
                getStories: triggerVoid.asObservable(),
                getEvents: triggerVoid.asObservable(),
                getUrls: triggerVoid.asObservable()
            )
        )
        
        var counter = 1
        
        output.character.drive(
            onNext: { character in
                if counter == 0 {
                    expectation.fulfill()
                }
                counter -= 1
        }).disposed(by: disposeBag)
        
        
        output.error.drive(
            onNext: { error in
                XCTFail("testFetchCharacterDetailsCorrect Failed \(error.title)")
        }).disposed(by: disposeBag)
        
        viewModel.getData()
        
        wait(for: [expectation], timeout: 8.0)
        
    }
    
   

}
