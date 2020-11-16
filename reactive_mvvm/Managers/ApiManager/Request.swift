//
//  Request.swift
//  reactive_mvvm
//
//  Created by Francisco José Ruiz on 15/11/2020.
//  Copyright © 2020 Francisco José Ruiz. All rights reserved.
//

import Foundation
import RxSwift
import CommonCrypto

class Request {
    
    enum ContentType: String {
        case application_json = "application/json"
    }
    enum Method: String {
        case get = "GET"
        case post = "POST"
    }
    
    func regular(url: String, contentType: ContentType = .application_json, method: Method = .get, extraParams: String? = nil) -> Observable<Data> {
        return Observable.create { observer in
            
            let session = URLSession.shared
            var fullUrl = url+self.addAuthParameters()
            if let params = extraParams {
               fullUrl += params
            }
            
            var request = URLRequest(url: URL(string: fullUrl)!)
            
            request.httpMethod = method.rawValue
            request.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
            
            session.dataTask(with: request) { (data, response, error) in
                /// Error
                if let e = error {
                    let error = CustomError(
                        title: e.localizedDescription,
                        description: e.localizedDescription,
                        code: 0
                    )
                    observer.onError(error)
                    observer.onCompleted()
                }
                guard let data = data, let response = response as? HTTPURLResponse, error == nil else { return }
                
                if (200...299).contains(response.statusCode) {
                    observer.onNext(data)
                }
                else {
                    do {
                        let decoder = JSONDecoder()
                        let customErrorJson = try decoder.decode(CustomErrorJson.self, from: data)
                        
                        let error = CustomError(
                            title: customErrorJson.statusMessage,
                            description: customErrorJson.statusMessage,
                            code: customErrorJson.statusCode
                        )
                        print("API_ERROR: url \(url)")
                        print("API_ERROR: statusCode \(response.statusCode)")
                        observer.onError(error)
                    } catch let error {
                        print("JSON_DECODER_API_ERROR: \(error.localizedDescription)")
                        observer.onError(error)
                    }
                }
                
                observer.onCompleted()
            }.resume()
            
            return Disposables.create {
                session.finishTasksAndInvalidate()
            }
        }
    }
    
    private func addAuthParameters() -> String {
        let timestamp = String(Date().timeIntervalSince1970 * 1000000)
        let apikey = Constants.api_keys.public
        let hash = self.md5("\(timestamp)\(Constants.api_keys.private)\(Constants.api_keys.public)")
        
        return "?apikey=" + apikey + "&ts=" + timestamp + "&hash=" + hash
    }
    
    private func md5(_ string: String) -> String {
        let length = Int(CommonCrypto.CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData.map {
                String(format: "%02hhx", $0)
            }.joined()
    }
    
}

protocol OurErrorProtocol: LocalizedError {

    var title: String { get }
    var code: Int { get }
}

struct CustomError: OurErrorProtocol {
    var title: String
    var code: Int
    var errorDescription: String? { return _description }
    var failureReason: String? { return _description }

    private var _description: String

    init(title: String, description: String = "", code: Int = 0) {
        self.title = title
        self._description = description
        self.code = code
    }
}

struct CustomErrorJson: Codable {
    let statusCode: Int
    let statusMessage: String
    let success: Bool
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case statusMessage = "status_message"
        case success
    }
}
