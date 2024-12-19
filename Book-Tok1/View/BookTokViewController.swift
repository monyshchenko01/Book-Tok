//
//  Untitled.swift
//  Book-Tok1
//
//  Created by Kira Zholtikova on 13.12.2024.
//
import UIKit
import SnapKit
import Combine

final class BookTokViewController: UIViewController {
    private let viewModel: BaseBookTokViewModel
    
    let bookInfoView = BookInfoView()
    
    let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let textOverlay: UIView = {
        let overlay = UIView()
        overlay.clipsToBounds = true
        return overlay
    }()
    
    private let gradientLayer = CAGradientLayer()
    
    private let buttonsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.distribution = .fill
        return stackView
    }()
    
    private let authorButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 45,
                                            weight: .bold, scale: .large), forImageIn: .normal)
        button.accessibilityIdentifier = "authorButton"
        return button
    }()
    
    let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart.circle.fill"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 45,
                                                weight: .bold, scale: .large), forImageIn: .normal)
        button.accessibilityIdentifier = "likeButton"
        return button
    }()
    
    private let commentsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bubble.circle.fill"), for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 45,
                                                weight: .bold, scale: .large), forImageIn: .normal)
        button.accessibilityIdentifier = "commentsButton"
        return button
    }()
    
    init(viewModel: BaseBookTokViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        bindViewModel()
        viewModel.fetchBook()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = textOverlay.bounds
    }
    
    private func setupView() {
        view.addSubview(coverImageView)
        view.addSubview(textOverlay)
        view.addSubview(bookInfoView)
        view.addSubview(buttonsStack)
        buttonsStack.addArrangedSubview(authorButton)
        buttonsStack.addArrangedSubview(likeButton)
        buttonsStack.addArrangedSubview(commentsButton)
        
        authorButton.addTarget(self, action: #selector(didTapAuthorButton), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        commentsButton.addTarget(self, action: #selector(didTapCommentsButton), for: .touchUpInside)
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeUp))
        swipeUpGesture.direction = .up
        view.addGestureRecognizer(swipeUpGesture)
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeDown))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)
    }
    
    private func setupLayout() {
        coverImageView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        buttonsStack.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(50)
        }
        
        bookInfoView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalTo(buttonsStack.snp.top).offset(-30)
        }
        
        textOverlay.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(bookInfoView.snp.top).offset(-200)
        }
    }
    
    private func bindViewModel() {
        viewModel.bookPublisher
            .sink { [weak self] book in
                self?.view.layoutIfNeeded()
                self?.setupGradient()
                self?.buttonsStack.isHidden = true
                if let book = book {
                    self?.buttonsStack.isHidden = false
                    self?.bookInfoView.configure(with: book)
                    self?.authorButton.isHidden = book.authors?.isEmpty ?? true
                }
                
                self?.viewModel.fetchCurrentBookImage()
                self?.animateContentIn()
            }
            .store(in: &viewModel.cancellables)
        viewModel.bookImagePublisher
            .sink { [weak self] image in
                self?.coverImageView.image = image
            }
            .store(in: &viewModel.cancellables)
        viewModel.isLikedPublished
            .sink { [weak self] isLiked in
                self?.likeButton.tintColor = isLiked ? .systemPink : .white
            }
            .store(in: &viewModel.cancellables)
    }
    
    @objc func didTapAuthorButton() {
        guard let author = viewModel.getAuthor() else { return }
        let authorViewModel = AuthorViewModel(author: author, bookAPIservice: self.viewModel.bookAPIservice)
        let authorViewController = AuthorViewController(viewModel: authorViewModel)
        navigationController?.pushViewController(authorViewController, animated: true)
    }
    
    @objc func didTapLikeButton() {
        viewModel.updateLikedStatus()
    }
    
    @objc func didTapCommentsButton() {
        if !viewModel.isLikedSubject.value {
            viewModel.updateLikedStatus()
        }
        
        guard let bookEntity = viewModel.currentBookEntity() else {
            print("Book entity is not available")
            return
        }
        
        let commentsVC = CommentsViewController()
        commentsVC.book = bookEntity
        let context = viewModel.getContext()
        commentsVC.context = context
        
        commentsVC.modalPresentationStyle = .pageSheet
        if let sheet = commentsVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(commentsVC, animated: true)
    }
    
    @objc func didSwipeUp() {
        if viewModel.isSwipeUpAllowed() {
            animateContentOut()
            viewModel.nextBook()
        }
    }
    
    @objc func didSwipeDown() {
        if viewModel.isSwipeDownAllowed() {
            animateContentOut()
            viewModel.previousBook()
        }
    }
    
    func animateContentOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.height)
        })
    }
    
    func animateContentIn() {
        self.view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
        UIView.animate(withDuration: 0.3) {
            self.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    private func setupGradient() {
        textOverlay.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }

        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(1).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)

        gradientLayer.frame = textOverlay.bounds

        textOverlay.layer.insertSublayer(gradientLayer, at: 0)
    }

}
