//
//  BookTokView.swift
//  Book-Tok1
//
//  Created by Kira Zholtikova on 18.12.2024.
//
import Foundation
import UIKit
import SnapKit

final class BookInfoView : UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 24, weight: .heavy)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let categoryLabel = UILabel()
        
        categoryLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        categoryLabel.textColor = .white
        categoryLabel.textAlignment = .center
        categoryLabel.backgroundColor = .systemBlue
        categoryLabel.layer.cornerRadius = 15
        categoryLabel.layer.masksToBounds = true
        categoryLabel.numberOfLines = 1
    
        return categoryLabel
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
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        return stackView
    }()
    
    init() {
        super.init(frame: .zero)
        setupView()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(categoryLabel)
        stackView.addArrangedSubview(ratingView)
        stackView.addArrangedSubview(descriptionLabel)
    }

    
    private func setupLayout() {
        stackView.snp.makeConstraints{
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(10)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.height.lessThanOrEqualTo(UIScreen.main.bounds.height / 4)
        }
    }
    
    func configure(with book: Book) {
        titleLabel.text = book.title

        if let categories = book.categories, !categories.isEmpty {
            categoryLabel.isHidden = false
            categoryLabel.text = categories.first
        } else {
            categoryLabel.isHidden = true
        }

        if let rating = book.averageRating, rating > 0 {
            setupRating(rating)
            ratingView.isHidden = false
        } else {
            ratingView.isHidden = true
        }

        if let description = book.description, !description.isEmpty {
            descriptionLabel.isHidden = false
            descriptionLabel.text = description
        } else {
            descriptionLabel.isHidden = true
        }

        layoutIfNeeded()
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
        ratingView.addArrangedSubview(UIView())
        
        layoutIfNeeded()
    }
    
    private func addStars(type: String, count: Int) {
        for _ in 0..<count {
            let starImageView = UIImageView(image: UIImage(systemName: type))
            starImageView.tintColor = .systemYellow
            starImageView.contentMode = .scaleAspectFit
            starImageView.translatesAutoresizingMaskIntoConstraints = false
            starImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
            starImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            ratingView.addArrangedSubview(starImageView)
        }
    }
}
