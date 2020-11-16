//
//  DownloadPageStatus.swift
//  rxmarvel
//
//  Created by Francisco José Ruiz on 15/11/2020.
//  Copyright © 2020 Francisco José Ruiz. All rights reserved.
//

import Foundation

//MARK: Structs
struct DownloadPageStatus {
    static let pageAppendingBy = 100
    
    struct PageElements {
        var offset: Int = 0
        var limit: Int = pageAppendingBy
    }
    private(set) var isDownloading: Bool = false
    private(set) var page = PageElements()
    private var firstDownload = true
    
    /// Descargamos la siguiente página
    mutating func downloadNextPage() -> PageElements {
        if !firstDownload {
            page.offset += DownloadPageStatus.pageAppendingBy
        }
        firstDownload = false
        isDownloading = true
        
        return PageElements(offset: page.offset, limit: page.limit)
    }
    
    /// Recargamos todos los elementos
    mutating func refreshDownload() -> PageElements {
        isDownloading = true
        return PageElements(offset: 0, limit: page.limit)
    }
    
    mutating func endDownloading() {
        isDownloading = false
    }
    mutating func endDownloadingWithError() {
        page.offset -= DownloadPageStatus.pageAppendingBy
        isDownloading = false
    }
}
