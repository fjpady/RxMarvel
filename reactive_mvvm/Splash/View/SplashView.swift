//
//  SplashView.swift
//  reactive_mvvm
//
//  Created by Francisco José Ruiz on 14/11/2020.
//  Copyright © 2020 Francisco José Ruiz. All rights reserved.
//

import UIKit

class SplashView: UIViewController {

    //MARK: IBOutlet
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        translate()
        configureView()
    }
    
    private func translate() {
        titleLabel.text = Localizable.SplashView.title.localized
        bodyLabel.text = Localizable.SplashView.list.localized
        continueButton.setTitle(
            Localizable.SplashView.continue.localized,
            for: .normal
        )
    }
    
    private func configureView() {
        /// Buttons
        continueButton.layer.cornerRadius = 10.0
    }
    

    //MARK: IBActions
    @IBAction func continueTapped(_ sender: Any) {
        let vc = LoginView.create(viewModel: LoginViewModel())
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
}
