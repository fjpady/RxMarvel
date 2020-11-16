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
        static let `public` = "7c02c27437aa8d5892e6018c6dac3b1a"
        static let `private` = "b728c42f5b54f8ad3d45f56b8a9baba8678d732d"
    }
    
    
    /// API vars
    static let api_url = String(format: global_urls.protocol, global_urls.url_name)
    
    
    struct Character {
        static let list = "\(Constants.api_url)\(global_urls.api_version)/public/characters"
        static let details = "\(Constants.api_url)\(global_urls.api_version)/public/characters/%@"
    }
    
}
