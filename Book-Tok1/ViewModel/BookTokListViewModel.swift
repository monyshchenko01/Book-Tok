//
//  BookTokListViewModel.swift
//  Book-Tok1
//
//  Created by Kira Zholtikova on 18.12.2024.
//
import Combine
import UIKit

final class BookTokListViewModel: BaseBookTokViewModel {
    private let books: [Book]
    private let images: [UIImage?]
    
    init(books: [Book], images: [UIImage?], bookAPIservice: BookAPIService, index: Int) {
        self.books = books
        self.images = images
        super.init(bookAPIservice: bookAPIservice)
        self.index = index
    }

    override func fetchBook() {
        guard books.indices.contains(index) else { return }
        bookSubject.send(books[index])
        isLikedSubject.send(findBook(books[index]) != nil)
    }
    
    override func fetchCurrentBookImage() {
        guard images.indices.contains(index) else { return }
        bookImageSubject.send(images[index])
    }

    override func nextBook() {
        index += 1
        fetchBook()
    }

    override func previousBook() {
        index -= 1
        fetchBook()
    }
    
    override func isSwipeUpAllowed() -> Bool {
        return index < books.count - 1
    }
    
    override func isSwipeDownAllowed() -> Bool {
        return index > 0
    }

}
