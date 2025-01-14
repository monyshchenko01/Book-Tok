import UIKit
import SnapKit
import CoreData

class CommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var viewModel: CommentsViewModel!
    var book: BookEntity?
    var context: NSManagedObjectContext!
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommentCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGray6
        return tableView
    }()

    private let commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Write a comment..."
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.darkGray.cgColor
        if let placeholderLabel = textField.value(forKey: "placeholderLabel") as? UILabel {
            placeholderLabel.textColor = .gray
        }
        return textField
    }()

    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Comment", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        guard let book = book else {
            print("Book is nil")
            return
        }
        viewModel = CommentsViewModel(context: context)
        viewModel.updateUI = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel.fetchComments(for: book)
        tableView.dataSource = self
        tableView.delegate = self
        submitButton.addTarget(self, action: #selector(addComment), for: .touchUpInside)
        setupView()
    }

    private func setupView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-120)
        }

        let inputContainer = UIView()
        inputContainer.backgroundColor = .white
        view.addSubview(inputContainer)

        inputContainer.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(120)
        }

        inputContainer.addSubview(commentTextField)
        inputContainer.addSubview(submitButton)

        commentTextField.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalTo(submitButton.snp.left).offset(-16)
            $0.top.equalToSuperview().offset(20)
            $0.height.equalTo(40)
        }

        submitButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(20)
            $0.width.equalTo(120)
            $0.height.equalTo(40)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        cell.textLabel?.text = viewModel.comments[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.textLabel?.textColor = .black
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        cell.selectedBackgroundView = selectedBackgroundView
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Comment",
                                      message: "Do you want to delete this comment?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            guard let book = self.book else { return }
            self.viewModel.deleteComment(at: indexPath.row, for: book)
        }))
        present(alert, animated: true, completion: nil)
    }

    @objc private func addComment() {
        guard let text = commentTextField.text, !text.isEmpty else { return }
        guard let book = book else { return }
        viewModel.addComment(text, to: book)
        commentTextField.text = ""
    }
}
