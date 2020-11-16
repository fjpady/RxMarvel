//
//  LoginViewModel.swift
//  reactive_mvvm
//
//  Created by Francisco José Ruiz on 14/11/2020.
//  Copyright © 2020 Francisco José Ruiz. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol LoginViewModelProtocol {
    func transform(_ input: LoginViewModel.Input) -> LoginViewModel.Output
    var disposeBag: DisposeBag { get }
}

class LoginViewModel: LoginViewModelProtocol {
    
    //MARK: Properties
    /// BehaviorSubject - When you subscribe to it, you will get the latest value emitted by the Subject, and then the values emitted after the subscription.
    internal let messageSubject = PublishSubject<String>()
    
    
    /// PublishSubject - When you subscribe to it, you will only get the values that were emitted after the subscription.
    internal let loginEventSubject = PublishSubject<Void>()
    internal let mailFieldValidationSubject = PublishSubject<String>()
    
    // MARK: - Bindings
    struct Input {
        /// String del email
        let emailText: Observable<String>
        
        /// String de la password
        let passwordText: Observable<String>
        
        /// Listener del tap del botón login
        let buttonTap: Observable<Void>
    }
    
    struct Output {
        /// Label para la validación de los datos del mail y password
        let validableMail: Driver<Bool>
        let validablePassword: Driver<Bool>
        
        let validableMailIsHidden: Driver<Bool>
        let validablePasswordIsHidden: Driver<Bool>
        
        /// Estado del botón del login {enabled / disabled}
        let loginButtonIsEnabled: Driver<Bool>
        
        /// Listener para el completion del login
        let loginSuccessful: Driver<Void>
    }
    
    private(set) var input: Input!
    private(set) var output: Output!
    
    //MARK: Rx
    internal var disposeBag = DisposeBag()
    
    
    //MARK: Methods
    func transform(_ input: Input) -> Output {
        self.input = input
        self.output = Output(
            validableMail: validableMail(input),
            validablePassword: validablePassword(input),
            validableMailIsHidden: validableMailIsHidden(input),
            validablePasswordIsHidden: validablePasswordIsHidden(input),
            loginButtonIsEnabled: loginButtonIsEnabled(input),
            loginSuccessful: loginSuccessful
        )
        
        handleLoginButtonTap(input)
        
        return output
    }
   
    
    func handleLoginButtonTap(_ input: Input) {
        input
            .buttonTap
            .subscribe(
                onNext: { _ in
                    self.loginEventSubject.asObserver().on(.next(()))
            }
        ).disposed(by: disposeBag)
        
        //result.map { _ in }.subscribe(loginEventSubject).disposed(by: disposeBag)
    }
    
}

//MARK: Output
extension LoginViewModel {
    func validableMail(_ input: Input) -> Driver<Bool> {
        input.emailText.map { string in
            if string.count == 0 { return false }
            
            if string.isValidEmail() {
                return true
            }
            else {
                return false
            }
            
        }.asDriver(onErrorJustReturn: false)
    }
    
    func validablePassword(_ input: Input) -> Driver<Bool> {
        input.passwordText.map { string in
            if string.count == 0 { return false }
            
            if string.isValidPassword() {
                return true
            }
            else {
                return false
            }
            
        }.asDriver(onErrorJustReturn: false)
    }
    
    func validableMailIsHidden(_ input: Input) -> Driver<Bool> {
        input.emailText.map { string in
            string.count == 0
        }.asDriver(onErrorJustReturn: true)
    }
    
    func validablePasswordIsHidden(_ input: Input) -> Driver<Bool> {
        input.passwordText.map { string in
            string.count == 0
        }.asDriver(onErrorJustReturn: true)
    }
    
    func loginButtonIsEnabled(_ input: Input) -> Driver<Bool> {
        Observable
            .combineLatest(input.emailText, input.passwordText)
            .map { email, pass in
                email.isValidEmail() && pass.isValidPassword()
            }.asDriver(onErrorJustReturn: false)
    }
    
    var loginSuccessful: Driver<Void> {
        loginEventSubject.asDriver(onErrorDriveWith: Driver.never())
    }
}
