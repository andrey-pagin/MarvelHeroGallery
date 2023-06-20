import Foundation

final class FullScreenImageViewModel {
    
    private let repository = CharacterRepository()
    
    func getCharacter(id: Int, completion: @escaping (CharacterModel?) -> Void) {
        repository.getCharacter(id: id, completion)
    }
    
}
