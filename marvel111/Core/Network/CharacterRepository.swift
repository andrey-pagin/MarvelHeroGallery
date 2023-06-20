import Alamofire
import CryptoKit
import Foundation

enum NetError: Error {
    case emptyResult
    case error(Error)
}

final class CharacterRepository {
    
    private var database: CharacterModelDatabaseProtocol = DatabaseManagerImpl()
    
    private let baseUrl = "https://gateway.marvel.com/v1/public/characters"
    
    func getCharacters(offset: Int = 0, _ completion: @escaping (Result<[CharacterModel], NetError>) -> Void) {
        AF.request(
            baseUrl,
            parameters: requestParams(offset: offset)
        ).responseDataDecodable(of: CharacterListPayload.self) { response in
            
            switch response.result {
                    
            case .success(let charactersPayload):
                debugPrint(response)
                guard let charactersDecodable = charactersPayload.data?.results
                else {
                    completion(.failure(.emptyResult))
                    return
                }
                let characterModelArray: [CharacterModel] = charactersDecodable.compactMap {
                    self.createCharacterFromDecodable(character: $0)
                }
                self.database.writeAll(characters: characterModelArray)
                completion(.success(characterModelArray))
                    
            case .failure(let failure):
                NSLog(failure.localizedDescription)
                if offset == 0 {
                    completion(.success(self.database.getAll()))
                } else {
                    completion(.failure(.error(failure)))
                }
            }
        }
    }

    func getCharacter(id: Int, _ completion: @escaping (CharacterModel?) -> Void) {
        AF.request(
            baseUrl + "/\(id)",
            parameters: requestParams()
        ).responseDataDecodable(of: CharacterListPayload.self) { response in
            switch response.result {
            case .success(let charactersPayload):
                guard let charactersDecodable = charactersPayload.data?.results else { completion(nil); return }
                let characterModelArray: [CharacterModel] = charactersDecodable.compactMap { self.createCharacterFromDecodable(character: $0) }
                completion(characterModelArray.first)
            case .failure(let failure):
                NSLog(failure.localizedDescription)
                completion(self.database.getCharacter(id: id))
            }
        }
    }
    
    private func createCharacterFromDecodable(character: CharacterPayload?) -> CharacterModel? {
        guard let unwrappedCharacterPayload = character else { return nil }
        guard let id = unwrappedCharacterPayload.id else { return nil }
        
        return CharacterModel(id: id, name: unwrappedCharacterPayload.name,
                              imagelink: unwrappedCharacterPayload.thumbnail?.imageUrlString,
                              description: character?.description)
    }

    private func requestParams(offset: Int = 0) -> [String: String] {
        let privateKey = "016959c7eec6034a2883f65c348962cd586944ee"
        let apikey = "61e5488a7822174f2989d726559fc029"
        let timeStamp = NSDate().timeIntervalSince1970
        let hash = getHash(timeStamp: timeStamp, apikey: apikey, privateKey: privateKey)
        return ["apikey": apikey, "ts": "\(timeStamp)", "hash": hash, "offset": "\(offset)"]
    }

    private func getHash(timeStamp: Double, apikey: String, privateKey: String) -> String {
        let dirtyMd5 = Insecure.MD5.hash(data: "\(timeStamp)\(privateKey)\(apikey)".data(using: .utf8)!)
        return dirtyMd5.map { String(format: "%02hhx", $0) }.joined()
    }

    private struct CharacterListPayload: Decodable {
        let count: Int?
        let results: [CharacterPayload?]?
    }

    private struct CharacterPayload: Decodable {
        let name: String?
        let id: Int?
        let thumbnail: ThumbnailPayload?
        let description: String?
    }

    private struct ThumbnailPayload: Decodable {
        let imageUrlString: String?
        let imageExtension: String?
        
        enum CodingKeys: String, CodingKey {
            case imageUrlString = "path"
            case imageExtension = "extension"
        }
    }
}
