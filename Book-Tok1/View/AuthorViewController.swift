import UIKit
import Combine
import SnapKit

class AuthorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let nameLabel = UILabel()
    private let bioLabel = UILabel()
    private let photoImageView = UIImageView()
    private let booksHeaderLabel = UILabel()
    private let tableView = UITableView()
    
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: AuthorViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    func configure(with viewModel: AuthorViewModel) {
        self.viewModel = viewModel
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        nameLabel.font = .boldSystemFont(ofSize: 20)
        nameLabel.textAlignment = .center
        
        bioLabel.font = .systemFont(ofSize: 16)
        bioLabel.numberOfLines = 0
        bioLabel.textAlignment = .left
        
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.layer.cornerRadius = 75
        photoImageView.clipsToBounds = true
        
        booksHeaderLabel.text = "Список книг"
        booksHeaderLabel.font = .boldSystemFont(ofSize: 22)
        booksHeaderLabel.textAlignment = .center
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BookCell")
        
        view.addSubview(nameLabel)
        view.addSubview(photoImageView)
        view.addSubview(bioLabel)
        view.addSubview(booksHeaderLabel)
        view.addSubview(tableView)
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        photoImageView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(150)
        }
        
        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        booksHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(bioLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(booksHeaderLabel.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        viewModel?.authorPublisher
            .sink { [weak self] author in
                self?.nameLabel.text = author?.name ?? "Unknown Author"
                self?.bioLabel.isHidden = author?.biography.isEmpty ?? true
                self?.bioLabel.text = author?.biography
                self?.photoImageView.isHidden = author?.photoURL?.isEmpty ?? true
                
                self?.view.layoutIfNeeded()
            }
            .store(in: &cancellables)
        
        viewModel?.authorImagePublisher
            .sink { [weak self] image in
                self?.photoImageView.image = image
            }
            .store(in: &cancellables)
    }

    private func updateUI() {
        guard let author = viewModel?.getAuthor() else { return }
        
        nameLabel.text = author.name
        bioLabel.text = author.biography
        
        if let photoURL = URL(string: author.photoURL ?? "") {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: photoURL) {
                    DispatchQueue.main.async {
                        self.photoImageView.image = UIImage(data: data)
                    }
                }
            }
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.getAuthor()?.books.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "BookCell")
        
        if let book = viewModel?.getAuthor()?.books[indexPath.row] {
            let bookImageView = UIImageView()
            let titleLabel = UILabel()
            
            bookImageView.contentMode = .scaleAspectFill
            bookImageView.clipsToBounds = true
            titleLabel.font = .systemFont(ofSize: 16)
            
            cell.contentView.addSubview(bookImageView)
            cell.contentView.addSubview(titleLabel)

            bookImageView.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(10)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(60)
            }
            
            titleLabel.snp.makeConstraints { make in
                make.leading.equalTo(bookImageView.snp.trailing).offset(10)
                make.trailing.equalToSuperview().offset(-10)
                make.centerY.equalToSuperview()
            }
            
            titleLabel.text = book.title
        }
        
        return cell
    }

//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        if let selectedBook = viewModel?.getAuthor()?.books[indexPath.row] {
//            let bookDetailsViewModel = BookDetailsViewModel(book: selectedBook, coverImage: UIImage(named: "defaultBookCover"))
//            let bookDetailsVC = BookDetailsViewController(viewModel: bookDetailsViewModel)
//            navigationController?.pushViewController(bookDetailsVC, animated: true)
//        }
//    }
}
