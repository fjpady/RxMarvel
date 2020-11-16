//
//  ValidableLabel.swift
//  reactive_mvvm
//
//  Created by Francisco José Ruiz on 15/11/2020.
//  Copyright © 2020 Francisco José Ruiz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class ValidableLabel: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.text = ""
    }
    
    func showInvalid(message: String) {
        self.text = message
        self.textColor = .red
    }
    
    func showValid(message: String) {
        self.text = message
        self.textColor = .green
    }
    
}
