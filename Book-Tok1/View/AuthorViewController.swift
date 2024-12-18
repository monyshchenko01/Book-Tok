import UIKit
import Combine
import SnapKit

class AuthorViewController: UIViewController {

    private var viewModel: AuthorViewModel
    private var books: [Book] = []
    private var images: [UIImage?] = []
    
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    
    init(viewModel: AuthorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        
        DispatchQueue.global(qos: .background).async {
            self.viewModel.fetchAuthorBooks()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BookCell.self, forCellReuseIdentifier: BookCell.reuseIdentifier)
        
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        Publishers.CombineLatest(viewModel.authorBooksPublisher, viewModel.authorBooksImagsePublisher)
           .sink { [weak self] books, images in
               self?.books = books
               self?.images = images
               self?.tableView.reloadData()
           }
           .store(in: &viewModel.cancellables)
    }
    
}

extension AuthorViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookCell.reuseIdentifier, for: indexPath) as? BookCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: books[indexPath.row], image: images[indexPath.row])
        return cell
    }
}
