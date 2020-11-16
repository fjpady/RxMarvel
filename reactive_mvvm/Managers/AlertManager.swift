//
//  AlertManager.swift
//  reactive_mvvm
//
//  Created by Francisco José Ruiz on 15/11/2020.
//  Copyright © 2020 Francisco José Ruiz. All rights reserved.
//

import UIKit

class AlertManager {
    
    /// Alert View
    var alertViews = [UIView]()
    
    // -- Warning alert
    func showWarning(parentView: UIView, message: String = "Texto de aviso ...") {
        
        /// Alert configuration
        let width = parentView.frame.width
        let height: CGFloat = 130.0
        
        /// Create alert view
        let alertView = UIView(frame: CGRect( x: 0, y: 0, width: width, height: height))
        alertView.translatesAutoresizingMaskIntoConstraints = false
        
        alertView.backgroundColor = .systemOrange
        
        /// Create alert label
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0,height: 0))
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.numberOfLines = 3
        label.text = message
        label.textColor = .white
        
        /// Add label to alert view
        alertView.addSubview(label)
        
        /// Add alertView to main view
        parentView.addSubview(alertView)
        
        /// Add constraints
        /// 1. Espacios laterales y superior
        NSLayoutConstraint.activate([
            NSLayoutConstraint(
                item: alertView,
                attribute: .top,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .top,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: alertView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .leading,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: alertView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .trailing,
                multiplier: 1,
                constant: 0
            )
        ])
        
        /// 2. Height
        NSLayoutConstraint.activate([
            NSLayoutConstraint(
                item: alertView,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: height
            )
        ])
        
        /// 3. Espacios para la label
        NSLayoutConstraint.activate([
            NSLayoutConstraint(
                item: label,
                attribute: .top,
                relatedBy: .equal,
                toItem: alertView,
                attribute: .top,
                multiplier: 1,
                constant: 10
            ),
            NSLayoutConstraint(
                item: label,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: alertView,
                attribute: .bottom,
                multiplier: 1,
                constant: 10
            ),
            NSLayoutConstraint(
                item: label,
                attribute: .left,
                relatedBy: .equal,
                toItem: alertView,
                attribute: .left,
                multiplier: 1,
                constant: 10
            ),
            NSLayoutConstraint(
                item: label,
                attribute: .right,
                relatedBy: .equal,
                toItem: alertView,
                attribute: .right,
                multiplier: 1,
                constant: 10
            )
        ])
        
        /// Add alertview to list
        alertViews.append(alertView)
        
        /// Create timer to hide alertview
        let _ = Timer.scheduledTimer(
            timeInterval: 3,
            target: self,
            selector: #selector(autoHideAlertView(timer:)),
            userInfo: ["alertView": alertView],
            repeats: false
        )
        
        /// Animate alertview
        alertView.animShow()
        
    }
    
    // - Timer para ocultar la alertview
    @objc func autoHideAlertView(timer: Timer) {
        if let userInfo = timer.userInfo as? [String: UIView], let alertView = userInfo["alertView"] {
            alertView.animHide()
            timer.invalidate()
        }
    }
}

//MARK: Extensiones de UIView para la clase AlertManager
extension UIView{
    
    // - Función para mostrar la alertview
    func animShow(_ tirme: Double = 0.2){
        UIView.animate(
            withDuration: tirme,
            delay: 0,
            options: [.curveEaseIn],
            animations: {
                self.center.y += self.bounds.height
                self.layoutIfNeeded()
        },
        completion: nil
        )
        self.isHidden = false
    }
    
    // - Función para ocultar la alertview
    func animHide(_ time: Double = 0.2){
        UIView.animate(
            withDuration: time,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                self.center.y -= self.bounds.height
                self.layoutIfNeeded()
            },
            completion: {(_ completed: Bool) -> Void in
                self.removeFromSuperview()
            }
        )
    }
    
}
