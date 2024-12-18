import UIKit
import Combine
import CoreData
import SnapKit

class LikedBooksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var viewModel = LikedBooksViewModel()
    private let tableView = UITableView()
    private let titleLabel = UILabel()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupView()
        setupLayout()
        viewModel.$likedBooks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        viewModel.loadBooks()
    }

    private func setupView() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        titleLabel.text = "Liked Books"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.numberOfLines = 1
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LikedBookCell.self, forCellReuseIdentifier: LikedBookCell.reuseIdentifier)
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.likedBooks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LikedBookCell.reuseIdentifier,
                                                       for: indexPath) as? LikedBookCell else {
            fatalError("Unable to dequeue BookCell")
        }
        let book = viewModel.likedBooks[indexPath.row]
        cell.configure(with: book)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
}
