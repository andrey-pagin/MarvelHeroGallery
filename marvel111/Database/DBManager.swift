import RealmSwift
import Foundation

final class DatabaseManagerImpl: DatabaseManager {
    
    private let realm: Realm?
    
    init() {
        self.realm = try? Realm()
    }
    
    func write(object: Object) {
        try? realm?.write { realm?.add(object, update: .modified) }
    }
    
    func get<T: Object> (id: Int, type: T.Type) -> T? {
        return realm?.object(ofType: T.self, forPrimaryKey: id)
    }
    
    func getAll<T: Object> (_ type: T.Type) -> [T]? {
        let results = realm?.objects(T.self)
        return results?.map { $0 }
    }
}

extension DatabaseManagerImpl: CharacterModelDatabaseProtocol {
    func getCharacter(id: Int) -> CharacterModel? {
        guard let model = get(id: id, type: CharacterRealmModel.self) else { return nil }
        return CharacterModel(realmModel: model)
    }
    
    func write(character: CharacterModel) {
        write(object: CharacterRealmModel(character))
    }
    
    func writeAll(characters: [CharacterModel]) {
        characters.forEach { write(object: CharacterRealmModel($0)) }
    }
    
    func getAll() -> [CharacterModel] {
        return getAll(CharacterRealmModel.self)?.compactMap { CharacterModel(realmModel: $0) } ?? []
    }
}

private extension CharacterModel {
    init? (realmModel: CharacterRealmModel) {
        self.init(id: realmModel.heroId, name: realmModel.name, imagelink: realmModel.imageLink, description: realmModel.characterDescription)
    }
}

// MARK: CharacterRealmModel
// Realm object should bs in global space
fileprivate final class CharacterRealmModel: Object {
    @Persisted var name: String
    @Persisted var characterDescription: String
    @Persisted(primaryKey: true) var heroId: Int
    @Persisted var imageLink: String
    
    convenience init(id: Int, name: String, imagelink: String, description: String) {
        self.init()
        self.heroId = id
        self.name = name
        self.characterDescription = description
        if imagelink.hasSuffix("jpg") {
            self.imageLink = imagelink
        } else {
            self.imageLink = imagelink + "/portrait_uncanny.jpg"
        }
    }
    
    convenience init(_ characterModel: CharacterModel) {
        self.init()
        self.heroId = characterModel.heroId
        self.name = characterModel.name
        self.characterDescription = characterModel.characterDescription
        self.imageLink = characterModel.imageLink
    }
}
