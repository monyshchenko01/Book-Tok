//
//  BookTokViewModel.swift
//  Book-Tok1
//
//  Created by Kira Zholtikova on 13.12.2024.
//
import Foundation
import CoreData
import UIKit
import Combine

final class BookTokViewModel {
    var bookSubject = CurrentValueSubject<Book?, Never>(nil)
    private let bookImageSubject = CurrentValueSubject<UIImage?, Never>(nil)
    let isLikedSubject = CurrentValueSubject<Bool, Never>(false)

    let bookAPIservice: BookAPIService
    var cancellables = Set<AnyCancellable>()
    
    var bookPublisher: AnyPublisher<Book?, Never> {
        bookSubject.eraseToAnyPublisher()
    }
    
    var bookImagePublisher: AnyPublisher<UIImage?, Never> {
        bookImageSubject.eraseToAnyPublisher()
    }
    
    var isLikedPublished: AnyPublisher<Bool, Never> {
        isLikedSubject.eraseToAnyPublisher()
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
                    self?.isLikedSubject.send(false)
                }
            } receiveValue: { [weak self] book in
                self?.bookSubject.send(book)
                self?.isLikedSubject.send(self?.findBook(book) != nil)
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
    
    private func findBook(_ book: Book) -> BookEntity? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Failed to get AppDelegate")
            return nil
        }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", book.title)
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            return nil
        }
    }
    
    func updateLikedStatus() {
        guard let currentBook = bookSubject.value else { return }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Failed to get AppDelegate")
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        if let existingBookEntity = findBook(currentBook) {
            context.delete(existingBookEntity)
            isLikedSubject.send(false)
        } else {
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
            isLikedSubject.send(true)
        }
        do {
            try context.save()
        } catch {
            print("Failed to toggle liked status: \(error)")
        }
    }
    
    func getAuthor() -> String? {
        guard let currentBook = bookSubject.value else { return nil }
        return currentBook.authors?.first
    }
    
    func currentBookEntity() -> BookEntity? {
        guard let currentBook = bookSubject.value else { return nil }
        return findBook(currentBook)
    }
    
    func getContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Failed to get AppDelegate")
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
}

