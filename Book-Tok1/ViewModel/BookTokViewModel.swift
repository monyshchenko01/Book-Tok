//
//  BookTokViewModel.swift
//  Book-Tok1
//
//  Created by Kira Zholtikova on 13.12.2024.
//
import Foundation
import Combine

final class BookTokViewModel {
    private var bookSubject = CurrentValueSubject<Book?, Never>(nil)
    private var isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let bookAPIservice: BookAPIService
    var cancellables = Set<AnyCancellable>()
    
    var bookPublisher: AnyPublisher<Book?, Never> {
        bookSubject.eraseToAnyPublisher()
    }

    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    
    init(bookAPIservice: BookAPIService) {
        self.bookAPIservice = bookAPIservice
    }
    
    func fetchRandomBook() {
        isLoadingSubject.send(true)
        
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
    
    func likeBook() {
        guard let currentBook = bookSubject.value else { return }
        
        do {
//            try context.save()
            print("Книга '\(currentBook.title)' додана до лайкнутих!")
        } catch {
            print("Помилка при додаванні книги: \(error)")
        }
    }
    
    func openComments() {
        
    }
    
    func goToAuthor() {
        
    }
}
