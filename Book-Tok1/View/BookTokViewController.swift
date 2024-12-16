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
    
//    private let dark
    
//    private let rating
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 24, weight: .heavy)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        return label
    }()
    
//    private let categoriesContainer
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        return label
    }()
    
    private let authorButton: UIButton = {
        let button = UIButton()
        
        button.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large), forImageIn: .normal)
        button.accessibilityIdentifier = "likeButton"
        
        return button
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        
        button.setImage(UIImage(systemName: "heart.circle.fill"), for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.imageView?.contentMode = .scaleAspectFit
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large), forImageIn: .normal)
        button.accessibilityIdentifier = "likeButton"
        
        return button
    }()
    
    private let commentsButton: UIButton = {
        let button = UIButton()
        
        button.setImage(UIImage(systemName: "bubble.circle.fill"), for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large), forImageIn: .normal)
        button.accessibilityIdentifier = "likeButton"
        
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
    
    private func setupView() {
        view.addSubview(coverImageView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(authorButton)
        view.addSubview(likeButton)
        view.addSubview(commentsButton)
        
//        authorButton.addTarget(self, action: #selector(didTapAuthorButton), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
//        commentsButton.addTarget(self, action: #selector(didTapCommentsButton), for: .touchUpInside)
    }
    
    private func setupLayout() {
        coverImageView.snp.makeConstraints {
//            $0.edges.equalTo(view.safeAreaLayoutGuide)
            $0.edges.equalToSuperview()
        }
        
        likeButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(30)
       }
        
        authorButton.snp.makeConstraints {
            $0.centerY.equalTo(likeButton)
            $0.trailing.equalTo(likeButton.snp.leading).offset(-15)
        }
        
        commentsButton.snp.makeConstraints {
            $0.centerY.equalTo(likeButton)
            $0.leading.equalTo(likeButton.snp.trailing).offset(15)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalTo(likeButton.snp.top).offset(-30)
            $0.height.lessThanOrEqualTo(view.snp.height).multipliedBy(0.5)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalTo(descriptionLabel.snp.top).offset(-15)
        }
    }
    
    private func bindViewModel() {
        viewModel.bookPublisher
            .sink { [weak self] book in
                self?.titleLabel.text = book?.title
                self?.descriptionLabel.text = book?.description
                self?.viewModel.fetchCurrentBookCoverImage()
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.bookImagePublisher
            .sink { [weak self] image in
                self?.coverImageView.image = image
            }
            .store(in: &viewModel.cancellables)
    }
    
    @objc private func didTapLikeButton() {
        self.likeButton.tintColor = .systemPink
        viewModel.likeBook()
    }
}
