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
