import Foundation
import UIKit
import Combine

final class AuthorViewModel {
    private let authorName: String
    private var authorBooksSubject = PassthroughSubject<[Book], Never>()
    private var authorBooksImagesSubject = PassthroughSubject<[UIImage?], Never>()
    let bookAPIservice: BookAPIService
    var cancellables = Set<AnyCancellable>()

    var authorBooksPublisher: AnyPublisher<[Book], Never> {
        authorBooksSubject.eraseToAnyPublisher()
    }
    
    var authorBooksImagesPublisher: AnyPublisher<[UIImage?], Never> {
        authorBooksImagesSubject.eraseToAnyPublisher()
    }
    
    init(author: String, bookAPIservice: BookAPIService) {
        self.authorName = author
        self.bookAPIservice = bookAPIservice
    }

    func fetchAuthorBooks() {
        bookAPIservice.fetchBooksFromAuthor(with: authorName)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.authorBooksSubject.send([])
                }
            } receiveValue: { [weak self] books in
                self?.authorBooksSubject.send(books)
            }
            .store(in: &cancellables)
        
        fetchBooksImages()
    }

    func fetchBooksImages() {
        authorBooksSubject
            .sink { [weak self] books in
                guard let self = self else { return }
                
                let authorBooksImagesPublishers = books.map { book -> AnyPublisher<UIImage?, Never> in
                    if let urlString = book.imageLinks?.thumbnail, let url = URL(string: urlString) {
                        return self.bookAPIservice.fetchImage(at: url)
                            .map { $0 }
                            .catch { _ in Just(nil) }
                            .eraseToAnyPublisher()
                    } else {
                        return Just(nil).eraseToAnyPublisher()
                    }
                }
                
                Publishers.MergeMany(authorBooksImagesPublishers)
                    .collect()
                    .sink(receiveCompletion: { [weak self] completion in
                        if case .failure = completion {
                            self?.authorBooksImagesSubject.send([])
                        }
                    }, receiveValue: { [weak self] images in
                        self?.authorBooksImagesSubject.send(images)
                    })
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)
    }
    
    func getAuthor() -> String {
        return authorName
    }
    
}
