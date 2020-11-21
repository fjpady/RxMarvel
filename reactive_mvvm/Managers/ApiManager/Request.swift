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
import Alamofire
import Reachability

class Request {
    
    enum ContentType: String {
        case application_json = "application/json"
    }
    enum Method: String {
        case get = "GET"
        case post = "POST"
    }
    
    
    func regular(_ url: String, parameters: [String: Any]? = nil, headers:[String: String]? = nil, method: HTTPMethod, encoding: ParameterEncoding)  -> Observable<Data> {
        return Observable.create { observer in
            
            /// Check connection
            let reachability = try! Reachability()
            if reachability.connection == .unavailable {
                //let e = SDError()
                //e.notReachableError()
                //listener.errorHandler(e)
                
            }
            
            /// Check parameters
            var myParams: [String: Any] = self.getAuthParameters()
            if let newParameters = parameters {
                for param in newParameters {
                    myParams[param.key] = param.value
                }
            }
            
            /// Check headers
            var myHeaders = [String: String]()
            if let obj = headers{
                myHeaders = obj
            }
            
            Alamofire.request(url, method: method, parameters: myParams, encoding: encoding ,headers: myHeaders)
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        if let data = response.data {
                            observer.onNext(data)
                        }
                        
                    case .failure( _):
                        if let data = response.data {
                           do {
                                let decoder = JSONDecoder()
                                let customErrorJson = try decoder.decode(CustomErrorJson.self, from: data)
                                print(data)
                                let error = CustomError(
                                    title: customErrorJson.statusMessage,
                                    description: customErrorJson.statusMessage,
                                    code: customErrorJson.statusCode
                                )
                                print("API_ERROR: url \(url)")
                                print("API_ERROR: statusCode \(error.code)")
                                observer.onError(error)
                            } catch let error {
                                print("JSON_DECODER_API_ERROR: \(error.localizedDescription)")
                                observer.onError(error)
                            }
                        }
                    }
                    observer.onCompleted()
            }
            
            
            return Disposables.create {}
        }
        
    }
    
    private func getAuthParameters() -> [String: Any] {
        let timestamp = String(Date().timeIntervalSince1970 * 1000000)
        let apikey = Constants.api_keys.public
        let hash = self.md5("\(timestamp)\(Constants.api_keys.private)\(Constants.api_keys.public)")
        return [
            "apikey": apikey,
            "ts": timestamp,
            "hash": hash
        ]
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
    var code: String { get }
}

struct CustomError: OurErrorProtocol {
    var title: String
    var code: String
    var errorDescription: String? { return _description }
    var failureReason: String? { return _description }

    private var _description: String

    init(title: String, description: String = "", code: String = "0") {
        self.title = title
        self._description = description
        self.code = code
    }
}

struct CustomErrorJson: Codable {
    let statusCode: String
    let statusMessage: String
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "code"
        case statusMessage = "message"
    }
}
