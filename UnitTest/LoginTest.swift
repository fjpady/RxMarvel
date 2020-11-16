//
//  LoginTest.swift
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

class LoginTest: XCTestCase {

    var viewModel : LoginViewModel!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    //fileprivate var mock : MockLogin!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.disposeBag = DisposeBag()
        self.viewModel = LoginViewModel()
    }
    
    override class func tearDown() {
        //self.viewModel = nil
        //self.mock = nil
        super.tearDown()
    }
   
    func testMail() throws {
        let result = scheduler.createObserver(Bool.self)
        
        let triggerVoid = scheduler.createHotObservable([.next(0, ())])
        let trigger1 = scheduler.createHotObservable(
            [
                .next(0, "valido@valido.com"), /// Valid
                .next(0, "valido@hola.es"), /// Valid
                .next(0, "valido@123.es"), /// Valid
                .next(0, "invalido"),
                .next(0, "invalido@hola"),
            ]
        )
        
        let output = viewModel.transform(
            LoginViewModel.Input(
                emailText: trigger1.asObservable(),
                passwordText: trigger1.asObservable(),
                buttonTap: triggerVoid.asObservable()
            )
        )
        
        output.validableMail
        .drive(result)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(
            result.events,
            [
                .next(0, true),
                .next(0, true),
                .next(0, true),
                .next(0, false),
                .next(0, false)
            ],
            "Error al validar email"
        )
    }
    
    
    func testPassword() throws {
        let result = scheduler.createObserver(Bool.self)
        
        let triggerVoid = scheduler.createHotObservable([.next(0, ())])
        let trigger1 = scheduler.createHotObservable(
            [
                .next(0, "123456"), /// Valid
                .next(0, "asdfgh"), /// Valid
                .next(0, "123"),
                .next(0, "asd"),
                .next(0, "12345"),
            ]
        )
        
        let output = viewModel.transform(
            LoginViewModel.Input(
                emailText: trigger1.asObservable(),
                passwordText: trigger1.asObservable(),
                buttonTap: triggerVoid.asObservable()
            )
        )
        
        output.validablePassword
        .drive(result)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        print(result.events)
        XCTAssertEqual(
            result.events,
            [
                .next(0, true),
                .next(0, true),
                .next(0, false),
                .next(0, false),
                .next(0, false)
            ],
            "Error al validar password"
        )
    }
    
    
}


