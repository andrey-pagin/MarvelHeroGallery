import Foundation
import RealmSwift

protocol DatabaseManager {
    func getAll<T: Object> (_ type: T.Type) -> [T]?
    func get<T: Object> (id: Int, type: T.Type) -> T?
    func write(object: Object)
}
