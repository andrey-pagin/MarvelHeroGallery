import UIKit
import SnapKit
import Alamofire
import Kingfisher
import Combine

private struct Constants {
    static let collectionViewLayoutInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 60)
    static let collectionViewLayoutItemSize = CGSize(width: UIScreen.main.bounds.width - 120,
                                                     height: UIScreen.main.bounds.height - 300)
    static let itemSpasing = 40.0
}

final class ListViewController: UIViewController {
    
    private var subscriptions = Set<AnyCancellable>()
    private let viewModel: MainViewModelProtocol = MainViewModel()
    
    private let background = BackgroundView(frame: .zero)
    private var currentSelectedItemIndex = 0
    
    private var fullScreenTransitionManager: FullScreenTransitionManager?
    
    private let fullScreenImageViewController = FullScreenImageViewController()
    
    private lazy var mainScrollView: UIScrollView = {
        let mainScrollView = UIScrollView()
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Reloading data")
        refreshControl.backgroundColor = .systemGray
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        mainScrollView.refreshControl = refreshControl
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.showsHorizontalScrollIndicator = false
        return mainScrollView
    }()
    
    private let contentView = UIView()
    
    private let logoImage: UIImageView = {
        let logo = UIImageView()
        logo.image = UIImage(named: "marvel_logo")
        return logo
    }()

    private let titleTextLabel: UILabel = {
        let titleTextLabel = UILabel()
        titleTextLabel.text = "Choose your hero"
        titleTextLabel.textColor = .white
        titleTextLabel.font = UIFont(name: "Roboto-Black", size: 37)
        titleTextLabel.textAlignment = .center
        return titleTextLabel
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = PagingCollectionViewLayout()
        layout.itemSize = Constants.collectionViewLayoutItemSize
        layout.minimumLineSpacing = Constants.itemSpasing
        layout.scrollDirection = .horizontal
        layout.sectionInset = Constants.collectionViewLayoutInset
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.decelerationRate = .fast
        collectionView.backgroundColor = .none
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    @objc func refresh() {
       // Code to refresh collectionView
        viewModel.refresh()
        mainScrollView.refreshControl?.endRefreshing()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        title = ""
        navigationController?.navigationBar.tintColor = .white
        view.addSubview(mainScrollView)
        mainScrollView.addSubview(contentView)
        contentView.addSubview(background)
        contentView.addSubview(logoImage)
        contentView.addSubview(titleTextLabel)
        registerCollectionViewCells()
        contentView.addSubview(collectionView)
        background.setTriangleColor(.black)
        mainScrollView.contentInsetAdjustmentBehavior = .never
        mainScrollView.alwaysBounceHorizontal = false
        mainScrollView.alwaysBounceVertical = true
        viewModel.moreDataIsNeeded()
        setLayout()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    private func setLayout() {
        
        mainScrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.snp.edges)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }
        background.snp.makeConstraints { make in
            make.edges.equalTo(contentView.snp.edges)
        }
        logoImage.snp.makeConstraints { make in
            make.centerX.equalTo(contentView.snp.centerX)
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(10)
            make.size.equalTo(CGSize(width: 140, height: 30))
        }
        titleTextLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImage.snp.bottom).offset(20)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
        }
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            make.top.equalTo(titleTextLabel.snp.bottom).offset(10)
            make.bottom.equalTo(contentView.snp.bottom).offset(-30)
        }
    }
    
    private func setupBindings() {
        viewModel.itemsPublisher.sink { [weak self] _ in
            self?.collectionView.reloadData()
        }.store(in: &subscriptions)
    }

    private func registerCollectionViewCells() {
        collectionView.register(CollectionViewCell.self,
                                forCellWithReuseIdentifier: String(describing: CollectionViewCell.self))

        collectionView.register(CollectionViewLoadingIndicatorCell.self,
                                forCellWithReuseIdentifier: String(describing: CollectionViewLoadingIndicatorCell.self))
    }
    
    func changeTriangleColor(currentItemIndex: Int) {
        switch viewModel.items[currentItemIndex] {
        case .hero(model: let model):
            let cache = ImageCache.default
            cache.retrieveImage(forKey: "\(model.heroId)") { result in
                switch result {
                case .success(let value):
                    DispatchQueue.global(qos: .userInteractive).async {
                        let color = value.image?.averageColor ?? .clear
                        DispatchQueue.main.async {
                            self.background.setTriangleColor(color)
                        }
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        case .loading:
            background.setTriangleColor(.black)
        }
    }
    
}

extension ListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tag = indexPath.item + 1
        switch viewModel.items[indexPath.item] {
        case .hero(model: let model):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: CollectionViewCell.self),
                for: indexPath) as? CollectionViewCell else {
                return .init()
            }
            cell.setup(characterModel: model, and: tag)
            return cell
        case .loading:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: CollectionViewLoadingIndicatorCell.self),
                for: indexPath) as? CollectionViewLoadingIndicatorCell else {
                return .init()
            }
            cell.setup()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch viewModel.items[indexPath.item] {
        case .hero(model: let model):
            let tag = indexPath.row + 1
            let characterData = model
            let fullScreenTransitionManager = FullScreenTransitionManager(anchorViewTag: tag)
            fullScreenImageViewController.setup(characterData: characterData, tag: tag)
            fullScreenImageViewController.modalPresentationStyle = .custom
            fullScreenImageViewController.transitioningDelegate = fullScreenTransitionManager
            present(fullScreenImageViewController, animated: true)
            self.fullScreenTransitionManager = fullScreenTransitionManager
        case .loading:
            break
        }

    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.items.count - 1 {
            // Last cell is visible
            viewModel.moreDataIsNeeded()
        }
        let centerPoint = CGPoint(x: collectionView.frame.size.width / 2 + collectionView.contentOffset.x,
                                  y: collectionView.frame.size.height / 2 + collectionView.contentOffset.y)
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            changeTriangleColor(currentItemIndex: indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = Constants.collectionViewLayoutItemSize
        let cellWidth = (indexPath.row == viewModel.items.count && viewModel.isLoading ) ? 40 : size.width
        return CGSize(width: cellWidth, height: size.height)
    }
}
