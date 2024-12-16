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
    private let viewModel: BookTokViewModel
    
    private let coverImageView: UIImageView = {
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 24, weight: .heavy)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        return label
    }()
    
    private let categoriesStack: UIStackView = {
        let stackView = UIStackView()
        
        return stackView
    }()
    
    private let ratingView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fill
        
        return stackView
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        return label
    }()
    
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
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 45, weight: .bold, scale: .large), forImageIn: .normal)
        button.accessibilityIdentifier = "authorButton"
        
        return button
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        
        button.setImage(UIImage(systemName: "heart.circle.fill"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 45, weight: .bold, scale: .large), forImageIn: .normal)
        button.accessibilityIdentifier = "likeButton"
        
        return button
    }()
    
    private let commentsButton: UIButton = {
        let button = UIButton()
        
        button.setImage(UIImage(systemName: "bubble.circle.fill"), for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 45, weight: .bold, scale: .large), forImageIn: .normal)
        button.accessibilityIdentifier = "commentsButton"
        
        return button
    }()
    
    init(viewModel: BookTokViewModel) {
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
        viewModel.fetchRandomBook()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = textOverlay.bounds
    }
    
    private func setupView() {
        view.addSubview(coverImageView)
        view.addSubview(textOverlay)
        view.addSubview(titleLabel)
        view.addSubview(ratingView)
        view.addSubview(descriptionLabel)
        view.addSubview(buttonsStack)
        buttonsStack.addArrangedSubview(authorButton)
        buttonsStack.addArrangedSubview(likeButton)
        buttonsStack.addArrangedSubview(commentsButton)
        
        authorButton.addTarget(self, action: #selector(didTapAuthorButton), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        commentsButton.addTarget(self, action: #selector(didTapCommentsButton), for: .touchUpInside)
    }
    
    private func setupLayout() {
        coverImageView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        textOverlay.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        buttonsStack.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(50)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalTo(buttonsStack.snp.top).offset(-30)
            $0.height.lessThanOrEqualTo(view.snp.height).multipliedBy(0.4)
        }
        
        ratingView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(10)
            $0.bottom.equalTo(descriptionLabel.snp.top).offset(-15)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalTo(ratingView.snp.top).offset(-15)
        }
    }
    
    private func bindViewModel() {
        viewModel.bookPublisher
            .sink { [weak self] book in
                self?.titleLabel.text = book?.title
                self?.descriptionLabel.text = book?.description
                self?.authorButton.isHidden = book?.authors?.isEmpty ?? true
                
                self?.view.layoutIfNeeded()
                self?.setupGradient()
                self?.setupRating(book?.averageRating)
                
                self?.viewModel.fetchCurrentBookCoverImage()
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
    
    @objc private func didTapAuthorButton() {
        guard let author = viewModel.getAuthor() else { return }
//        let authorVM = AuthorViewModel(name: author)
        let authorVC = UIViewController() // change to author tab
        navigationController?.pushViewController(authorVC, animated: true)
    }
    
    @objc private func didTapLikeButton() {
        viewModel.updateLikedStatus()
    }
    
    @objc private func didTapCommentsButton() {
        let commentsVC = CommentsViewController()
        commentsVC.modalPresentationStyle = .pageSheet

        if let sheet = commentsVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }

        present(commentsVC, animated: true)
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

        textOverlay.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -100).isActive = true
        textOverlay.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupRating(_ rating: Double?) {
        guard let rating = rating else {
            ratingView.isHidden = true
            return
        }
        ratingView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        ratingView.isHidden = false
        
        let maxRating = 5
        let fullStars = Int(rating)
        let halfStars = rating - Double(fullStars) >= 0.5 ? 1 : 0
        let emptyStars = maxRating - fullStars - halfStars
        
        addStars(type: "star.fill", count: fullStars)
        addStars(type: "star.leadinghalf.fill", count: halfStars)
        addStars(type: "star", count: emptyStars)
    }
    
    private func addStars(type: String, count: Int) {
        for _ in 0..<count {
            let starImageView = UIImageView(image: UIImage(systemName: type))
            starImageView.tintColor = .systemYellow
            starImageView.translatesAutoresizingMaskIntoConstraints = false
            starImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
            starImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            
            ratingView.addArrangedSubview(starImageView)
        }
    }

}
