import RealmSwift

protocol CharacterModelDatabaseProtocol: AnyObject {
    
    func write(character: CharacterModel)
    func writeAll(characters: [CharacterModel])
    func getCharacter(id: Int) -> CharacterModel?
    func getAll() -> [CharacterModel]
    
}
