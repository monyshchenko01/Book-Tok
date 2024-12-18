//
//  BookTokViewControllerTests.swift
//  Book-Tok1
//
//  Created by Kira Zholtikova on 18.12.2024.
//
import Combine
import XCTest
@testable import Book_Tok1

class MockBookTokViewModel: BaseBookTokViewModel {
    override func updateLikedStatus() {
        isLikedSubject.send(!isLikedSubject.value)
    }
}

final class BookTokViewModelTests: XCTestCase {
    var viewController: BookTokViewController!
    var mockViewModel: MockBookTokViewModel!
    
    let mockBook = Book(
        title: "Test Title",
        authors: ["Author"],
        description: "Test Description",
        categories: ["Category"],
        averageRating: 4.0,
        imageLinks: nil
    )
    
    override func setUp() {
        mockViewModel = MockBookTokViewModel(bookAPIservice: BookAPIService())
        viewController = BookTokViewController(viewModel: mockViewModel)
        _ = viewController.view
    }
    
    override func tearDown() {
        mockViewModel = nil
        viewController = nil
    }
    
    func testInitialState() {
        XCTAssertNil(mockViewModel.bookSubject.value)
        XCTAssertFalse(mockViewModel.isLikedSubject.value)
    }

    
    func testDidTapAuthorButtonOpensAuthotScreen() {
        mockViewModel.bookSubject.send(mockBook)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UINavigationController(rootViewController: viewController)
        }

        viewController.didTapAuthorButton()

        XCTAssertTrue(viewController.navigationController?.topViewController is AuthorViewController)
    }
    
    func testDidTapLikeButtonSendsLikedSignal() {
        XCTAssertFalse(mockViewModel.isLikedSubject.value)

        viewController.didTapLikeButton()

        XCTAssertTrue(mockViewModel.isLikedSubject.value)
    }
    
    func testDidTapLikeButtonUpdatesButtonColor() {
        let initialColor = viewController.likeButton.tintColor

        viewController.didTapLikeButton()

        XCTAssertNotEqual(initialColor, viewController.likeButton.tintColor)
    }

    func testDidTapCommentsButtonOpensCommentsScreen() {
        mockViewModel.bookSubject.send(mockBook)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UINavigationController(rootViewController: viewController)
        }
        viewController.didTapCommentsButton()

        XCTAssertTrue(viewController.navigationController?.presentedViewController is CommentsViewController)
    }

    func testBookPublisherUpdatesBookInfoView() {
        mockViewModel.bookSubject.send(mockBook)

        XCTAssertEqual(viewController.bookInfoView.titleLabel.text, mockBook.title)
        XCTAssertEqual(viewController.bookInfoView.descriptionLabel.text, mockBook.description)
        XCTAssertEqual(viewController.bookInfoView.categoryLabel.text, mockBook.categories?.first)
    }

    func testBookImagePublisherUpdatesCoverImageView() {
        let mockImage = UIImage()

        mockViewModel.bookImageSubject.send(mockImage)
        
        XCTAssertEqual(viewController.coverImageView.image, mockImage)
    }
    
    func testAnimateContentOutMovesContentOut() {
        viewController.view.transform = .identity

        viewController.animateContentOut()

        XCTAssertEqual(viewController.view.transform.ty, -viewController.view.frame.height)
    }

    func testAnimateContentInMovesContentIn() {
        viewController.view.transform = CGAffineTransform(translationX: 0, y: viewController.view.frame.height)

        viewController.animateContentIn()

        XCTAssertEqual(viewController.view.transform, .identity)
    }
    
    func testGetAuthorReturnCurrentBookAuthor() {
        mockViewModel.bookSubject.send(mockBook)
        let author = mockViewModel.getAuthor()

        XCTAssertEqual(mockBook.authors?.first, author)
    }
    
    func testConfigureCell() {
        let cell = BookCell(style: .default, reuseIdentifier: BookCell.reuseIdentifier)
        let mockImage = UIImage()

        cell.configure(with: mockBook, image: mockImage)

        XCTAssertEqual(cell.titleLabel.text, mockBook.title)
        XCTAssertEqual(cell.bookImageView.image, mockImage)
         
    }
}

