import UIKit
import Combine
import CoreData
import SnapKit

class LikedBooksViewController: UIViewController {
    
    private var viewModel: LikedBooksViewModel
    private var books: [Book] = []
    private var images: [UIImage?] = []
    
    private let tableView = UITableView()
    private let titleLabel = UILabel()
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: LikedBooksViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupView()
        setupLayout()
        bindViewModel()
        
        DispatchQueue.global(qos: .background).async {
            self.viewModel.loadBooks()
        }
    }

    private func setupView() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BookCell.self, forCellReuseIdentifier: BookCell.reuseIdentifier)
        
        titleLabel.text = "Liked Books"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.numberOfLines = 1
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
    }

    private func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.centerX.equalToSuperview()
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func bindViewModel() {
        Publishers.CombineLatest(viewModel.likedBooksPublisher, viewModel.likedBooksImagesPublisher)
           .sink { [weak self] books, images in
               self?.books = books
               self?.images = images
               self?.tableView.reloadData()
           }
           .store(in: &viewModel.cancellables)
    }
    

    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.lightGray.cgColor,
            UIColor.white.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

}

extension LikedBooksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookCell.reuseIdentifier, for: indexPath) as? BookCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: books[indexPath.row], image: images[indexPath.row])
        return cell
    }
}

