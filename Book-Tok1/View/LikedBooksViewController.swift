import UIKit
import Combine
import CoreData
import SnapKit

class LikedBooksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let viewModel: LikedBooksViewModel
    private let tableView = UITableView()
    private let titleLabel = UILabel()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupView()
        setupLayout()
        viewModel.$likedBooks
            .combineLatest(viewModel.$likedBooksImages)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.loadBooks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadBooks()
    }

    
    init(viewModel: LikedBooksViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func setupView() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        titleLabel.text = "Liked Books"
        titleLabel.font = .systemFont(ofSize: 32, weight: .heavy)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 1
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BookCell.self, forCellReuseIdentifier: BookCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
    }

    private func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            $0.centerX.equalToSuperview()
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.leading.trailing.bottom.equalToSuperview().inset(20)
        }
    }

    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(1).cgColor,
            UIColor.white.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.likedBooks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookCell.reuseIdentifier,
                                                       for: indexPath) as? BookCell else {
            fatalError("Unable to dequeue BookCell")
        }
        let book = viewModel.likedBooks[indexPath.row]
        cell.configure(with: book, image: viewModel.likedBooksImages[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
}
