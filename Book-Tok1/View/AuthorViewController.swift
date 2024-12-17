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
//    private let bookAPIService: BookAPIService
    private let author: Author
    private let viewModel: AuthorViewModel
    
    init(viewModel: AuthorViewModel/*, bookAPIService: BookAPIService*/, author: Author) {
        self.viewModel = viewModel
        self.author = author
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
//        fetchAuthorDetails()
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
//    private func fetchAuthorDetails() {
//        viewModel.fetchAuthorDetails(name: author.name)
//        viewModel.authorPublisher
//            .sink { [weak self] _ in
//                self?.updateUI()
//            }
//            .store(in: &cancellables)
//    }
    private func updateUI() {
        guard let author = viewModel.getAuthor() else { return }
        
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
        return viewModel.getAuthor()?.books.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "BookCell")
        
        if let book = viewModel.getAuthor()?.books[indexPath.row] {
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
//    хз як працює, потрбвно буде перевірити
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let selectedBook = viewModel.getAuthor()?.books[indexPath.row] {
            let bookDetailsViewModel = BookDetailsViewModel(book: selectedBook, coverImage: UIImage(named: "defaultBookCover"))
            let bookDetailsVC = BookDetailsViewController(viewModel: bookDetailsViewModel)
            navigationController?.pushViewController(bookDetailsVC, animated: true)
        }
    }


}
