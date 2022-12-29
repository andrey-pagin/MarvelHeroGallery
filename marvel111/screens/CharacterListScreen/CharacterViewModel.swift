import Foundation

protocol CharacterViewModel: AnyObject {
    var items: [CollectionCellItem] { get }
    var itemsPublisher: Published<[CollectionCellItem]>.Publisher { get }
    var isLoading: Bool { get }
    func refresh()
    func moreDataIsNeeded()
}
