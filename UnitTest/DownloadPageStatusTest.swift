//
//  DownloadPageStatusTest.swift
//  UnitTest
//
//  Created by Francisco José Ruiz on 15/11/2020.
//  Copyright © 2020 Francisco José Ruiz. All rights reserved.
//

import XCTest
@testable import rxmarvel

class DownloadPageStatusTest: XCTestCase {

   
    var pageStatus: DownloadPageStatus!
    
    override func setUp() {
        super.setUp()
        self.pageStatus = DownloadPageStatus()
    }
    
    override class func tearDown() {
        //self.viewModel = nil
        super.tearDown()
    }
    
    func testPager() throws {
        var page = pageStatus.downloadNextPage()
        XCTAssert(page.offset == 0, "offset debe ser 0 la primera vez que se ejecuta")
        
        page = pageStatus.downloadNextPage()
        XCTAssert(
            page.offset == DownloadPageStatus.pageAppendingBy && pageStatus.isDownloading,
            "offset debe ser \(DownloadPageStatus.pageAppendingBy) la segunda vez que se ejecuta & isDownloading = true"
        )
        
        page = pageStatus.downloadNextPage()
        XCTAssert(
            page.offset == DownloadPageStatus.pageAppendingBy * 2 && pageStatus.isDownloading,
            "offset debe ser \(DownloadPageStatus.pageAppendingBy * 2) la tercera vez que se ejecuta & isDownloading = true"
        )
        
        pageStatus.endDownloading()
        XCTAssert(
            !pageStatus.isDownloading,
            "isDownloading debe ser false"
        )
        
        let expectedValue = pageStatus.page.offset - DownloadPageStatus.pageAppendingBy
        pageStatus.endDownloadingWithError()
        XCTAssert(
            pageStatus.page.offset == expectedValue && !pageStatus.isDownloading,
            "offset debe ser \(expectedValue) la tercera vez que se ejecuta & isDownloading = false"
        )
        
        page = pageStatus.refreshDownload()
        XCTAssert(
            page.offset == 0 && pageStatus.isDownloading,
            "offset debe ser 0 & isDownloading = true"
        )
        
        pageStatus.endDownloading()
        XCTAssert(
            !pageStatus.isDownloading,
            "isDownloading debe ser false"
        )
    }

    

}
