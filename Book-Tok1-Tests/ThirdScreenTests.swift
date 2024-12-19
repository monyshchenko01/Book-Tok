import XCTest
@testable import Book_Tok1

final class BookTokListViewModelTests: XCTestCase {
    var viewModel: BookTokListViewModel!
    var mockBooks: [Book]!
    var mockImages: [UIImage?]!
    var bookAPIService = BookAPIService()

    override func setUp() {
        super.setUp()

        mockBooks = [
            Book(title: "Book 1", authors: ["Author 1"], description: "Description 1", categories: ["Category 1"], averageRating: 4.0, imageLinks: nil),
            Book(title: "Book 2", authors: ["Author 2"], description: "Description 2", categories: ["Category 2"], averageRating: 4.5, imageLinks: nil),
            Book(title: "Book 3", authors: ["Author 3"], description: "Description 3", categories: ["Category 3"], averageRating: 5.0, imageLinks: nil)
        ]
        mockImages = [UIImage(), UIImage(), UIImage()]

        viewModel = BookTokListViewModel(books: mockBooks, images: mockImages, bookAPIservice: bookAPIService, index: 0)
    }

    override func tearDown() {
        viewModel = nil
        mockBooks = nil
        mockImages = nil
        super.tearDown()
    }
    
    func testFetchInitialBook() {
        viewModel.fetchBook()

        XCTAssertEqual(viewModel.bookSubject.value?.title, "Book 1")
        XCTAssertFalse(viewModel.isLikedSubject.value)
    }
    
    func testFetchCurrentBookImage() {
        viewModel.fetchCurrentBookImage()

        XCTAssertEqual(viewModel.bookImageSubject.value, mockImages[0])
    }

    func testNextBookFetchesNext() {
        viewModel.nextBook()

        XCTAssertEqual(viewModel.bookSubject.value?.title, "Book 2")
        XCTAssertFalse(viewModel.isLikedSubject.value)
    }
    
    func testPreviousBookFetchesPrevious() {
        viewModel.index = 1

        viewModel.previousBook()
        
        XCTAssertEqual(viewModel.bookSubject.value?.title, "Book 1")
    }

    func testIsSwipeUpNotAllowedForLast() {
        viewModel.index = mockBooks.count - 1
        XCTAssertFalse(viewModel.isSwipeUpAllowed())
    }

    func testIsSwipeDownNotAllowedForFirst() {
        XCTAssertFalse(viewModel.isSwipeDownAllowed())
    }


}
