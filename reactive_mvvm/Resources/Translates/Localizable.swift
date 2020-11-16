//
//  Localizable.swift
//  reactive_mvvm
//
//  Created by Francisco José Ruiz on 15/11/2020.
//  Copyright © 2020 Francisco José Ruiz. All rights reserved.
//

import Foundation

enum Localizable {

    //MARK: Fields
    enum Common: String, LocalizableDelegate {
        case invalid_password = "Common.invalid_password"
        case invalid_email = "Common.invalid_email"
        case valid_password = "Common.valid_password"
        case valid_email = "Common.valid_email"
        case fill_fields = "Common.fill_fields"
        case no_internet_connection = "Common.no_internet_connection"
    }
    
    
    enum LoginView: String, LocalizableDelegate {
        case title = "LoginView.title"
        case mail_label = "LoginView.mail_label"
        case mail_placeholder = "LoginView.mail_placeholder"
        case password_label = "LoginView.password_label"
        case password_placeholder = "LoginView.password_placeholder"
        case login_button = "LoginView.login_button"
        case hint_connection = "LoginView.hint_connection"
        
    }
    
    enum CharacterDetailsView: String, LocalizableDelegate {
        case title = "CharacterDetailsView.title"
        case `description` = "CharacterDetailsView.description"
        case comics = "CharacterDetailsView.comics"
        case series = "CharacterDetailsView.series"
        case stories = "CharacterDetailsView.stories"
        case events = "CharacterDetailsView.events"
        case urls = "CharacterDetailsView.urls"
        
        case comics_amount = "CharacterDetailsView.comics_amount"
        case series_amount = "CharacterDetailsView.series_amount"
        case stories_amount = "CharacterDetailsView.stories_amount"
        case events_amount = "CharacterDetailsView.events_amount"
        case urls_amount = "CharacterDetailsView.urls_amount"
    }
    
    enum CharacterListView: String, LocalizableDelegate {
        case title = "CharacterListView.title"
        case search_bar = "CharacterListView.search_bar"
    }
    
    
    enum SplashView: String, LocalizableDelegate {
        case title = "SplashView.title"
        case list = "SplashView.list"
        case `continue` = "SplashView.continue"
    }
    
    enum CharacterCell: String, LocalizableDelegate {
        case title = "CharacterCell.title"
        case `description` = "CharacterCell.description"
    }
}


protocol LocalizableDelegate {
    var rawValue: String { get }    //localize key
    var table: String? { get }
    var localized: String { get }
}
extension LocalizableDelegate {

    func localized(_ obj: Any?) -> String {
        var translation: String! = ""
        if obj is Int {
            let txt = Bundle.main.localizedString(forKey: rawValue, value: nil, table: table)
            translation = String(format: txt, obj as! Int)
        }
        if obj is String {
            let txt = Bundle.main.localizedString(forKey: rawValue, value: nil, table: table)
            translation = String(format: txt, obj as! String)
        }
        return translation
    }
    
    //returns a localized value by specified key located in the specified table
    var localized: String {
        return Bundle.main.localizedString(forKey: rawValue, value: nil, table: table)
    }

    // file name, where to find the localized key
    // by default is the Localizable.string table
    var table: String? {
        return nil
    }
}

