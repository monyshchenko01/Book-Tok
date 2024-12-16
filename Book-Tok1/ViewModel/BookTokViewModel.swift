//
//  BookTokViewModel.swift
//  Book-Tok1
//
//  Created by Kira Zholtikova on 13.12.2024.
//
import Foundation
import UIKit
import Combine

final class BookTokViewModel {
    private var bookSubject = CurrentValueSubject<Book?, Never>(nil)
    private let bookImageSubject = CurrentValueSubject<UIImage?, Never>(nil)

    private let bookAPIservice: BookAPIService
    var cancellables = Set<AnyCancellable>()
    
    var bookPublisher: AnyPublisher<Book?, Never> {
        bookSubject.eraseToAnyPublisher()
    }
    
    var bookImagePublisher: AnyPublisher<UIImage?, Never> {
        bookImageSubject.eraseToAnyPublisher()
    }

    init(bookAPIservice: BookAPIService) {
        self.bookAPIservice = bookAPIservice
    }
    
    func fetchRandomBook() {
        bookAPIservice.fetchRandomBook()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.bookSubject.send(nil)
                }
            } receiveValue: { [weak self] book in
                self?.bookSubject.send(book)
            }
            .store(in: &cancellables)
    }
    
    func fetchCurrentBookCoverImage() {
        guard let coverUrl = bookSubject.value?.imageLinks?.thumbnail, let url = URL(string: coverUrl) else { return }
       
        bookAPIservice.fetchImage(at: url)
           .receive(on: DispatchQueue.main)
           .sink(receiveCompletion: { [weak self] completion in
               if case .failure = completion {
                   self?.bookImageSubject.send(nil)
               }
           }, receiveValue: { [weak self] image in
               self?.bookImageSubject.send(image)
           })
           .store(in: &cancellables)
   }
    
    func likeBook() {
        guard let currentBook = bookSubject.value else { return }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let bookEntity = BookEntity(context: context)
        bookEntity.title = currentBook.title
        bookEntity.authors = currentBook.authors
        bookEntity.bookDescription = currentBook.description
        bookEntity.categories = currentBook.categories
        bookEntity.averageRating = currentBook.averageRating ?? 0.0

        if let imageLinks = currentBook.imageLinks {
            let imageLinksEntity = ImageLinksEntity(context: context)
            imageLinksEntity.smallThumbnail = imageLinks.smallThumbnail
            imageLinksEntity.thumbnail = imageLinks.thumbnail
            bookEntity.imageLinks = imageLinksEntity
        }

        do {
            try context.save()
        } catch {
            print("Failed to save book: \(error)")
        }
    }
    
    func openComments() {
        
    }
    
    func goToAuthor() {
        
    }
}
