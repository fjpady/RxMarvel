//
//  Extensions.swift
//  reactive_mvvm
//
//  Created by Francisco José Ruiz on 15/11/2020.
//  Copyright © 2020 Francisco José Ruiz. All rights reserved.
//

import UIKit
import Kingfisher

//MARK: Extensions for UIImageView
extension UIImageView {
    
    /// Función para obtener una imagen de internet
    func imageFromServer(url: String, placeholder: UIImage? = nil) {
        if self.image == nil, let placeholder = placeholder {
            self.image = placeholder
        }
        
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            if error != nil { return }
            
            DispatchQueue.main.async {
                guard let data = data else { return }
                self.image = UIImage(data: data)
            }
        }.resume()
    }
    
    func load(url: String, placeholder: UIImage? = nil) {
        let url = URL(string: url)!
        self.kf.setImage(
        with: url,
        placeholder: placeholder ?? UIImage(),
        options: [
            .cacheOriginalImage
        ])
    }
}

//MARK: Extensions for String
extension String {
    /// Check valid mail
    func isValidEmail() -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return doRegex(regex)
    }
    
    /// Check password
    func isValidPassword() -> Bool {
        let regex = "^[a-zA-Z0-9._%+-]{6,}$"
        return doRegex(regex)
    }
    
    private func doRegex(_ regex: String) -> Bool {
        if self.count == 0 { return false }
        let r = NSPredicate(format:"SELF MATCHES %@", regex)
        return r.evaluate(with: self)
    }
}

//MARK: Extensions for Bundle
extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy

        do {
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
        } catch DecodingError.typeMismatch(_, let context) {
            fatalError("Failed to decode \(file) from bundle due to type mismatch – \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing \(type) value – \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(_) {
            fatalError("Failed to decode \(file) from bundle because it appears to be invalid JSON")
        } catch {
            fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)")
        }
    }
}
