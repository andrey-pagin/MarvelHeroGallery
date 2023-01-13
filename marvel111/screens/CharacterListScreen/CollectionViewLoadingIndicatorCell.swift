import UIKit
import SnapKit

final class CollectionViewLoadingIndicatorCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLayout()
    }
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        return spinner
    }()
    
    func setup() {
        spinner.startAnimating()
    }
    
    private func setUpLayout() {
        addSubview(spinner)
        spinner.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
