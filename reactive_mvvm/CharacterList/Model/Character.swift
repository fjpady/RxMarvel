// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - ResultData
struct ResultData: Decodable {
    let code: Int
    let status, copyright, attributionText, attributionHTML, etag: String
    var data: DataClass
    
    func getListOfCharacters() -> [Character] {
        return data.characters ?? [Character]()
    }
}


// MARK: - DataClass
struct DataClass: Decodable {
    var offset, limit, total, count: Int
    var characters: [Character]?
    
    enum CodingKeys: String, CodingKey {
        case offset, limit, total, count
        case characters = "results"
    }
}

// MARK: - Result
struct Character: Decodable, Equatable {
    let id: Int
    let name, resultDescription, modified, resourceURI: String
    var description: String?
    let thumbnail: Thumbnail?
    let comics, series, events: Comics
    let stories: Stories
    let urls: [URLElement]
    enum CodingKeys: String, CodingKey {
        case id, name, modified, thumbnail, resourceURI, comics, series, stories, events, urls
        case resultDescription = "description"
    }
    
    static func ==(lhs: Character, rhs: Character) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}

// MARK: - Comics
struct Comics: Decodable {
    let available, returned: Int
    let collectionURI: String
    let items: [ComicsItem]
}

// MARK: - ComicsItem
struct ComicsItem: Decodable {
    let resourceURI, name: String
}

// MARK: - CharactersModel
struct Stories: Decodable {
    let available, returned: Int
    let collectionURI: String
    let items: [StoriesItem]
}

// MARK: - StoriesItem
struct StoriesItem: Decodable {
    let resourceURI, name, type: String
}

// MARK: - Thumbnail
struct Thumbnail: Decodable {
    let path, thumbnailExtension: String

    enum CodingKeys: String, CodingKey {
        case path
        case thumbnailExtension = "extension"
    }
    
    func getUrl() -> String? {
        if path != "" && thumbnailExtension != "" {
            return "\(path).\(thumbnailExtension)"
        }
        return nil
    }
}

// MARK: - URLElement
struct URLElement: Decodable {
    let type, url: String
}
