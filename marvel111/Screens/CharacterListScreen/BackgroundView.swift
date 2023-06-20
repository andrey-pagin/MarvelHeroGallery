import UIKit

final class BackgroundView: UIImageView {

    private let backgroundImage = UIImage(named: "background") ?? .init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .darkGray
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTriangleColor(_ color: UIColor) {
        self.image = backgroundImage.withTintColor(color)
    }
}
