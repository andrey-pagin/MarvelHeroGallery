import Foundation

struct CharacterModel {
    let name: String
    let characterDescription: String
    let heroId: Int
    let imageLink: String
    
    init(id: Int, name: String, imagelink: String, description: String) {
        self.heroId = id
        self.name = name
        self.characterDescription = description
        if imagelink.hasSuffix("jpg") {
            self.imageLink = imagelink
        } else {
            self.imageLink = imagelink + "/portrait_uncanny.jpg"
        }
    }
    
    init(id: Int, name: String?, imagelink: String?, description: String?) {
        self.heroId = id
        self.name = name ?? "Noname"
        self.characterDescription = description ?? ""
        guard let link = imagelink else { self.imageLink = ""; return}
        if link.hasSuffix("jpg") {
            self.imageLink = link
        } else {
            self.imageLink = link + "/portrait_uncanny.jpg"
        }
    }
}
