import UIKit
import SnapKit

class BookCell: UITableViewCell {
    static let reuseIdentifier = "BookCell"
    private let bookImageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupGradientBackground()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        titleLabel.font = .boldSystemFont(ofSize: 16)
        authorLabel.font = .systemFont(ofSize: 14)
        authorLabel.textColor = .gray
        contentView.addSubview(bookImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        bookImageView.contentMode = .scaleAspectFill
        bookImageView.layer.cornerRadius = 16
        bookImageView.clipsToBounds = true
        bookImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(8)
            $0.width.equalTo(100)
            $0.height.equalTo(140)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.leading.equalTo(bookImageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(8)
        }
        authorLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(bookImageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(8)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        authorLabel.text = nil
    }
    
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = contentView.bounds
        gradientLayer.colors = [UIColor.lightGray.cgColor, UIColor.darkGray.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        contentView.layer.insertSublayer(gradientLayer, at: 0)
    }

    func configure(with book: Book, image: UIImage?) {
        titleLabel.text = book.title
        authorLabel.text = book.authors?.joined(separator: ", ")
        
        guard let bookImage = image else {
            return bookImageView.backgroundColor = .gray
        }
        bookImageView.image = bookImage
    }
    
}