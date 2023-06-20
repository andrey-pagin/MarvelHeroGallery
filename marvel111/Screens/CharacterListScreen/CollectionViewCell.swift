import UIKit
import Kingfisher

final class CollectionViewCell: UICollectionViewCell {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 15.0
        imageView.clipsToBounds = true
        return imageView
    }()
    private let textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.font = UIFont(name: "Roboto-Black", size: 24)
        textLabel.textColor = .white
        textLabel.shadowColor = .black
        textLabel.shadowOffset = CGSize(width: 5, height: 5)
        return textLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .none
        imageView.kf.indicatorType = .activity
        setUpLayout()
    }

    func setup(characterModel: CharacterModel?, and tag: Int) {
        imageView.image = .init()
        textLabel.text = ""
        guard let characterData = characterModel else { return }
        imageView.layoutIfNeeded()
        let processor = DownsamplingImageProcessor(size: imageView.bounds.size)
                     |> RoundCornerImageProcessor(cornerRadius: 20)
        let resource = ImageResource(
            downloadURL: URL(string: characterData.imageLink) ?? URL(fileURLWithPath: ""),
            cacheKey: "\(characterData.heroId)"
        )
        imageView.kf.setImage(
            with: resource,
            placeholder: UIImage(named: "placeholder"),
            options: [
                .processor(processor),
                .cacheOriginalImage
            ]
        ) { result in
            switch result {
            case .success(let value):
                NSLog("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                NSLog("Job failed: \(error.localizedDescription)")
            }
        }
        imageView.tag = tag
        textLabel.text = characterData.name
    }

    private func setUpLayout() {
        addSubview(imageView)
        addSubview(textLabel)
        textLabel.snp.makeConstraints {
            $0.left.equalTo(self.snp.left).offset(20)
            $0.right.equalTo(self.snp.right).offset(-10)
            $0.top.equalTo(self.snp.bottom).offset(-50)
        }
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
