//
//  LoginView.swift
//  reactive_mvvm
//
//  Created by Francisco José Ruiz on 14/11/2020.
//  Copyright © 2020 Francisco José Ruiz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginView: UIViewController {

    //MARK: Construct
    static func create(viewModel: LoginViewModelProtocol) -> LoginView {
        let vc = UIStoryboard(
            name: Constants.Storyboards.Main,
            bundle: nil
        ).instantiateViewController(
            withIdentifier: "LoginView"
        ) as! LoginView
        vc.viewModel = viewModel
        return vc
    }
    
    //MARK: IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var mailValidableLabel: UILabel!
    @IBOutlet weak var passwordValidableLabel: UILabel!
    
    
    // This constraint ties an element at zero points from the bottom layout guide
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
    //MARK: Managers
    var alertManager = AlertManager()
    
    //MARK: ViewControllers
    private lazy var characterListView = CharacterListView()
    
    //MARK: Properties
    var viewModel: LoginViewModelProtocol!
    
    
    //MARK: Rx
    private var disposeBag = DisposeBag()
    
    
    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        translate()
        configureView()
        setupBindings()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func translate() {
        /// Translate labels
        titleLabel.text = Localizable.LoginView.title.localized
        mailLabel.text = Localizable.LoginView.mail_label.localized
        
        /// Translate textfields
        mailTextField.placeholder = Localizable.LoginView.mail_placeholder.localized
        passwordLabel.text = Localizable.LoginView.password_label.localized
        passwordTextField.placeholder = Localizable.LoginView.password_placeholder.localized
        hintLabel.text = Localizable.LoginView.hint_connection.localized
        
        /// Translate buttons
        loginButton.setTitle(
            Localizable.LoginView.login_button.localized,
            for: .normal
        )
    }
    
    private func configureView() {
        /// Add corners to textfields & textviews
        mailTextField.layer.cornerRadius = 10.0
        passwordTextField.layer.cornerRadius = 10.0
        
        /// UIButtons
        loginButton.layer.cornerRadius = 10.0
        
        /// Delegates
        mailTextField.delegate = self
        passwordTextField.delegate = self
        
        /// Keyboard
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardNotification(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    private func setupBindings() {
        /// Set up viewmodel output
        let output = viewModel.transform(
            LoginViewModel.Input(
                emailText: mailTextField.rx.text.orEmpty.asObservable(),
                passwordText: passwordTextField.rx.text.orEmpty.asObservable(),
                buttonTap: loginButton.rx.tap.asObservable()
            )
        )
        output.loginSuccessful.drive(onNext: goToCharacterList).disposed(by: disposeBag)
        
        /// Set up validable messages.
        setupValidables(output)
    }
    
    
    /// Función para animar la view para que el textfield cuando aparezca el teclado, quede siempre visible
    @objc func keyboardNotification(notification: NSNotification) {
        UIViewHelper.keyBoardAppears(notification: notification, view: view, keyboardHeightLayoutConstraint: keyboardHeightLayoutConstraint)
    }
    
    
    //MARK: Methods
    private func setupValidables(_ output: LoginViewModel.Output) {
        /// Hides
        output.loginButtonIsEnabled.drive(loginButton.rx.isEnabled).disposed(by: disposeBag)
        output.validableMailIsHidden.drive(mailValidableLabel.rx.isHidden).disposed(by: disposeBag)
        output.validablePasswordIsHidden.drive(passwordValidableLabel.rx.isHidden).disposed(by: disposeBag)
        
        /// Check valid mail
        output.validableMail.drive(
            onNext: {
                if $0 {
                    self.mailValidableLabel.text = Localizable.Common.valid_email.localized
                    self.mailValidableLabel.textColor = .systemGreen
                }
                else {
                    self.mailValidableLabel.text = Localizable.Common.invalid_email.localized
                    self.mailValidableLabel.textColor = .systemRed
                }
            }
        ).disposed(by: disposeBag)
        
        /// Check valid password
        output.validablePassword.drive(
            onNext: {
               if $0 {
                    self.passwordValidableLabel.text = Localizable.Common.valid_password.localized
                    self.passwordValidableLabel.textColor = .systemGreen
                }
                else {
                    self.passwordValidableLabel.text = Localizable.Common.invalid_password.localized
                    self.passwordValidableLabel.textColor = .systemRed
                }
            }
        ).disposed(by: disposeBag)
    }
    
    private func goToCharacterList() {
        characterListView = CharacterListView.create(viewModel: CharacterListViewModel())
        characterListView.modalPresentationStyle = .fullScreen
        self.present(characterListView, animated: true, completion: nil)
    }
    
}

//MAKR: UITextFieldDelegate
extension LoginView: UITextFieldDelegate {
    
    /// When press return, hide keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}
