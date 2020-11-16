//
//  Constants.swift
//  reactive_mvvm
//
//  Created by Francisco José Ruiz on 15/11/2020.
//  Copyright © 2020 Francisco José Ruiz. All rights reserved.
//

import Foundation

/// global locale
var locale = "es"

struct Constants {
    
    /// Global url vars
    struct Storyboards {
        static let Main = "Main"
    }
    
    /// Global url vars
    struct global_urls {
        static let `protocol` = "https://%@"
        static let url_name = "gateway.marvel.com"
        static let api_version = "/v1"
    }
    
    struct api_keys {
        static let `public` = ""
        static let `private` = ""
    }
    
    
    /// API vars
    static let api_url = String(format: global_urls.protocol, global_urls.url_name)
    
    
    struct Character {
        static let list = "\(Constants.api_url)\(global_urls.api_version)/public/characters"
        static let details = "\(Constants.api_url)\(global_urls.api_version)/public/characters/%@"
    }
    
}
